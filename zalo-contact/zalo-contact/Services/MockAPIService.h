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

typedef void (^OnContactChangeBlock) (ContactEntity *);
typedef void (^OnContactUpdateBlock) (ContactEntity *, ContactEntity *);

@protocol APIServiceProtocol

@required

@property OnContactChangeBlock onContactAdded;
@property OnContactChangeBlock onContactDeleted;
@property OnContactUpdateBlock onContactUpdated;

- (void)getContactList;
- (void)fakeServerUpdate;

//- (void)contactChanged;
//- (void)contactDeleted;
//- (void)contactAdded;

@end

@interface MockAPIService : NSObject<APIServiceProtocol>

@end

NS_ASSUME_NONNULL_END
