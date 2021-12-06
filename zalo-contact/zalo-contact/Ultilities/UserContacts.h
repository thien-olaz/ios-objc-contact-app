//
//  UserContacts.h
//  zalo-contact
//
//  Created by Thiện on 18/11/2021.
//

#import <Foundation/Foundation.h>
@import Contacts;
#import "ContactEntity.h"
#import "ZaloContactService.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^PermissionCompletion) (BOOL);

@interface UserContacts : NSObject

+ (UserContacts *)sharedInstance;
+ (void)checkAccessContactPermission:(PermissionCompletion)block;

- (void)fetchLocalContacts;
- (NSArray<CNContact *> *)getContactList;
- (ContactDictionary *)getContactDictionary;

@end

NS_ASSUME_NONNULL_END
