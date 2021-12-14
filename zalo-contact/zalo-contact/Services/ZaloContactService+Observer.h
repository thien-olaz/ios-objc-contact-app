//
//  ZaloContactService+Observer.h
//  zalo-contact
//
//  Created by Thiện on 10/12/2021.
//

#import "CellObject.h"
#import "ZaloContactService.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZaloContactService (Observer)

- (void)subcribe:(id<ZaloContactEventListener>)listener;
- (void)unsubcribe:(id<ZaloContactEventListener>)listener;

- (void)didReceiveNewFullList:(NSArray<ContactEntity *>*)sortedArray;

@end

NS_ASSUME_NONNULL_END
