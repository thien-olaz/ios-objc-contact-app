//
//  ContactObject.h
//  zalo-contact
//
//  Created by Thiện on 29/11/2021.
//

#import "CellObject.h"
#import "ContactEntity.h"
#import "ContactCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface ContactObject : CellObject

@property ContactEntity *contact;

- (instancetype)initWithContactEntity:(ContactEntity *)contact;

@end

NS_ASSUME_NONNULL_END
