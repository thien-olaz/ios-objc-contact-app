//
//  NSArrayExt.h
//  zalo-contact
//
//  Created by Thiện on 07/12/2021.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSArray (Common)

- (NSArray *)flatMap:(id (^)(id obj))block;

@end

NS_ASSUME_NONNULL_END
