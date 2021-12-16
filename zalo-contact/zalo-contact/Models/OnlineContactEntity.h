//
//  OnlineContactEntity.h
//  zalo-contact
//
//  Created by Thiện on 15/12/2021.
//

#import "ContactEntity.h"

NS_ASSUME_NONNULL_BEGIN

@interface OnlineContactEntity : ContactEntity

@property NSDate *onlineTime;
- (NSComparisonResult)compareTime:(OnlineContactEntity *)entity;

@end

NS_ASSUME_NONNULL_END
