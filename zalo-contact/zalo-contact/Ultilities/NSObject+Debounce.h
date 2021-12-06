//
//  NSObject+Debounce.h
//  zalo-contact
//
//  Created by Thiện on 06/12/2021.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (Debounce)

- (void)debounce:(SEL)action delay:(NSTimeInterval)delay;

@end
NS_ASSUME_NONNULL_END
