//
//  ZaloContactService+ChangeHandle.m
//  zalo-contact
//
//  Created by Thiện on 21/12/2021.
//

#import "ZaloContactService+ChangeHandle.h"
#import "ZaloContactService+Observer.h"
#import "ZaloContactService+Storage.h"
#import "GCDThrottle.h"

float const throttleTime = 0.75;

@interface ZaloContactService (ChangeHandle)

@end

@implementation ZaloContactService (ChangeHandle)
// response for server event
- (void)setUp {
    LOG(@"#-#-# FAKE SOCKET CONNECTED #-#-#");
    __weak typeof(self) weakSelf = self;
    [self.apiService setOnContactAdded:^(ContactEntity * newContact) {
        dispatch_async(weakSelf.apiServiceQueue, ^{
            ZaloContactService *strongSelf = weakSelf;
            [strongSelf addContact:newContact];
        });
    }];
    
    [self.apiService setOnContactDeleted:^(NSString * accountId) {
        dispatch_async(weakSelf.apiServiceQueue, ^{
            ZaloContactService *strongSelf = weakSelf;
            [strongSelf removeContact:accountId];
        });
    }];
    
    [self.apiService setOnContactUpdated:^(ContactEntity * newContact) {
        dispatch_async(weakSelf.apiServiceQueue, ^{
            ZaloContactService *strongSelf = weakSelf;
            [strongSelf updateContact:newContact];
        });
    }];
    
}

#pragma mark - server actions handle

- (void)addContact:(ContactEntity*)contact {
    // exist -> turn into update contact
    if ([self.accountDictionary objectForKey:contact.accountId]) {
        [self updateContact:contact];
        return;
    }
    // add to data source
    [self addContact:contact toContactDict:self.contactDictionary andAccountDict:self.accountDictionary];
    
    [self incommingAddMediator:contact];
    [self throttleUpdateDataSource];
}

- (void)removeContact:(NSString*)accountId {
    ContactEntity *contact = [self.accountDictionary objectForKey:accountId];
    if (!contact) return;
    // delete in data source
    if (![self deleteContact:contact inContactDict:self.contactDictionary andAccountDict:self.accountDictionary]) return;
    // delete success
    [self incommingRemoveWithContact:contact];
    [self throttleUpdateDataSource];
}

- (void)updateContact:(ContactEntity*)contact {
    // exist -> continue
    ContactEntity *oldContact = [self.accountDictionary objectForKey:contact.accountId];
    if (!oldContact) return;
    
    // changes does not affect order
    if ([oldContact compare:contact] == NSOrderedSame) {
        // replace in data source
        [self updateContactInDataSource:contact];
    } else {
        // delete than insert
        [self deleteContact:oldContact inContactDict:self.contactDictionary andAccountDict:self.accountDictionary];
        [self addContact:contact toContactDict:self.contactDictionary andAccountDict:self.accountDictionary];
    }
    
    [self incommingUpdateMediator:contact];
    [self throttleUpdateDataSource];
}

#pragma mark - incomminincommingUpdateMediator change handle
/*
 add, insert and remove is calculate base on the different between old list and new list
 */

- (void)incommingAddMediator:(ContactEntity*)contact {
    // old list has the same accountId item
    if ([self.oldAccountDictionary objectForKey:contact.accountId]) {
        // update animation
        [self incommingUpdateMediator:contact];
    } else {
        // add animation
        [self incommingAddWithContact:contact];
    }
}

- (void)incommingAddWithContact:(ContactEntity*)contact {
    ChangeFootprint *addFootprint = [ChangeFootprint initChangeBy:contact.accountId];
    [self.removeSet removeObject:addFootprint];
    [self.updateSet removeObject:addFootprint];
    //    NSLog(@"add anim");
    [self.addSet addObject:addFootprint];
}

- (void)incommingRemoveWithContact:(ContactEntity*)contact {
    ChangeFootprint *removeFootprint = [ChangeFootprint initChangeBy:contact.accountId];
    [self.addSet removeObject:removeFootprint];
    [self.updateSet removeObject:removeFootprint];
    //    NSLog(@"remove anim");
    [self.removeSet addObject:removeFootprint];
}

