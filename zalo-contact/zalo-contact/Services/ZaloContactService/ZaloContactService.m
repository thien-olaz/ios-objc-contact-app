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
    dispatch_queue_attr_t qos = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_USER_INITIATED, -1);
    _contactServiceStorageQueue = dispatch_queue_create("_contactServiceStorageQueue", qos);
    _apiServiceQueue = dispatch_queue_create("_apiServicesQueue", qos);

    
    self.bounceLastUpdate = NO;
    
    onlineList = [NSMutableArray new];
    self.addOnlineList = [NSMutableArray new];
    self.removeOnlineList = [NSMutableArray new];
    
    self.contactDictionary = [ContactMutableDictionary new];
    self.accountDictionary = [AccountMutableDictionary new];
    
    [self cacheChanges];
    
    self.footprintDict = [FootprintMutableDictionary new];
    [self setupInitData];
    
    return self;
}

- (void)deleteContactWithId:(NSString *)accountId {
    ContactEntity *contactToDelete = [self.oldAccountDictionary objectForKey:accountId];
    if (!contactToDelete) return;
    [self deleteContact:contactToDelete];
}

- (ContactMutableDictionary *)getContactDictCopy {
    NSMutableDictionary *returnDict = [NSMutableDictionary new];
    for (NSString *key in self.contactDictionary.keyEnumerator) {
        [returnDict setObject:self.contactDictionary[key].mutableCopy forKey:key];
    }
    return returnDict;
}

- (OnlineContactEntityMutableArray *)getOnlineContactList {
    return onlineList.copy;
}

- (AccountMutableDictionary*)getAccountDictCopy {
    return self.accountDictionary.mutableCopy;
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
