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
NSString * const MTFooNotification = @"ZaloContactServiceThrottlingNotification";

@interface ZaloContactService () {
    NSMutableDictionary<NSString *,ContactEntity *> *cacheContactDictionary;
    NSMutableArray<ContactEntity *> *addList;
    NSMutableArray<ContactEntity *> *removeList;
    NSMutableArray<ContactEntity *> *updateList;
    NSMutableArray<NSString *> *addSectionList;
    NSMutableArray<NSString *> *removeSectionList;
    BOOL bounceLastUpdate;
}
@property dispatch_queue_t contactServiceQueue;
@property NSLock *dataLock;

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
    
    serviceLock = [NSLock new];
    
    _apiService = [MockAPIService new];
    
    cacheContactDictionary = [NSMutableDictionary new];
    addList = [NSMutableArray new];
    removeList = [NSMutableArray new];
    updateList = [NSMutableArray new];
    addSectionList = [NSMutableArray new];
    removeSectionList = [NSMutableArray new];
    contactDictionary = [ContactDictionary new];
    bounceLastUpdate = NO;
    _dataLock = [NSLock new];
    
    accountDictionary = [NSMutableDictionary new];
    dispatch_queue_attr_t qos = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_USER_INITIATED, -1);    
    _contactServiceQueue = dispatch_queue_create("downLoadAGroupPhoto", qos);
        
    
    dispatch_async(self.contactServiceQueue, ^{
        [self load];
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
        ZaloContactService *strongSelf = weakSelf;
        [strongSelf.dataLock lock];
        [strongSelf addcontact:newContact];
        [strongSelf.dataLock unlock];
    }];
    
    [_apiService setOnContactDeleted:^(NSString * phoneNumber) {
        ZaloContactService *strongSelf = weakSelf;
        [strongSelf.dataLock lock];
        [strongSelf removecontact:phoneNumber];
        [strongSelf.dataLock unlock];
    }];
    
    [_apiService setOnContactUpdated:^(ContactEntity * newContact) {
        ZaloContactService *strongSelf = weakSelf;
        [strongSelf.dataLock lock];
        [strongSelf updatecontact:newContact];
        [strongSelf.dataLock unlock];
    }];
}

//methods called from local
- (void)deleteContactWithPhoneNumber:(NSString *)phoneNumber {
    [serviceLock lock];
    [self.dataLock lock];
    [self removeContactWithoutThrottle:phoneNumber];
    [self.dataLock unlock];
    [serviceLock unlock];
}

- (ContactDictionary *)getFullContactDict {
    return contactDictionary.copy;
}

- (NSArray<ContactEntity *>*)getFullContactList {
    return accountDictionary.allValues;
}


- (ContactEntity *)getContactsWithPhoneNumber:(NSString *)phoneNumber {
    return [accountDictionary objectForKey:phoneNumber];
}

- (BOOL)isFriendWithPhoneNumber:(NSString *)phoneNumber {
    return [accountDictionary objectForKey:phoneNumber] != nil;
}

#pragma mark - udpate data handler

