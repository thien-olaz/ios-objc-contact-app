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
#import "CellObject.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^TapBlock)(void);


@protocol SwipeActionDelegate <NSObject>

@required
- (void)performAction:(SwipeActionType)type forObject:(CellObject *)object;

@end

@interface ContactTableViewAction : NSObject<UITableViewDelegate>

@property id<SwipeActionDelegate> swipeActionDelegate;

- (CellObject *)attachToObject:(CellObject *)object action:(TapBlock)tapped;
- (CellObject *)attachToObject:(CellObject *)object swipeAction:(NSArray<SwipeActionObject *> *)actionList;
@end

NS_ASSUME_NONNULL_END
