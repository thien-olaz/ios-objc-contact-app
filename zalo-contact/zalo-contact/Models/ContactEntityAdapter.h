//
//  ContactAdapter.h
//  zalo-contact
//
//  Created by Thiện on 17/11/2021.
//

#import <Foundation/Foundation.h>
#import "ContactEntity.h"
@import Contacts;
NS_ASSUME_NONNULL_BEGIN

@interface ContactEntityAdapter : ContactEntity

- (id)initWithCNContact:(CNContact *)contact;

@end

NS_ASSUME_NONNULL_END
