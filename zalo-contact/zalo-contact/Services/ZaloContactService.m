//
//  ZaloContactService.m
//  zalo-contact
//
//  Created by Thiện on 06/12/2021.
//

#import "ZaloContactService.h"
#import "UserContacts.h"
#import "NSArrayExt.h"
#import "ContactGroupEntity.h"
#import "ContactEntity.h"
#import "ZaloContactService+Storage.h"
#import "ZaloContactService+Observer.h"
#import "GCDThrottle.h"
//MARK: - Usage
/*
 User for external and internal use
 */

@interface ZaloContactService () {
    NSMutableDictionary<NSString *,ContactEntity *> *cacheContactDictionary;
    
    AccountIdSet *addSet;
    AccountIdSet *removeSet;
    AccountIdSet *updateSet;
    
    NSMutableArray<NSString *> *addSectionList;
    NSMutableArray<NSString *> *removeSectionList;
    BOOL bounceLastUpdate;
    
    NSMutableArray<ContactEntity *> *addOnlineList;
    NSMutableArray<ContactEntity *> *removeOnlineList;
}
@property dispatch_queue_t contactServiceQueue;
@property dispatch_queue_t apiServicesQueue;
@property NSLock *dataLock;
@property NSLock *serviceLock;

@end

@implementation ZaloContactService 

static ZaloContactService *sharedInstance = nil;

+ (ZaloContactService *)sharedInstance {
    @synchronized([ZaloContactService class]) {
        if (!sharedInstance)
            sharedInstance = [self new];
        return sharedInstance;
    }
    return nil;
}

- (instancetype)init {
    self = super.init;
    
    _serviceLock = [NSLock new];
    
    _apiService = [MockAPIService new];
    
    cacheContactDictionary = [NSMutableDictionary new];
    
    addSet = [AccountIdSet new];
    removeSet = [AccountIdSet new];
    updateSet = [AccountIdSet new];
    
    addSectionList = [NSMutableArray new];
    removeSectionList = [NSMutableArray new];
    contactDictionary = [ContactDictionary new];
    bounceLastUpdate = NO;
    
    onlineList = [NSMutableArray new];
    addOnlineList = [NSMutableArray new];
    removeOnlineList = [NSMutableArray new];
    
    _dataLock = [NSLock new];
    
    accountDictionary = [NSMutableDictionary new];
    
    dispatch_queue_attr_t qos = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_USER_INITIATED, -1);
    _contactServiceQueue = dispatch_queue_create("_contactServiceQueue", qos);
    _apiServicesQueue = dispatch_queue_create("_apiServicesQueue", qos);
    
    dispatch_async(self.contactServiceQueue, ^{
        //        [self load];
    });
    [self setUp];
    //fetching data form server
    __weak typeof(self) weakSelf = self;
    
    //    [_apiService fetchContacts:^(NSArray<ContactEntity *> * contactsFromServer) {
    //        if (contactsFromServer.count <= 0) return;
    //
    //        NSArray<ContactEntity *> *sortedArr = [ContactEntity insertionSort:contactsFromServer];
    //
    //        [weakSelf didReceiveNewFullList:sortedArr];
    //    }];
    
    return self;
}

- (void)fetchLocalContact {
    [UserContacts.sharedInstance fetchLocalContacts];
    contactDictionary = [ContactEntity mergeContactDict:UserContacts.sharedInstance.getContactDictionary toDict:contactDictionary];
    
    // Complexity == all contacts
    for (NSArray<ContactEntity *> *contacts in [contactDictionary allValues]) {
        for (ContactEntity *contact in contacts) [accountDictionary setObject:contact forKey:contact.phoneNumber.copy];
    }
}