- (void)incommingUpdateMediator:(ContactEntity*)contact {
    ContactEntity *oldContact = [self.oldAccountDictionary objectForKey:contact.accountId];
    // old list has the same accountId item
    if (!oldContact) return;
    // if not affect list order
    if ([oldContact compare:contact] == NSOrderedSame) {
        // update anim
        [self incommingUpdateWithContact:contact];
    } else {
        // update reorder anim
        [self incommingReorderWithContact:contact];
    }
}

- (void)incommingUpdateWithContact:(ContactEntity*)contact {
    ChangeFootprint *updateFootprint = [ChangeFootprint initChangeBy:contact.accountId];
    [self.removeSet removeObject:updateFootprint];
    [self.addSet removeObject:updateFootprint];
    //    NSLog(@"update anim");
    [self.updateSet addObject:updateFootprint];
}

- (void)incommingReorderWithContact:(ContactEntity*)contact {
    ChangeFootprint *reorderFootprint = [ChangeFootprint initChangeBy:contact.accountId];
    [self.updateSet removeObject:reorderFootprint];
    //    NSLog(@"reorder anim");
    [self.removeSet addObject:reorderFootprint];
    [self.addSet addObject:reorderFootprint];
}

# pragma mark: Update data source
// if exist -> update. if not exist -> add
// return YES if add, NO if udpate
- (void)addContact:(ContactEntity*)contact toContactDict:(ContactMutableDictionary *)contactDict andAccountDict:(AccountMutableDictionary *)accountDict {
    // no section -> create new section
    if (![contactDict objectForKey:contact.header] || ![[contactDict objectForKey:contact.header] count]) {
        // not have a section -> add section
        [contactDict setObject:[[NSMutableArray alloc] initWithArray:@[contact]] forKey:contact.header];
        [accountDict setObject:contact forKey:contact.accountId];
    } else {
        // has a section -> insert
        NSMutableArray<ContactEntity *> *sortedContactArray = [contactDict objectForKey:contact.header];
        NSUInteger insertIndex = [sortedContactArray indexOfObject:contact
                                                     inSortedRange:(NSRange){0, [sortedContactArray count]}
                                                           options:NSBinarySearchingInsertionIndex
                                                   usingComparator:^NSComparisonResult(ContactEntity *obj1, ContactEntity *obj2) {
            return [obj1 compare:obj2];
        }];
        [accountDict setObject:contact forKey:contact.accountId];
        [sortedContactArray insertObject:contact atIndex:insertIndex];
    }
    
    [self saveAdd:contact];
}

// if not exist -> do nothing. if exist -> replace
- (void)updateContactInDataSource:(ContactEntity*)contact {
    // update the contact with the newest contact
    [self.accountDictionary setObject:contact forKey:contact.accountId];
    
    // no section -> can not update
    if (![self.contactDictionary objectForKey:contact.header]) return;
    
    NSMutableArray<ContactEntity *> *sortedContactArray = [self.contactDictionary objectForKey:contact.header];
    NSUInteger replaceIndex = [sortedContactArray indexOfObject:contact
                                                  inSortedRange:(NSRange){0, [sortedContactArray count]}
                                                        options:NSBinarySearchingFirstEqual
                                                usingComparator:^NSComparisonResult(ContactEntity *obj1, ContactEntity *obj2) {
        return [obj1 compare:obj2];
    }];
    // not found object to replace
    if (replaceIndex == NSNotFound) return;
    
    // add to section
    [sortedContactArray replaceObjectAtIndex:replaceIndex withObject:contact];
    [self saveUpdate:contact];
}

