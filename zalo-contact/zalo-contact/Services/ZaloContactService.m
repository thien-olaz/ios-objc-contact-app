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
    AccountIdMutableSet *addSet;
    AccountIdMutableSet *removeSet;
    AccountIdMutableSet *updateSet;
    
    NSMutableArray<ContactEntity *> *addOnlineList;
    NSMutableArray<ContactEntity *> *removeOnlineList;
}
@property id<APIServiceProtocol> apiService;

@property dispatch_queue_t contactServiceQueue;
@property dispatch_queue_t apiServicesQueue;

@property BOOL bounceLastUpdate;

@property ContactMutableDictionary *oldContactDictionary;
@property AccountMutableDictionary *oldAccountDictionary;

@property ContactMutableDictionary *contactDictionary;
@property AccountMutableDictionary *accountDictionary;

@property NSMutableArray<id<ZaloContactEventListener>> *listeners;
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
    
    self.apiService = [MockAPIService new];
    
    addSet = [AccountIdMutableSet new];
    removeSet = [AccountIdMutableSet new];
    updateSet = [AccountIdMutableSet new];
    
    
    self.contactDictionary = [ContactMutableDictionary new];
    self.bounceLastUpdate = NO;
    
    onlineList = [NSMutableArray new];
    addOnlineList = [NSMutableArray new];
    removeOnlineList = [NSMutableArray new];
    
    
    self.accountDictionary = [AccountMutableDictionary new];
    
    dispatch_queue_attr_t qos = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_USER_INITIATED, -1);
    _contactServiceQueue = dispatch_queue_create("_contactServiceQueue", qos);
    _apiServicesQueue = dispatch_queue_create("_apiServicesQueue", qos);
    
    dispatch_async(self.contactServiceQueue, ^{
//        if ([self.accountDictionary count]) return;
//        ContactMutableDictionary *loadContact = [self loadContactDictionary];
//        AccountMutableDictionary *loadAccount = [self loadAccountDictionary];
//        if (!loadContact || !loadAccount || ![loadContact count] || ![loadAccount count]) return;
//        dispatch_async(self.apiServicesQueue, ^{
//            self.contactDictionary = loadContact;
//            self.accountDictionary = loadAccount;
//            for (id<ZaloContactEventListener> listener in self.listeners) {
//                if ([listener respondsToSelector:@selector(onLoadSavedDataCompleteWithContact:andAccount:)]) {
//                    [listener onLoadSavedDataCompleteWithContact:self.contactDictionary.mutableCopy andAccount:self.accountDictionary.mutableCopy];
//                }
//            }
//        });
    });
    [self setUp];
    //fetching data form server
    
    //    __weak typeof(self) weakSelf = self;
    
    //    [_apiService fetchContacts:^(NSArray<ContactEntity *> * contactsFromServer) {
    //        if (contactsFromServer.count <= 0) return;
    //
    //        NSArray<ContactEntity *> *sortedArr = [ContactEntity insertionSort:contactsFromServer];
    //
    //        [weakSelf didReceiveNewFullList:sortedArr];
    //    }];
    
    return self;
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
    if (![self.accountDictionary objectForKey:contact.accountId]) {
        [self addContact:contact toContactDict:self.contactDictionary andAccountDict:self.accountDictionary];
        [self incommingAddWithContact:contact];
    } else {
        [self updateContactInDataSource:contact];
        [self incommingUpdateWithContact:contact];
    }
    [self throttleUpdateDataSource];
}

- (void)removeContact:(NSString*)accountId {
    ContactEntity *contact = [self.accountDictionary objectForKey:accountId];
    // if exist -> remove
    if (!contact) return;
    // if delete sucess
    if ([self deleteContact:contact inContactDict:self.contactDictionary andAccountDict:self.accountDictionary]) {
        [self incommingRemoveWithContact:contact];
        [self throttleUpdateDataSource];
    }
}

- (void)updateContact:(ContactEntity*)contact {
    //    if exist -> remove
    ContactEntity *oldContact = [self.accountDictionary objectForKey:contact.accountId];
    if (!oldContact) return;
    
    [self updateContactInDataSource:contact];
    // not change first name - last name - or phone number - affect order in list
    if ([oldContact compare:contact] == NSOrderedSame) {
        [self incommingUpdateWithContact:contact];
    } else {
        [self deleteContact:oldContact inContactDict:self.contactDictionary andAccountDict:self.accountDictionary];
        [self addContact:contact toContactDict:self.contactDictionary andAccountDict:self.accountDictionary];
        [self incommingReorderWithContact:contact];
    }
    
    [self throttleUpdateDataSource];
}

