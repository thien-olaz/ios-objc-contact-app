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
    
    [self.apiService setOnOnlineContactAdded:^(ContactEntity * newContact) {
        dispatch_async(weakSelf.apiServiceQueue, ^{
            ZaloContactService *strongSelf = weakSelf;
            [strongSelf addOnlineContact:newContact];
        });
    }];
    
    [self.apiService setOnOnlineContactDeleted:^(ContactEntity * deleteContact) {
        dispatch_async(weakSelf.apiServiceQueue, ^{
            ZaloContactService *strongSelf = weakSelf;
            [strongSelf removeOnlineContact:deleteContact];
        });
    }];
    
}

#pragma mark - server actions handle

- (void)addFootprintForContactId:(NSString *)accountId {
    ChangeFootprint *footprint = [ChangeFootprint initChangeBy:accountId];
    [self.footprintDict setObject:footprint forKey:accountId];
}

- (void)addContact:(ContactEntity*)contact {
    // exist -> turn into update contact
    if ([self.accountDictionary objectForKey:contact.accountId]) {
        [self updateContact:contact];
        return;
    }
    // add to data source
    [self addContact:contact toContactDict:self.contactDictionary andAccountDict:self.accountDictionary];
    
    [self addFootprintForContactId:contact.accountId];
    [self throttleUpdateDataSource];
}

- (void)removeContact:(NSString*)accountId {
    ContactEntity *contact = [self.accountDictionary objectForKey:accountId];
    if (!contact) return;
    // delete in data source
    if (![self deleteContact:contact inContactDict:self.contactDictionary andAccountDict:self.accountDictionary]) return;
    // delete success
    [self addFootprintForContactId:accountId];
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
    [self addFootprintForContactId:contact.accountId];
    [self throttleUpdateDataSource];
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
                [self.footprintDict removeObjectForKey:footprint.accountId];
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
    /// Header diff
    NSSet *oldSet = [NSSet setWithArray:self.oldContactDictionary.allKeys.copy];
    NSSet *newSet = [NSSet setWithArray:self.contactDictionary.allKeys.copy];
    
    NSMutableSet *removeHeaderSet = oldSet.mutableCopy;
    [removeHeaderSet minusSet:newSet];
    NSMutableSet *addHeaderSet = newSet.mutableCopy;
    [addHeaderSet minusSet:oldSet];
    
    /// Contact diff
    NSSet *oldAccountSet = [NSSet setWithArray:self.oldAccountDictionary.allKeys.copy];
    NSSet *newAccountSet = [NSSet setWithArray:self.accountDictionary.allKeys.copy];
    
    /// Remove footprint
    NSMutableSet *removeAccountSet = oldAccountSet.mutableCopy;
    [removeAccountSet minusSet:newAccountSet];
    
    NSMutableSet *removeFootprint = [NSMutableSet new];;
    for (NSString *contactId in removeAccountSet) {
        [removeFootprint addObject:self.footprintDict[contactId]];
    }
    
    /// Add footprint
    NSMutableSet *addContactIdSet = newAccountSet.mutableCopy;
    [addContactIdSet minusSet:oldAccountSet];
    
    NSMutableSet *addFootprint = [NSMutableSet new];;
    for (NSString *contactId in addContactIdSet) {
        [addFootprint addObject:self.footprintDict[contactId]];
    }
    
    /// Remove add and remove footprint from footprint dict to get the update part
    [self.footprintDict removeObjectsForKeys:addContactIdSet.allObjects];
    [self.footprintDict removeObjectsForKeys:removeAccountSet.allObjects];
    
    /// Update footprint
    NSMutableSet *updateFootprint = [NSMutableSet new];;
    for (NSString *contactId in self.footprintDict.allKeys) {
        // not affect order
        if ([self.oldAccountDictionary[contactId] compare: self.accountDictionary[contactId]] == NSOrderedSame) {
            [updateFootprint addObject:self.footprintDict[contactId]];
        } else {
            [addFootprint addObject:self.footprintDict[contactId]];
            [removeFootprint addObject:self.footprintDict[contactId]];
        }
    }
    
    [self notifyListenerWithAddSectionList:addHeaderSet.copy removeSectionList:removeHeaderSet.copy addContact:addFootprint.copy removeContact:removeFootprint.copy updateContact:updateFootprint.copy newContactDict:[self getContactDictCopy] newAccountDict:self.accountDictionary.copy];
    
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
    [self.footprintDict removeAllObjects];
}


#pragma mark online friends handle
- (void)addOnlineContact:(ContactEntity *)contact {
    if ([self.addOnlineList containsObject:contact]) {
        [self.addOnlineList removeObject:contact];
    }
    [self.addOnlineList addObject:contact];
    [self throttleUpdateOnlineFriend];
}

- (void)removeOnlineContact:(ContactEntity *)contact {
    if ([self.removeOnlineList containsObject:contact]) {
        [self.removeOnlineList removeObject:contact];
    }
    [self.removeOnlineList addObject:contact];
    [self throttleUpdateOnlineFriend];
}

- (void)throttleUpdateOnlineFriend {
    __weak typeof(self) weakSelf = self;
    dispatch_throttle_by_type(5, GCDThrottleTypeInvokeAndIgnore, ^{
        DISPATCH_ASYNC_IF_NOT_IN_QUEUE(GLOBAL_QUEUE, ^{
            [weakSelf updateOnlineList];
        });
    });
}

- (void)updateOnlineList {
    for (OnlineContactEntity *contact in self.removeOnlineList) {
        if ([onlineList containsObject:contact]) [onlineList removeObject:contact];
    }
    
    for (OnlineContactEntity *contact in self.addOnlineList) {
        NSUInteger foundIndex = [onlineList indexOfObject:contact
                                            inSortedRange:(NSRange){0, [onlineList count]} options:NSBinarySearchingInsertionIndex usingComparator:^NSComparisonResult(OnlineContactEntity *obj1, OnlineContactEntity *obj2) {
            return [obj1 compareTime:obj2];
        }];
        
        if (foundIndex == NSNotFound) return;
        [onlineList insertObject:contact atIndex:foundIndex];
    }
    
    for (id<ZaloContactEventListener> listener in self.listeners) {
        if ([listener respondsToSelector:@selector(onServerChangeOnlineFriendsWithAddContact:removeContact:updateContact:)]) {
            [listener onServerChangeOnlineFriendsWithAddContact:self.addOnlineList.mutableCopy removeContact:self.removeOnlineList.mutableCopy updateContact:@[].mutableCopy];
        }
    }
    
    [self.removeOnlineList removeAllObjects];
    [self.addOnlineList removeAllObjects];
    
}

@end