- (void)throttleUpdateDataSource {
    __weak typeof(self) weakSelf = self;
    dispatch_throttle_by_type(4, GCDThrottleTypeInvokeAndIgnore, ^{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0ul), ^{
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
    [serviceLock lock];
    
    [self applyRemoveList:removeList];
    [self applyAddList:addList];
    [self applyUpdateList:updateList];
    
    dispatch_async(self.contactServiceQueue, ^{
        [self didChange];
    });
    
    for (id<ZaloContactEventListener> listener in listeners) {
        if ([listener respondsToSelector:@selector(onServerChangeWithAddSectionList:removeSectionList:addContact:removeContact:updateContact:)]) {
            [listener onServerChangeWithAddSectionList:addSectionList removeSectionList:removeSectionList addContact:addList removeContact:removeList updateContact:updateList];
        }
    }
    
    [self cleanUpUpdateData];
    [serviceLock unlock];
}

- (void)addcontact:(ContactEntity*)contact {
    // existed -> return
    if ([accountDictionary objectForKey:contact.phoneNumber]) {
        [updateList addObject:contact];
    // will remove -> update
    } else
        if ([removeList containsObject:contact]) {
        [removeList removeObject:contact];
        [updateList addObject:contact];
    } else {
        [addList addObject:contact];
        [cacheContactDictionary setObject:contact forKey:contact.phoneNumber];
    }
    [self throttleUpdateDataSource];
}

- (void)removecontact:(NSString*)phoneNumber {
    if ([cacheContactDictionary objectForKey:phoneNumber]) {
        [addList removeObject:[cacheContactDictionary objectForKey:phoneNumber]];
        [cacheContactDictionary removeObjectForKey:phoneNumber];
    } else if ([accountDictionary objectForKey:phoneNumber]){
        [removeList addObject:[accountDictionary objectForKey:phoneNumber]];
    } else {
        return;
    }
    [self throttleUpdateDataSource];
}

- (void)updatecontact:(ContactEntity*)contact {
    if ([removeList containsObject:contact]) {
        [removeList removeObject:contact];
        [updateList addObject:contact];
    } else {
        [updateList addObject:contact];
    }
    [self throttleUpdateDataSource];
}

-(void)applyRemoveList:(NSArray<ContactEntity *>*)list {
    for (ContactEntity *contact in list) {
        if (![contactDictionary objectForKey:contact.header]) continue;
        [[contactDictionary objectForKey:contact.header] removeObject:contact];
        [accountDictionary removeObjectForKey:contact.phoneNumber];
        
        if ([contactDictionary objectForKey:contact.header].count) continue;
        [contactDictionary removeObjectForKey:contact.header];
        
        [removeSectionList addObject:contact.header];
    }
}

-(void)applyAddList:(NSArray<ContactEntity *>*)list {
    for (ContactEntity *contact in list) {
        if (![contactDictionary objectForKey:contact.header]) {
            [contactDictionary setObject:[[NSMutableArray alloc] initWithArray:@[contact]] forKey:contact.header];
            [accountDictionary setObject:contact forKey:contact.phoneNumber];
            
            if ([removeSectionList containsObject:contact.header]) {
                [removeSectionList removeObject:contact.header];
            } else {
                [addSectionList addObject:contact.header];
            }
            
        } else {
            NSMutableArray<ContactEntity *> *sortedContactArray = [contactDictionary objectForKey:contact.header];
            NSUInteger insertIndex = [sortedContactArray indexOfObject:contact
                                                         inSortedRange:(NSRange){0, [sortedContactArray count]} options:NSBinarySearchingInsertionIndex usingComparator:^NSComparisonResult(ContactEntity *obj1, ContactEntity *obj2) {
                return [obj1 compare:obj2];
            }];
            [accountDictionary setObject:contact forKey:contact.phoneNumber];
            [sortedContactArray insertObject:contact atIndex:insertIndex];
        }
    }
}

- (void)applyUpdateList:(NSArray<ContactEntity *>*)list {
    for (ContactEntity *contact in list) {
        NSMutableArray<ContactEntity *> *sortedContactArray = [contactDictionary objectForKey:contact.header];
        if (!sortedContactArray) continue;
        NSUInteger foundIndex = [sortedContactArray indexOfObject:contact
                                                    inSortedRange:(NSRange){0, [sortedContactArray count]} options:NSBinarySearchingFirstEqual usingComparator:^NSComparisonResult(ContactEntity *obj1, ContactEntity *obj2) {
            return [obj1 comparePhoneNumber:obj2];
        }];
        if (foundIndex == NSNotFound) continue;
        [accountDictionary setObject:contact forKey:contact.phoneNumber];
        [sortedContactArray replaceObjectAtIndex:foundIndex withObject:contact];
    }
}

//clean up after all changed data is applied
- (void)cleanUpUpdateData {
    [addList removeAllObjects];
    [removeList removeAllObjects];
    [updateList removeAllObjects];
    [removeSectionList removeAllObjects];
    [addSectionList removeAllObjects];
    [cacheContactDictionary removeAllObjects];
}

- (void)removeContactWithoutThrottle:(NSString*)phoneNumber {
    ContactEntity *removeContact = [accountDictionary objectForKey:phoneNumber];
    if (!removeContact) return;
    
    [accountDictionary removeObjectForKey:phoneNumber];
    
    if (![contactDictionary objectForKey:removeContact.header]) return;

    [[contactDictionary objectForKey:removeContact.header] removeObject:removeContact];

    NSMutableArray<NSString *> *removeSection = [NSMutableArray new];
    if (![contactDictionary objectForKey:removeContact.header].count) {
        [contactDictionary removeObjectForKey:removeContact.header];
        [removeSection addObject:removeContact.header];
    }
        
    dispatch_async(self.contactServiceQueue, ^{
        [self didChange];
    });
        
    for (id<ZaloContactEventListener> listener in listeners) {
        if ([listener respondsToSelector:@selector(onServerChangeWithAddSectionList:removeSectionList:addContact:removeContact:updateContact:)]) {
            [listener onServerChangeWithAddSectionList:@[].mutableCopy removeSectionList:removeSection addContact:@[].mutableCopy removeContact:@[removeContact].mutableCopy updateContact:@[].mutableCopy];
        }
    }
        
    bounceLastUpdate = YES;
    
}

@end
