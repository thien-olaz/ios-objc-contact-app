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

@property AccountIdMutableOrderedSet *addSet;
@property AccountIdMutableOrderedSet *removeSet;
@property AccountIdMutableOrderedSet *updateSet;

@property id<APIServiceProtocol> apiService;
@property dispatch_queue_t contactServiceQueue;
@property dispatch_queue_t apiServiceQueue;

@property BOOL bounceLastUpdate;

@property ContactMutableDictionary *oldContactDictionary;
@property AccountMutableDictionary *oldAccountDictionary;
@property ContactMutableDictionary *contactDictionary;
@property AccountMutableDictionary *accountDictionary;

@property NSMutableArray<id<ZaloContactEventListener>> *listeners;

@end


NS_ASSUME_NONNULL_END
