//
//  NSObject+Debounce.m
//  zalo-contact
//
//  Created by Thiện on 06/12/2021.
//

#import "NSObject+Debounce.h"

@implementation NSObject (Debounce)

- (void)debounce:(SEL)action delay:(NSTimeInterval)delay
{
  __weak typeof(self) weakSelf = self;
  [NSObject cancelPreviousPerformRequestsWithTarget:weakSelf selector:action object:nil];
  [weakSelf performSelector:action withObject:nil afterDelay:delay];
}

@end
