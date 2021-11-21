//
//  UserContacts.h
//  zalo-contact
//
//  Created by Thiện on 18/11/2021.
//

#import <Foundation/Foundation.h>
@import Contacts;
NS_ASSUME_NONNULL_BEGIN

typedef void (^PermissionCompletion) (BOOL);

@interface UserContacts : NSObject

+(UserContacts *)sharedInstance;
+(void) checkAccessContactPermission:(PermissionCompletion)block;

-(void) fetchLocalContacts;
- (NSArray<CNContact *> *) getContactList;

@end

NS_ASSUME_NONNULL_END
