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

@interface ZaloContactService (ChangeHandle)

@end

@implementation ZaloContactService (ChangeHandle)
// response for server event
- (void)setUp {
    NSLog(@"Begin reponse to server event");
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

- (void)addContact:(ContactEntity*)contact {
    //add success
    if (![self.accountDictionary objectForKey:contact.accountId]) {
        [self addContact:contact toContactDict:self.contactDictionary andAccountDict:self.accountDictionary];
        [self incommingAddWithContact:contact];
        [self throttleUpdateDataSource];
        //already has contact in data -> update
    } else {
        [self updateContact:contact];
    }
}

- (void)removeContact:(NSString*)accountId {
    ContactEntity *contact = [self.accountDictionary objectForKey:accountId];
    if (!contact) return;
    
    // remove success
    if ([self deleteContact:contact inContactDict:self.contactDictionary andAccountDict:self.accountDictionary]) {
        [self incommingRemoveWithContact:contact];
        [self throttleUpdateDataSource];
    }
}

- (void)updateContact:(ContactEntity*)contact {
    // exist -> continue
    ContactEntity *oldContact = [self.accountDictionary objectForKey:contact.accountId];
    if (!oldContact) return;
    // changes does not affect order -> replace
    if ([oldContact compare:contact] == NSOrderedSame) {
        [self updateContactInDataSource:contact];
        [self incommingUpdateWithContact:contact];
        // changes affect order -> delete and insert
    } else {
        // no need to care if add or remove success or not
        [self deleteContact:oldContact inContactDict:self.contactDictionary andAccountDict:self.accountDictionary];
        [self addContact:contact toContactDict:self.contactDictionary andAccountDict:self.accountDictionary];
        [self incommingReorderWithContact:contact];
    }
    
    [self throttleUpdateDataSource];
}


- (void)incommingAddWithContact:(ContactEntity*)contact {
    ChangeFootprint *addFootprint = [ChangeFootprint initChangeBy:contact.accountId];
    [self.addSet addObject:addFootprint];
}

- (void)incommingRemoveWithContact:(ContactEntity*)contact {
    ChangeFootprint *removeFootprint = [ChangeFootprint initChangeBy:contact.accountId];
    [self.addSet removeObject:removeFootprint];
    [self.updateSet removeObject:removeFootprint];
    [self.removeSet addObject:removeFootprint];
}


- (void)incommingUpdateWithContact:(ContactEntity*)contact {
    ChangeFootprint *updateFootprint = [ChangeFootprint initChangeBy:contact.accountId];
    // udpate when has incomming add -> keep add animation -> not add to update set
    if ([self.addSet containsObject:updateFootprint]) return;;
    [self.updateSet addObject:updateFootprint];
}

- (void)incommingReorderWithContact:(ContactEntity*)contact {
    ChangeFootprint *reorderFootprint = [ChangeFootprint initChangeBy:contact.accountId];
    [self.removeSet addObject:reorderFootprint];
    [self.addSet addObject:reorderFootprint];
}



# pragma mark: Update data source
// if exist -> update. if not exist -> add
// return YES if add, NO if udpate
-(void) addContact:(ContactEntity*)contact toContactDict:(ContactMutableDictionary *)contactDict andAccountDict:(AccountMutableDictionary *)accountDict {
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
    
    [self saveLatestChanges];
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
    [self saveLatestChanges];
    
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
    
    // section become e mpty after delete -> remove section then YES
    if ([contactDict objectForKey:contact.header].count) {
        [self saveLatestChanges];
        return YES;
    }
    
    [contactDict removeObjectForKey:contact.header];
    
    [self saveLatestChanges];
    // delete success
    return YES;
}


#pragma mark - udpate data handler

- (void)throttleUpdateDataSource {
    __weak typeof(self) weakSelf = self;
    dispatch_throttle_by_type(0.5, GCDThrottleTypeInvokeAndIgnore, ^{
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
    
    [self notifyListenerWithAddSectionList:addHeaderSet.copy removeSectionList:removeHeaderSet.copy addContact:self.addSet.copy removeContact:self.removeSet.copy updateContact:self.updateSet.copy newContactDict:self.contactDictionary.copy newAccountDict:self.accountDictionary.copy];
    
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