- (void)deleteContactWithId:(NSString *)accountId {
    ContactEntity *contact = [self.oldAccountDictionary objectForKey:accountId];
    if (!contact) return;
    
    dispatch_async(self.apiServicesQueue, ^{
        
        if ([self deleteContact:contact inContactDict:self.oldContactDictionary andAccountDict:self.oldAccountDictionary]) {
            
            ContactEntity *curContact = [self.accountDictionary objectForKey:accountId];
            if (curContact) {
                [self deleteContact:curContact inContactDict:self.contactDictionary andAccountDict:self.accountDictionary];
                [self->addSet removeObject:accountId];
                [self->removeSet removeObject:accountId];
                [self->updateSet removeObject:accountId];
            }
            
            NSMutableArray *removeSection = [NSMutableArray new];
            if (![self.oldContactDictionary objectForKey:contact.header]) {
                [removeSection addObject:contact.header];
            }
            
            [self notifyListenerWithAddSectionList:@[] removeSectionList:removeSection.copy addContact:[NSSet new]  removeContact:[NSSet setWithArray:@[accountId]] updateContact:[NSSet new] newContactDict:self.oldContactDictionary.copy newAccountDict:self.oldAccountDictionary.copy];
            self.bounceLastUpdate = YES;
            
        }
    });
}

- (ContactMutableDictionary *)getFullContactDict {
    return self.contactDictionary.copy;
}

- (OnlineContactEntityMutableArray *)getOnlineContactList {
    return onlineList.copy;
}

- (NSArray<ContactEntity *>*)getAccountList {
    return self.accountDictionary.copy;
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
    
    [self notifyListenerWithAddSectionList:addHeaderSet.copy removeSectionList:removeHeaderSet.copy addContact:addSet.copy removeContact:removeSet.copy updateContact:updateSet.copy newContactDict:self.contactDictionary.copy newAccountDict:self.accountDictionary.copy];
    
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

- (void)notifyListenerWithAddSectionList:(NSArray *)addSections
                       removeSectionList:(NSArray *)removeSections
                              addContact:(NSSet *)addContacts
                           removeContact:(NSSet *)removeContacts
                           updateContact:(NSSet *)updateContacts
                          newContactDict:(NSDictionary *)contactDict
                          newAccountDict:(NSDictionary *)accountDict {
    
    for (id<ZaloContactEventListener> listener in self.listeners) {
        if ([listener respondsToSelector:@selector(onServerChangeWithAddSectionList:removeSectionList:addContact:removeContact:updateContact:newContactDict:newAccountDict:)]) {
            [listener onServerChangeWithAddSectionList:addSections.copy
                                     removeSectionList:removeSections.copy
                                            addContact:addContacts.copy
                                         removeContact:removeContacts.copy
                                         updateContact:updateContacts.copy
                                        newContactDict:contactDict.copy
                                        newAccountDict:accountDict.copy];
        }
    }
}

- (void)incommingAddWithContact:(ContactEntity*)contact {
    if ([removeSet containsObject:contact.accountId]) {
        [removeSet removeObject:contact.accountId];
        [self updateContact:contact];
    } else if ([updateSet containsObject:contact.accountId]) {
        [self updateContact:contact];
    } else {
        [addSet addObject:contact.accountId];
    }
}

- (void)incommingRemoveWithContact:(ContactEntity*)contact {
    if ([addSet containsObject:contact.accountId]) {
        [addSet removeObject:contact.accountId];
    } else if ([updateSet containsObject:contact.accountId]) {
        [updateSet removeObject:contact.accountId];
    }
    [removeSet addObject:contact.accountId];
}


- (void)incommingUpdateWithContact:(ContactEntity*)contact {
    if ([addSet containsObject:contact.accountId]) {
        [self incommingAddWithContact:contact];
    } else if ([removeSet containsObject:contact.accountId]) {
        return;
    } else {
        [updateSet addObject:contact.accountId];
    }
}

- (void)incommingReorderWithContact:(ContactEntity*)contact {
    [removeSet addObject:contact.accountId];
    [addSet addObject:contact.accountId];
}
//clean up after all changed data is applied
- (void)cleanUpIncommingData {
    [addSet removeAllObjects];
    [removeSet removeAllObjects];
    [updateSet removeAllObjects];
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

- (void)saveLatestChanges {
    dispatch_async(self.contactServiceQueue, ^{
        NSMutableDictionary* saveContact = [NSMutableDictionary new];
        for (NSString *key in self.contactDictionary.keyEnumerator) {
            [saveContact setObject:self.contactDictionary[key].mutableCopy forKey:key];
        }
        NSMutableDictionary *saveAccount = self.accountDictionary.mutableCopy;
        [self didChangeWithContactDict:saveContact.mutableCopy andAccountDict:saveAccount];
    });
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
    
    for (id<ZaloContactEventListener> listener in self.listeners) {
        if ([listener respondsToSelector:@selector(onServerChangeOnlineFriendsWithAddContact:removeContact:updateContact:)]) {
            [listener onServerChangeOnlineFriendsWithAddContact:addOnlineList.mutableCopy removeContact:removeOnlineList.mutableCopy updateContact:@[].mutableCopy];
        }
    }
    
    [removeOnlineList removeAllObjects];
    [addOnlineList removeAllObjects];
    
}

- (void)fetchLocalContact {
    [UserContacts.sharedInstance fetchLocalContacts];
    //    self.contactDictionary = [ContactEntity mergeContactDict:UserContacts.sharedInstance.getContactDictionary toDict:self.contactDictionary];
    
    //    for (NSArray<ContactEntity *> *contacts in [self.contactDictionary allValues]) {
    //        for (ContactEntity *contact in contacts) [self.accountDictionary setObject:contact forKey:contact.phoneNumber.copy];
    //    }
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
