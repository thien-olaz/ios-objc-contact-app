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

- (void)onAddContact:(ContactEntity *)contact;
- (void)onDeleteContact:(ContactEntity *)contact;

@end

@interface ZaloContactService : NSObject

@property id<APIServiceProtocol> apiService;
@property ContactDictionary *contactDictionary;

+ (ZaloContactService *)sharedInstance;
- (ContactDictionary *)getFullContactDict;
- (NSArray<ContactEntity *>*)getFullContactList;

//MARK: Observer functions
- (void)didAddContact:(ContactEntity *)contact;
- (void)didDeleteContact:(ContactEntity *)contact;
- (void)subcribe:(id<ZaloContactEventListener>)listener;
- (void)unsubcribe:(id<ZaloContactEventListener>)listener;
@end

NS_ASSUME_NONNULL_END
