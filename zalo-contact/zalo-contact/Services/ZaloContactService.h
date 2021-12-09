//
//  ZaloContactService.h
//  zalo-contact
//
//  Created by Thiện on 06/12/2021.
//

#import <Foundation/Foundation.h>
#import "MockAPIService.h"
NS_ASSUME_NONNULL_BEGIN

typedef NSMutableDictionary<NSString *, NSArray<ContactEntity *>*> ContactDictionary;

@protocol ZaloContactEventListener <NSObject>

- (void)onReceiveNewList;
- (void)onAddContact:(ContactEntity *)contact;
- (void)onDeleteContact:(ContactEntity *)contact;
- (void)onUpdateContact:(ContactEntity *)contact toContact:(ContactEntity *)newContact;
@end

@interface ZaloContactService : NSObject

@property id<APIServiceProtocol> apiService;
@property ContactDictionary *contactDictionary;

+ (ZaloContactService *)sharedInstance;
- (ContactDictionary *)getFullContactDict;
- (NSArray<ContactEntity *>*)getFullContactList;
- (void)fetchLocalContact;
- (ContactEntity *)getContactsWithPhoneNumber:(NSString *)phoneNumber;
//MARK: Observer functions
- (void)subcribe:(id<ZaloContactEventListener>)listener;
- (void)unsubcribe:(id<ZaloContactEventListener>)listener;
- (void)didAddContact:(ContactEntity *)contact;
- (void)deleteContactWithPhoneNumber:(NSString *)phoneNumber;

@end

NS_ASSUME_NONNULL_END
