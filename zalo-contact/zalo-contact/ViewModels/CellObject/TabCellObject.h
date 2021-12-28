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

@property NSString *name;
@property int number;
- (instancetype)initWithName:(NSString *)name andNumber:(int)number;
@end

@interface TabCellObject : CellObject

@property NSMutableArray<TabItem *> *tabItems;

- (instancetype)initWithTabItem:(NSMutableArray<TabItem *>*)tabItems;

@end

NS_ASSUME_NONNULL_END
