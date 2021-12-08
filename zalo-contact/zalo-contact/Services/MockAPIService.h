//
//  APIService.h
//  zalo-contact
//
//  Created by Thiện on 06/12/2021.
//

#import <Foundation/Foundation.h>
#import "ContactEntity.h"
@import Contacts;
NS_ASSUME_NONNULL_BEGIN

typedef void (^OnData) (NSArray<ContactEntity *>*);
typedef void (^OnContactChangeBlock) (ContactEntity *);
typedef void (^OnContactUpdateBlock) (ContactEntity *, ContactEntity *);
typedef void (^OnContactUpdateWithPhoneNumberBLock) (NSString *, ContactEntity *);

@protocol APIServiceProtocol

@required

@property OnContactChangeBlock onContactAdded;
@property OnContactChangeBlock onContactDeleted;
@property OnContactUpdateBlock onContactUpdated;
@property OnContactUpdateWithPhoneNumberBLock onContactUpdatedWithPhoneNumber;

- (void)getContactList;
- (void)fetchContacts:(OnData)block;
//- (void)contactChanged;
//- (void)contactDeleted;
//- (void)contactAdded;

@end

@interface MockAPIService : NSObject<APIServiceProtocol>

- (void)fakeServerUpdate;

@end

NS_ASSUME_NONNULL_END
