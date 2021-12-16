//
//  OnlineContactObject.h
//  zalo-contact
//
//  Created by Thiện on 15/12/2021.
//

#import "CellObject.h"
#import "OnlineContactEntity.h"
NS_ASSUME_NONNULL_BEGIN

@interface OnlineContactObject : CellObject

@property OnlineContactEntity *contact;

- (instancetype)initWithContactEntity:(OnlineContactEntity *)contact;
- (BOOL)isEqual:(id)object;

- (NSComparisonResult)compare:(OnlineContactObject *)object;
- (NSComparisonResult)revertCompare:(OnlineContactObject *)object;

@end

NS_ASSUME_NONNULL_END
