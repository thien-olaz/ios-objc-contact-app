//
//  UserContacts.m
//  zalo-contact
//
//  Created by Thiện on 18/11/2021.
//

#import "UserContacts.h"
#import "ContactEntityAdapter.h"

@interface UserContacts ()
@property NSMutableArray<CNContact *> *contactList;
@property NSDictionary<NSString*, NSMutableArray<ContactEntity *>*> *contactDictionary;
@end

@implementation UserContacts
static UserContacts *sharedInstance = nil;

+ (UserContacts *)sharedInstance {
    @synchronized([UserContacts class]) {
        if (!sharedInstance)
            sharedInstance = [self new];
        return sharedInstance;
    }
    return nil;
}

- (instancetype)init {
    self = [super init];
    return self;
}

+ (void) checkAccessContactPermission:(PermissionCompletion)block {
    [CNContactStore.alloc.init
     requestAccessForEntityType:CNEntityTypeContacts
     completionHandler:
         ^(BOOL granted, NSError * _Nullable error) {
        block(granted);
    }];
}

// MARK: - check
- (void)fetchLocalContacts {
    _contactDictionary = [self getDeviceContactEntities];
}

- (NSMutableDictionary<NSString*, NSMutableArray<ContactEntity *>*>*)getDeviceContactEntities {
    //    NSDate *methodStart = [NSDate date];
    
    //    for(int i=1; i<2000; i++) {
    CNContactStore *ctstore = [[CNContactStore alloc] init];
    
    NSMutableDictionary<NSString*, NSMutableArray<ContactEntity *>*> *contactDictionary = [NSMutableDictionary dictionary];
    
    [ctstore requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (granted == YES) {
            
            NSArray *keys = @[CNContactNamePrefixKey, CNContactNameSuffixKey, CNContactFamilyNameKey, CNContactGivenNameKey, CNContactPhoneNumbersKey, CNContactImageDataKey];
            CNContactFetchRequest *request = [CNContactFetchRequest.alloc initWithKeysToFetch:keys];
            NSError *error;
            
            [request setSortOrder:CNContactsUserDefaults.sharedDefaults.sortOrder];
            
            [ctstore enumerateContactsWithFetchRequest:request
                                                 error:&error
                                            usingBlock:^(CNContact * __nonnull contact, BOOL * __nonnull stop) {
                if (error) {
                    NSLog(@"error fetching contacts %@", error);
                } else {
                    ContactEntityAdapter *contactEntity = [ContactEntityAdapter.alloc initWithCNContact:contact];
                    NSString *header = contactEntity.header;
                    NSMutableArray<ContactEntity *> *contacts = [contactDictionary objectForKey:header];
                    if (!contacts) {
                        [contactDictionary setObject:[NSMutableArray.alloc initWithArray:@[contactEntity]]  forKey: header];
                    } else {
                        [contacts addObject:contactEntity];
                        [contactDictionary setObject:contacts forKey: header];
                    }
                    
                    // NSLog(@"%@ , %@, %@, %@, %@", contact.familyName, contact.familyName, contact.givenName, ((CNLabeledValue<CNPhoneNumber*>*)contact.phoneNumbers[0]).value.stringValue);
                }
            }];
        }
    }];
    //    }
    //    NSLog(@"%@", contactDictionary.description);
    
    //    NSDate *methodFinish = [NSDate date];
    //    NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:methodStart];
    //    NSLog(@"new executionTime = %f", executionTime);
    //    return results;
    return contactDictionary;
}

//fetcch contact
- (NSArray<CNContact *> *)getContactList {
    if (!_contactList) {
        return @[];
    }
    return _contactList;
}

- (NSDictionary<NSString*, NSArray<ContactEntity*>*> *)getContactDictionary {
    if (_contactDictionary) {
        return _contactDictionary;
    }
    return [NSDictionary new];
    
}


@end
