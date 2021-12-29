//
//  TabCellObject.h
//  zalo-contact
//
//  Created by Thiện on 28/12/2021.
//

@import Foundation;
@import UIKit;
#import "ContactCell.h"

NS_ASSUME_NONNULL_BEGIN



@interface TabItem : NSObject

@property NSUInteger indentity;
@property NSString *name;
@property int number;

- (instancetype)initWithName:(NSString *)name andNumber:(int)number;

@end

typedef void(^OnTabItemClick) (int);

@interface TabCellObject : CellObject

@property NSMutableArray<TabItem *> *tabItems;
@property int selectedIndex;
@property (copy) OnTabItemClick didClick;

- (instancetype)initWithTabItem:(NSMutableArray<TabItem *>*)tabItems selectedIndex:(int)index withDidClickBlock:(OnTabItemClick)block;
- (instancetype)initWithTabItem:(NSMutableArray<TabItem *>*)tabItems;

@end

NS_ASSUME_NONNULL_END
