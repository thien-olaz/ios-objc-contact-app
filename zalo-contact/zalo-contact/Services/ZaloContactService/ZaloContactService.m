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
#import "ZaloContactService+API.h"
#import "ZaloContactService+ChangeHandle.h"
#import "ZaloContactService+Private.h"
#import "GCDThrottle.h"

//MARK: - Usage
/*
 User for external and internal use
 */

@interface ZaloContactService () {
    NSMutableArray<ContactEntity *> *addOnlineList;
    NSMutableArray<ContactEntity *> *removeOnlineList;
}

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
    
    self.addSet = [AccountIdMutableOrderedSet new];
    self.removeSet = [AccountIdMutableOrderedSet new];
    self.updateSet = [AccountIdMutableOrderedSet new];
    
    self.contactDictionary = [ContactMutableDictionary new];
    self.bounceLastUpdate = NO;
    
    onlineList = [NSMutableArray new];
    addOnlineList = [NSMutableArray new];
    removeOnlineList = [NSMutableArray new];
    
    self.accountDictionary = [AccountMutableDictionary new];
    
    dispatch_queue_attr_t qos = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_USER_INITIATED, -1);
    _contactServiceQueue = dispatch_queue_create("_contactServiceQueue", qos);
    _apiServiceQueue = dispatch_queue_create("_apiServicesQueue", qos);
    
    [self setupInitData];
    
    return self;
}

- (void)deleteContactWithId:(NSString *)accountId {
    ContactEntity *contact = [self.oldAccountDictionary objectForKey:accountId];
    if (!contact) return;
    
    dispatch_async(self.apiServiceQueue, ^{
        if ([self deleteContact:contact inContactDict:self.oldContactDictionary andAccountDict:self.oldAccountDictionary]) {
            ContactEntity *curContact = [self.accountDictionary objectForKey:accountId];
            ChangeFootprint *footprint = [ChangeFootprint initChangeBy:accountId];
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
            
            [self notifyListenerWithAddSectionList:@[] removeSectionList:removeSection.copy addContact:[NSSet new]  removeContact:[NSSet setWithArray:@[footprint]] updateContact:[NSSet new] newContactDict:self.oldContactDictionary.copy newAccountDict:self.oldAccountDictionary.copy];
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
