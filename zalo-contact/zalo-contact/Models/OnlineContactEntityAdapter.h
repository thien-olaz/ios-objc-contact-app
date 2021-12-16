//
//  OnlineContactEntityAdapter.h
//  zalo-contact
//
//  Created by Thiện on 15/12/2021.
//

#import <Foundation/Foundation.h>
#import "OnlineContactEntity.h"
@import Contacts;

NS_ASSUME_NONNULL_BEGIN

@interface OnlineContactEntityAdapter : OnlineContactEntity

- (id)initWithCNContact:(CNContact *)contact;

@end

NS_ASSUME_NONNULL_END
