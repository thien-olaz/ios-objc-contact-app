//
//  ContactTableViewAction.h
//  zalo-contact
//
//  Created by Thiện on 29/11/2021.
//

@import UIKit;
@import Foundation;
#import "CellObject.h"
#import "ContactTableViewDataSource.h"
#import "HeaderFooterFactory.h"
#import "SwipeActionObject.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^TapBlock)(void);

typedef NS_ENUM(NSUInteger, SwipeActionType) {
    deleteAction,
    markAsFavoriteAction,
    moreAction
};

@interface ContactTableViewAction : NSObject<UITableViewDelegate>

- (CellObject *)attachToObject:(CellObject *)object action:(TapBlock)tapped;
- (CellObject *)attachToObject:(CellObject *)object action:(TapBlock)tapped swipeAction:(NSArray<SwipeActionObject *> *)actionList;
- (CellObject *)attachToObject:(CellObject *)object swipeAction:(NSArray<SwipeActionObject *> *)actionList;
@end

NS_ASSUME_NONNULL_END