// return YES if exist and deleted, return NO if not exist
- (BOOL)deleteContact:(ContactEntity*)contact inContactDict:(ContactMutableDictionary *)contactDict andAccountDict:(AccountMutableDictionary *)accountDict {
    [accountDict removeObjectForKey:contact.accountId];
    // no section -> return NO
    if (![contactDict objectForKey:contact.header]) return NO;
    NSMutableArray<ContactEntity *> *sortedContactArray = [contactDict objectForKey:contact.header];
    NSUInteger deleteIndex = [sortedContactArray indexOfObject:contact
                                                 inSortedRange:(NSRange){0, [sortedContactArray count]}
                                                       options:NSBinarySearchingFirstEqual
                                               usingComparator:^NSComparisonResult(ContactEntity *obj1, ContactEntity *obj2) {
        return [obj1 compare:obj2];
    }];
    // has section but not found -> return NO
    if (deleteIndex == NSNotFound) return NO;
    
    [[contactDict objectForKey:contact.header] removeObjectAtIndex:deleteIndex];
    [self saveDelete:contact.accountId];
    // section become e mpty after delete -> remove section then YES
    if ([contactDict objectForKey:contact.header].count) return YES;
    [contactDict removeObjectForKey:contact.header];
    // delete success
    return YES;
}

#pragma mark - instance actions
- (void)deleteContact:(ContactEntity *)contact {
    dispatch_async(self.apiServiceQueue, ^{
        if ([self deleteContact:contact inContactDict:self.oldContactDictionary andAccountDict:self.oldAccountDictionary]) {
            ContactEntity *curContact = [self.accountDictionary objectForKey:contact.accountId];
            ChangeFootprint *footprint = [ChangeFootprint initChangeBy:contact.accountId];
            if (curContact) {
                [self deleteContact:curContact inContactDict:self.contactDictionary andAccountDict:self.accountDictionary];
                [self.addSet removeObject:footprint];
                [self.removeSet removeObject:footprint];
                [self.updateSet removeObject:footprint];
            }
            
            NSMutableArray *removeSection = [NSMutableArray new];
            if (![self.oldContactDictionary objectForKey:contact.header]) {
                [removeSection addObject:contact.header];
            }
            
            NSMutableDictionary *oldDictCopy = [NSMutableDictionary new];
            for (NSString *key in self.oldContactDictionary.keyEnumerator) {
                [oldDictCopy setObject:self.oldContactDictionary[key].mutableCopy forKey:key];
            }
            
            [self notifyListenerWithAddSectionList:@[] removeSectionList:removeSection.copy addContact:[NSSet new]  removeContact:[NSSet setWithArray:@[footprint]] updateContact:[NSSet new] newContactDict:oldDictCopy newAccountDict:self.oldAccountDictionary.copy];
            self.bounceLastUpdate = YES;
            
        }
    });
}

#pragma mark - udpate data handler
- (void)throttleUpdateDataSource {
    __weak typeof(self) weakSelf = self;
    dispatch_throttle_by_type(throttleTime, GCDThrottleTypeInvokeAndIgnore, ^{
        dispatch_async(weakSelf.apiServiceQueue, ^{
            [weakSelf updateDataSource];
        });
    });
}

- (void)updateDataSource {
    if (self.bounceLastUpdate) {
        [self throttleUpdateDataSource];
        self.bounceLastUpdate = NO;
        return;
    }
    
    NSSet *oldSet = [NSSet setWithArray:self.oldContactDictionary.allKeys.copy];
    NSSet *newSet = [NSSet setWithArray:self.contactDictionary.allKeys.copy];
    
    NSMutableSet *removeHeaderSet = oldSet.mutableCopy;
    [removeHeaderSet minusSet:newSet];
    NSMutableSet *addHeaderSet = newSet.mutableCopy;
    [addHeaderSet minusSet:oldSet];
    
    [self notifyListenerWithAddSectionList:addHeaderSet.copy removeSectionList:removeHeaderSet.copy addContact:self.addSet.copy removeContact:self.removeSet.copy updateContact:self.updateSet.copy newContactDict:[self getContactDictCopy] newAccountDict:self.accountDictionary.copy];
    
    [self cacheChanges];
    [self cleanUpIncommingData];
}

// cache old data to quick compare
- (void)cacheChanges {
    self.oldContactDictionary = [NSMutableDictionary new];
    for (NSString *key in self.contactDictionary.keyEnumerator) {
        [self.oldContactDictionary setObject:self.contactDictionary[key].mutableCopy forKey:key];
    }
    self.oldAccountDictionary = self.accountDictionary.mutableCopy;
}

//clean up after all changed data is applied
- (void)cleanUpIncommingData {
    [self.addSet removeAllObjects];
    [self.removeSet removeAllObjects];
    [self.updateSet removeAllObjects];
}

@end
