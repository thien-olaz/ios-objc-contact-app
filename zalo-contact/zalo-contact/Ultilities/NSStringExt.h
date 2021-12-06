//
//  NSStringExt.h
//  zalo-contact
//
//  Created by Thiện on 06/12/2021.
//

#import <Foundation/Foundation.h>
#define LOG(str) NSLog(@"%s %@", __PRETTY_FUNCTION__ ,str);
NS_ASSUME_NONNULL_BEGIN

@interface NSString (Common)
- (void)log;
@end

NS_ASSUME_NONNULL_END
