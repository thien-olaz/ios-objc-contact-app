//
//  ZaloContactService+API.h
//  zalo-contact
//
//  Created by Thiện on 21/12/2021.
//

#import "ZaloContactService.h"
#import "ZaloContactService+Private.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZaloContactService ()
@property NSDate *checkDate;
@end

@interface ZaloContactService (API)
- (void)setupInitData;
@end

NS_ASSUME_NONNULL_END
