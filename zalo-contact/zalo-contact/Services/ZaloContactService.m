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
    
    contactDictionaryLock = [NSLock new];
    accountDictionaryLock = [NSLock new];
    
    _apiService = [MockAPIService new];
    
    contactDictionary = [ContactDictionary new];
    _lastUpdateTime = [NSDate date];
    accountDictionary = [NSMutableDictionary new];
    
    // load saved data
    [self load];
    
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
- (void)setUp {
    __weak typeof(self) weakSelf = self;
    [_apiService setOnContactAdded:^(ContactEntity * newContact) {
        [weakSelf didAddContact:newContact];
    }];
    
    [_apiService setOnContactDeleted:^(NSString * phoneNumber) {
        [weakSelf didDeleteContact:phoneNumber];
    }];
    
    [_apiService setOnContactUpdated:^(ContactEntity * oldContact, ContactEntity * newContact) {
        [weakSelf didUpdateContact:oldContact toContact:newContact];
    }];
    
    [_apiService setOnContactUpdatedWithPhoneNumber:^(NSString * phoneNumber, ContactEntity * newContact) {
        [weakSelf didUpdateContactWihPhoneNumber:phoneNumber toContact:newContact];
    }];
    
}


//methods called from local
- (void)deleteContactWithPhoneNumber:(NSString *)phoneNumber {
    [self didDeleteContact:phoneNumber];
}

- (ContactDictionary *)getFullContactDict {
    return contactDictionary;
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
