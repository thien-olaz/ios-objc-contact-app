//
//  SwipeActionObject.h
//  zalo-contact
//
//  Created by Thiện on 08/12/2021.
//

@import Foundation;
@import UIKit;
NS_ASSUME_NONNULL_BEGIN
typedef void (^ActionBlock)(void);

@interface SwipeActionObject : NSObject

@property NSString *title;
@property UIColor *color;
@property (copy) ActionBlock actionBlock;

- (instancetype)initWithTile:(NSString *)title color:(UIColor *)color action:(ActionBlock)block;

@end

NS_ASSUME_NONNULL_END
