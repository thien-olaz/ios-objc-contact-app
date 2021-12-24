//
//  CoreDataContactEntityAdapter.h
//  zalo-contact
//
//  Created by Thiện on 24/12/2021.
//

#import <Foundation/Foundation.h>
#import "ContactEntity.h"
#import "Contact+CoreDataClass.h"
NS_ASSUME_NONNULL_BEGIN

@interface CoreDataContactEntityAdapter : ContactEntity

- (id)initWithContact:(Contact *)contact;

@end

NS_ASSUME_NONNULL_END