- (void)setUp {
    __weak typeof(self) weakSelf = self;
    [_apiService setOnContactAdded:^(ContactEntity * newContact) {
        //        push task to serial queue
        dispatch_async(weakSelf.apiServicesQueue, ^{
            ZaloContactService *strongSelf = weakSelf;
            [strongSelf addContact:newContact];
        });
    }];
    
    [_apiService setOnContactDeleted:^(NSString * accountId) {
        dispatch_async(weakSelf.apiServicesQueue, ^{
            ZaloContactService *strongSelf = weakSelf;
            [strongSelf removeContact:accountId];
        });
    }];
    
    [_apiService setOnContactUpdated:^(ContactEntity * newContact) {
        dispatch_async(weakSelf.apiServicesQueue, ^{
            ZaloContactService *strongSelf = weakSelf;
            [strongSelf updateContact:newContact];
        });
    }];
    
    [_apiService setOnOnlineContactAdded:^(ContactEntity * onlineContact) {
        
    }];
    
    [_apiService setOnOnlineContactDeleted:^(ContactEntity * onlineContact) {
        
    }];
}


- (void)addContact:(ContactEntity*)contact {
    if (![accountDictionary objectForKey:contact.accountId]) {
        [self addContactToDataSource:contact];
        [self incomingAddWithContact:contact];
    } else {
        [self updateContactInDataSource:contact];
        [self incomingUpdateWithContact:contact];
    }
    [self throttleUpdateDataSource];
}

- (void)removeContact:(NSString*)accountId {
    // if exist -> remove
    if ([accountDictionary objectForKey:accountId]) {
        // if delete sucess
        if ([self deleteContactInDataSource:[accountDictionary objectForKey:accountId]]) {
            [self incomingRemoveWithContact:accountId];
        }
        [self throttleUpdateDataSource];
    }
}

- (void)updateContact:(ContactEntity*)contact {
    //    if exist -> remove
    ContactEntity *oldContact = [accountDictionary objectForKey:contact.accountId];
    if (!oldContact) return;
    
    [self updateContactInDataSource:contact];
    // not change first name - last name - or phone number - affect order in list
    if ([oldContact compare:contact] == NSOrderedSame) {
        [self incomingUpdateWithContact:contact];
    } else {
        [self deleteContactInDataSource:oldContact];
        [self addContactToDataSource:contact];
        [self incomingReorderWithContact:contact];        
    }
    
    [self throttleUpdateDataSource];
}

- (void)deleteContactWithId:(NSString *)accountId {
    ContactEntity *removeContact = [accountDictionary objectForKey:accountId];
    if (!removeContact) return;
    if ([self deleteContactInDataSource:[accountDictionary objectForKey:accountId]]) {
        [self incomingRemoveWithContact:accountId];
        [self updateDataSource];
        bounceLastUpdate = YES;
    }
}

- (ContactDictionary *)getFullContactDict {
    return contactDictionary.copy;
}

- (OnlineContactEntityArray *)getOnlineContactList {
    return onlineList.copy;
}

- (NSArray<ContactEntity *>*)getFullContactList {
    return accountDictionary.allValues;
}

#pragma mark - udpate data handler

- (void)throttleUpdateDataSource {
    __weak typeof(self) weakSelf = self;
    dispatch_throttle_by_type(1.5, GCDThrottleTypeInvokeAndIgnore, ^{
        dispatch_async(weakSelf.apiServicesQueue, ^{
            [weakSelf updateDataSource];
        });
    });
}

- (void)updateDataSource {
    if (bounceLastUpdate) {
        [self throttleUpdateDataSource];
        bounceLastUpdate = NO;
        return;
    }

    for (id<ZaloContactEventListener> listener in listeners) {
        if ([listener respondsToSelector:@selector(onServerChangeWithAddSectionList:removeSectionList:addContact:removeContact:updateContact:newContactDict:newAccountDict:)]) {
            [listener onServerChangeWithAddSectionList:addSectionList.copy
                                     removeSectionList:removeSectionList.copy
                                            addContact:addSet.copy
                                         removeContact:removeSet.copy
                                         updateContact:updateSet.copy
                                        newContactDict:contactDictionary.copy
                                        newAccountDict:accountDictionary.copy];
        }
    }
    
    [self cleanUpUpdateData];
}

