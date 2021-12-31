//
//  ZaloContactService+Private.h
//  zalo-contact
//
//  Created by Thiện on 21/12/2021.
//

#import "ZaloContactService.h"

NS_ASSUME_NONNULL_BEGIN

#define LOG(str) NSLog(@"🌍 ZaloContactService : %@", str);
#define LOG2(str1, str2) NSLog(@"🌍 ZaloContactService : %@", [NSString stringWithFormat:str1, str2])
@interface ZaloContactService ()

@property id<APIServiceProtocol> apiService;
@property dispatch_queue_t contactServiceStorageQueue;
@property dispatch_queue_t apiServiceQueue;

@property BOOL bounceLastUpdate;

@property ContactMutableDictionary *oldContactDictionary;
@property AccountMutableDictionary *oldAccountDictionary;
@property ContactMutableDictionary *contactDictionary;
@property AccountMutableDictionary *accountDictionary;
@property FootprintMutableDictionary *footprintDict;
@property NSMutableArray<id<ZaloContactEventListener>> *listeners;


@property NSMutableArray<ContactEntity *> *addOnlineList;
@property NSMutableArray<ContactEntity *> *removeOnlineList;

@property dispatch_queue_t fetchDataqueue;
@property dispatch_block_t fetchDataBlock;

@end


NS_ASSUME_NONNULL_END
