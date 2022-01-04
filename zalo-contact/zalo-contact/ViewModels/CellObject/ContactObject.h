//
//  ContactObject.h
//  zalo-contact
//
//  Created by Thiện on 29/11/2021.
//

#import "CellObject.h"
#import "ContactEntity.h"
#import "ContactCell.h"
#import "SwipeActionObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface ContactObject : CellObject

@property ContactEntity *contact;

- (instancetype)initWithContactEntity:(ContactEntity *)contact;
- (BOOL)isEqual:(id)object;
- (NSComparisonResult)compare:(ContactObject *)object;

@end

NS_ASSUME_NONNULL_END
