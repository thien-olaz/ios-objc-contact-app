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

@interface ZaloContactService ()
@property NSLock *dataLock;
@end
@implementation ZaloContactService {
    NSMutableDictionary<NSString *,ContactEntity *> *cacheContactDictionary;
    NSMutableArray<ContactEntity *> *addList;
    NSMutableArray<ContactEntity *> *removeList;
    NSMutableArray<ContactEntity *> *updateList;
    NSMutableArray<NSString *> *addSectionList;
    NSMutableArray<NSString *> *removeSectionList;
    BOOL isLast;
}

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
    
    contactDictionaryLock = [NSLock new];
    accountDictionaryLock = [NSLock new];
    
    _apiService = [MockAPIService new];
    
    cacheContactDictionary = [NSMutableDictionary new];
    addList = [NSMutableArray new];
    removeList = [NSMutableArray new];
    updateList = [NSMutableArray new];
    addSectionList = [NSMutableArray new];
    removeSectionList = [NSMutableArray new];
    contactDictionary = [ContactDictionary new];
    isLast = NO;
    _dataLock = [NSLock new];
    
    
    
    _lastUpdateTime = [NSDate date];
    accountDictionary = [NSMutableDictionary new];
    
    // load saved data
    //    self performSelectorInBackground:<#(nonnull SEL)#> withObject:<#(nullable id)#>
    //    [self load];
    
    //setup server method
    [self setUp];
    
    //fetching data form server
    __weak typeof(self) weakSelf = self;
    [_apiService fetchContacts:^(NSArray<ContactEntity *> * contactsFromServer) {
        if (contactsFromServer.count <= 0) return;
        
        NSArray<ContactEntity *> *sortedArr = [ContactEntity insertionSort:contactsFromServer];
        
        [weakSelf didReceiveNewFullList:sortedArr];
    }];
    
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

//methods called from server
// load save tuần tự 1 thread
// save change thôi
- (void)setUp {
    __weak typeof(self) weakSelf = self;
    [_apiService setOnContactAdded:^(ContactEntity * newContact) {
        [weakSelf.dataLock lock];
        [weakSelf addcontact:newContact];
        [weakSelf.dataLock unlock];
    }];
    
    [_apiService setOnContactDeleted:^(NSString * phoneNumber) {
        [weakSelf.dataLock lock];
        [weakSelf removecontact:phoneNumber];
        [weakSelf.dataLock unlock];
    }];
    
    [_apiService setOnContactUpdated:^(ContactEntity * oldContact, ContactEntity * newContact) {
        [weakSelf updatecontact:newContact];
    }];
    
    [_apiService setOnContactUpdatedWithPhoneNumber:^(NSString * phoneNumber, ContactEntity * newContact) {
        [weakSelf didUpdateContactWihPhoneNumber:phoneNumber toContact:newContact];
    }];
}

- (void)addcontact:(ContactEntity*)contact {
    // nếu chưa có section thì tạo section
    // đẩy title vào section list
    // về sau nếu có contact nào được thêm vào cái section đó thì bỏ qua
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

- (void)throttleUpdateDataSource {

    __weak typeof(self) weakSelf = self;
    
    dispatch_throttle_by_type(4, GCDThrottleTypeInvokeAndIgnore, ^{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0ul), ^{
            [weakSelf updateDataSource];
        });
    });
}


