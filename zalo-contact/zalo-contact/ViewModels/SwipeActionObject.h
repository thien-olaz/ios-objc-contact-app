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

typedef NS_ENUM(NSUInteger, SwipeActionType) {
    deleteAction,
    markAsFavoriteAction,
    moreAction
};

@interface SwipeActionObject : NSObject

@property SwipeActionType actionType;
@property NSString *title;
@property UIColor *color;
@property (copy) ActionBlock actionBlock;

- (instancetype)initWithTile:(NSString *)title color:(UIColor *)color actionType:(SwipeActionType)type;

@end

NS_ASSUME_NONNULL_END
