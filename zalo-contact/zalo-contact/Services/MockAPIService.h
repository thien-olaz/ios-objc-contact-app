//
//  APIService.h
//  zalo-contact
//
//  Created by Thiện on 06/12/2021.
//

#import <Foundation/Foundation.h>
#import "ContactEntity.h"
#import "OnlineContactEntity.h"
@import Contacts;
NS_ASSUME_NONNULL_BEGIN

typedef void (^OnData) (NSArray<ContactEntity *>*);
typedef void (^OnContactChangeBlock) (ContactEntity *);
typedef void (^OnContactDeleteBlock) (NSString *);
typedef void (^OnContactUpdateBlock) (ContactEntity *);
typedef void (^OnOnlineContactUpdateBlock) (OnlineContactEntity *);
typedef void (^OnContactUpdateWithPhoneNumberBLock) (NSString *, ContactEntity *);

@protocol APIServiceProtocol

@required

@property OnContactChangeBlock onContactAdded;
@property OnContactDeleteBlock onContactDeleted;
@property OnContactUpdateBlock onContactUpdated;
@property OnContactChangeBlock onOnlineContactAdded;
@property OnContactChangeBlock onOnlineContactDeleted;
@property OnContactChangeBlock onOnlineContactUpdate;
@property OnContactUpdateWithPhoneNumberBLock onContactUpdatedWithPhoneNumber;

- (void)getContactList;
- (void)fetchContacts:(OnData)block;
- (NSArray<CNContact *>*)getDataFromFile:(NSString *)fileName;

@end

@interface MockAPIService : NSObject<APIServiceProtocol>

- (void)fakeServerUpdate;

@end

NS_ASSUME_NONNULL_END