- (void)updateDataSource {
    [contactDictionaryLock lock];
    [accountDictionaryLock lock];
    for (ContactEntity *contact in removeList) {
        if (![contactDictionary objectForKey:contact.header]) continue;
        [[contactDictionary objectForKey:contact.header] removeObject:contact];
        [accountDictionary removeObjectForKey:contact.phoneNumber];
        // delete section if no data
        //        dời hết removeList nếu section đó bị xoá
        if ([contactDictionary objectForKey:contact.header].count) continue;
        [contactDictionary removeObjectForKey:contact.header];
        [removeSectionList addObject:contact.header];
    }
    
    for (ContactEntity *contact in addList) {
        //add section if no data
        if (![contactDictionary objectForKey:contact.header]) {
            [contactDictionary setObject:[[NSMutableArray alloc] initWithArray:@[contact]] forKey:contact.header];
            [accountDictionary setObject:contact forKey:contact.phoneNumber];
            //        dời hết add nếu section đó được thêm vào
            if ([removeSectionList containsObject:contact.header]) {
                [removeSectionList removeObject:contact.header];
            } else {
                [addSectionList addObject:contact.header];
            }
            continue;
        }
        
        NSMutableArray<ContactEntity *> *sortedContactArray = [contactDictionary objectForKey:contact.header];
        NSUInteger insertIndex = [sortedContactArray indexOfObject:contact
                                                     inSortedRange:(NSRange){0, [sortedContactArray count]} options:NSBinarySearchingInsertionIndex usingComparator:^NSComparisonResult(ContactEntity *obj1, ContactEntity *obj2) {
            return [obj1 compare:obj2];
        }];
        [accountDictionary setObject:contact forKey:contact.phoneNumber];
        [sortedContactArray insertObject:contact atIndex:insertIndex];
        
    }
    
    for (ContactEntity *contact in updateList) {
        NSMutableArray<ContactEntity *> *sortedContactArray = [contactDictionary objectForKey:contact.header];
        if (!sortedContactArray) continue;
        NSUInteger foundIndex = [sortedContactArray indexOfObject:contact
                                                    inSortedRange:(NSRange){0, [sortedContactArray count]} options:NSBinarySearchingInsertionIndex usingComparator:^NSComparisonResult(ContactEntity *obj1, ContactEntity *obj2) {
            return [obj1 comparePhoneNumber:obj2];
        }];
        if (foundIndex == NSNotFound) continue;
        [accountDictionary setObject:contact forKey:contact.phoneNumber];
        [sortedContactArray replaceObjectAtIndex:foundIndex withObject:contact];
    }
    
    for (id<ZaloContactEventListener> listener in listeners) {
        if ([listener respondsToSelector:@selector(onServerChangeWithAddSectionList:removeSectionList:addContact:removeContact:updateContact:)]) {
            [listener onServerChangeWithAddSectionList:addSectionList removeSectionList:removeSectionList addContact:addList removeContact:removeList updateContact:updateList];
        }
    }
    
    // sau khi update, bắt đầu 1 chu kỳ update mới - set lại data
    [addList removeAllObjects];
    [removeList removeAllObjects];
    [updateList removeAllObjects];
    [removeSectionList removeAllObjects];
    [addSectionList removeAllObjects];
    [cacheContactDictionary removeAllObjects];
    [contactDictionaryLock unlock];
    [accountDictionaryLock unlock];

}

//methods called from local
- (void)deleteContactWithPhoneNumber:(NSString *)phoneNumber {
    [self removeContactWithoutThrottle:phoneNumber];
}

- (void)removeContactWithoutThrottle:(NSString*)phoneNumber {
    
    ContactEntity *removeContact = [accountDictionary objectForKey:phoneNumber];
    if (!removeContact) return;
    if (![contactDictionary objectForKey:removeContact.header]) return;
    
    [contactDictionaryLock lock];
    [accountDictionaryLock lock];
    
    [[contactDictionary objectForKey:removeContact.header] removeObject:removeContact];
    [accountDictionary removeObjectForKey:phoneNumber];
    
    NSMutableArray<NSString *> *removeSection = [NSMutableArray new];
    if (![contactDictionary objectForKey:removeContact.header].count) {
        [contactDictionary removeObjectForKey:removeContact.header];
        [removeSection addObject:removeContact.header];
    }
    
    for (id<ZaloContactEventListener> listener in listeners) {
        if ([listener respondsToSelector:@selector(onServerChangeWithAddSectionList:removeSectionList:addContact:removeContact:updateContact:)]) {
            [listener onServerChangeWithAddSectionList:@[].mutableCopy removeSectionList:removeSection addContact:@[].mutableCopy removeContact:@[removeContact].mutableCopy updateContact:@[].mutableCopy];
        }
    }
    
    [contactDictionaryLock unlock];
    [accountDictionaryLock unlock];
}

//MARK: - external use - immutable
- (ContactDictionary *)getFullContactDict {
    return contactDictionary.copy;
}

- (NSArray<ContactEntity *>*)getFullContactList {
    return [contactDictionary.allValues flatMap:^id(id obj) { return obj; }];
}

// Check if a friend with phone number exist
- (ContactEntity *)getContactsWithPhoneNumber:(NSString *)phoneNumber {
    return [accountDictionary objectForKey:phoneNumber];
}

- (BOOL)isFriendWithPhoneNumber:(NSString *)phoneNumber {
    return [accountDictionary objectForKey:phoneNumber] != nil;
}

@end
