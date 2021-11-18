//
//  UserContacts.h
//  zalo-contact
//
//  Created by Thiện on 18/11/2021.
//

#import <Foundation/Foundation.h>
@import Contacts;
NS_ASSUME_NONNULL_BEGIN

@interface UserContacts : NSObject

+(UserContacts *)sharedInstance;
+(void) checkAccessContactPermission;

-(void) fetchLocalContacts;
- (NSArray<CNContact *> *) getContactList;

@end

NS_ASSUME_NONNULL_END
