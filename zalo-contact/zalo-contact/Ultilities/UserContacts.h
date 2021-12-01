//
//  UserContacts.h
//  zalo-contact
//
//  Created by Thiện on 18/11/2021.
//

#import <Foundation/Foundation.h>
@import Contacts;
#import "ContactEntity.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^PermissionCompletion) (BOOL);

@interface UserContacts : NSObject

+ (UserContacts *)sharedInstance;
+ (void)checkAccessContactPermission:(PermissionCompletion)block;

- (void)fetchLocalContacts;
- (NSArray<CNContact *> *)getContactList;
- (NSDictionary<NSString*, NSMutableArray<ContactEntity*>*> *)getContactDictionary;

@end

NS_ASSUME_NONNULL_END