//clean up after all changed data is applied
- (void)cleanUpUpdateData {
    [addSet removeAllObjects];
    [removeSet removeAllObjects];
    [updateSet removeAllObjects];
    [removeSectionList removeAllObjects];
    [addSectionList removeAllObjects];
    [cacheContactDictionary removeAllObjects];
}

- (void)incomingAddWithContact:(ContactEntity*)contact {
    if ([removeSet containsObject:contact.accountId]) {
        [removeSet removeObject:contact.accountId];
        [self updateContact:contact];
    } else if ([updateSet containsObject:contact.accountId]) {
        [self updateContact:contact];
    } else {
        [addSet addObject:contact.accountId];
    }
}

- (void)incomingRemoveWithContact:(NSString*)accountId {
    if ([addSet containsObject:accountId]) {
        [addSet removeObject:accountId];
    } else if ([updateSet containsObject:accountId]) {
        [updateSet removeObject:accountId];
    }
    [removeSet addObject:accountId];
}


- (void)incomingUpdateWithContact:(ContactEntity*)contact {
    if ([addSet containsObject:contact.accountId]) {
        [self incomingAddWithContact:contact];
    } else if ([removeSet containsObject:contact.accountId]) {
        return;
    } else {
        [updateSet addObject:contact.accountId];
    }
}

- (void)incomingReorderWithContact:(ContactEntity*)contact {
    [removeSet addObject:contact.accountId];
    [addSet addObject:contact.accountId];
}

// if exist -> update. if not exist -> add
// return YES if add, NO if udpate
-(void) addContactToDataSource:(ContactEntity*)contact {
    // no section -> create new section
    if (![contactDictionary objectForKey:contact.header] || ![[contactDictionary objectForKey:contact.header] count]) {
        // not have a section -> add section
        [contactDictionary setObject:[[NSMutableArray alloc] initWithArray:@[contact]] forKey:contact.header];
        [accountDictionary setObject:contact forKey:contact.accountId];
        
        // move out side
        if ([removeSectionList containsObject:contact.header]) {
            [removeSectionList removeObject:contact.header];
        } else {
            [addSectionList addObject:contact.header];
        }
    } else {
        // has a section -> insert
        NSMutableArray<ContactEntity *> *sortedContactArray = [contactDictionary objectForKey:contact.header];
        NSUInteger insertIndex = [sortedContactArray indexOfObject:contact
                                                     inSortedRange:(NSRange){0, [sortedContactArray count]}
                                                           options:NSBinarySearchingInsertionIndex
                                                   usingComparator:^NSComparisonResult(ContactEntity *obj1, ContactEntity *obj2) {
            return [obj1 compare:obj2];
        }];
        [accountDictionary setObject:contact forKey:contact.accountId];
        [sortedContactArray insertObject:contact atIndex:insertIndex];
    }
    dispatch_async(self.contactServiceQueue, ^{
        [self didChange];
    });
}

// if not exist -> do nothing. if exist -> replace
- (void)updateContactInDataSource:(ContactEntity*)contact {
    // update the contact with the newest contact
    [accountDictionary setObject:contact forKey:contact.accountId];
    
    // no section -> can not update
    if (![contactDictionary objectForKey:contact.header]) return;
    
    NSMutableArray<ContactEntity *> *sortedContactArray = [contactDictionary objectForKey:contact.header];
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
    dispatch_async(self.contactServiceQueue, ^{
        [self didChange];
    });
    
}

// return YES if exist and deleted, return NO if not exist
- (BOOL)deleteContactInDataSource:(ContactEntity*)contact {
    [accountDictionary removeObjectForKey:contact.accountId];
    // no section -> return NO
    if (![contactDictionary objectForKey:contact.header]) return NO;
    NSMutableArray<ContactEntity *> *sortedContactArray = [contactDictionary objectForKey:contact.header];
    NSUInteger deleteIndex = [sortedContactArray indexOfObject:contact
                                                 inSortedRange:(NSRange){0, [sortedContactArray count]}
                                                       options:NSBinarySearchingFirstEqual
                                               usingComparator:^NSComparisonResult(ContactEntity *obj1, ContactEntity *obj2) {
        return [obj1 compare:obj2];
    }];
    // has section but not found -> return NO
    if (deleteIndex == NSNotFound) return NO;
    
    [[contactDictionary objectForKey:contact.header] removeObjectAtIndex:deleteIndex];
    
    // section become e mpty after delete -> remove section then YES
    if ([contactDictionary objectForKey:contact.header].count) {
        dispatch_async(self.contactServiceQueue, ^{
            [self didChange];
        });
        return YES;
    }
    [contactDictionary removeObjectForKey:contact.header];
    
    // move out side
    if ([addSectionList containsObject:contact.header]) {
        [addSectionList removeObject:contact.header];
    } else {
        [removeSectionList addObject:contact.header];
    }
    dispatch_async(self.contactServiceQueue, ^{
        [self didChange];
    });
    // delete success
    return YES;
}

#pragma mark online friends handler
- (void)throttleUpdateOnlineFriend {
    __weak typeof(self) weakSelf = self;
    dispatch_throttle_by_type(15, GCDThrottleTypeInvokeAndIgnore, ^{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0ul), ^{
            [weakSelf updateOnlineList];
        });
    });
}

- (void)updateOnlineList {
    for (OnlineContactEntity *contact in removeOnlineList) {
        if ([onlineList containsObject:contact]) [onlineList removeObject:contact];
    }
    
    for (OnlineContactEntity *contact in addOnlineList) {
        NSUInteger foundIndex = [onlineList indexOfObject:contact
                                            inSortedRange:(NSRange){0, [onlineList count]} options:NSBinarySearchingInsertionIndex usingComparator:^NSComparisonResult(OnlineContactEntity *obj1, OnlineContactEntity *obj2) {
            return [obj1 compareTime:obj2];
        }];
        
        if (foundIndex == NSNotFound) return;
        [onlineList insertObject:contact atIndex:foundIndex];
    }
    
    for (id<ZaloContactEventListener> listener in listeners) {
        if ([listener respondsToSelector:@selector(onServerChangeOnlineFriendsWithAddContact:removeContact:updateContact:)]) {
            [listener onServerChangeOnlineFriendsWithAddContact:addOnlineList.mutableCopy removeContact:removeOnlineList.mutableCopy updateContact:@[].mutableCopy];
        }
    }
    
    [removeOnlineList removeAllObjects];
    [addOnlineList removeAllObjects];

}

- (void)addOnlineContact:(ContactEntity *)contact {
    if ([addOnlineList containsObject:contact]) {
        [addOnlineList removeObject:contact];
    }
    [addOnlineList addObject:contact];
    [self throttleUpdateOnlineFriend];
}

- (void)removeOnlineContact:(ContactEntity *)contact {
    [addOnlineList addObject:contact];
    
    // server marked online then offline -> remove from online list
    if ([addOnlineList containsObject:contact]) {
        [addOnlineList removeObject:contact];
    }
    
    if (![removeOnlineList containsObject:contact]) {
        [removeOnlineList addObject:contact];
    }
    
    [self throttleUpdateOnlineFriend];
}

@end

// pragma mark - log for contact dict
//
//NSLog(@" add section : %@", addSectionList);
//NSLog(@" remove section : %@", removeSectionList);
//for (NSString *key in contactDictionary.keyEnumerator) {
//    NSLog(@" section : %@", key);
//    for (ContactEntity *contact in contactDictionary[key]) {
//        NSLog(@" %d : %@", count, contact.fullName);
//    }
//}
