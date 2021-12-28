//
//  TabCellObject.m
//  zalo-contact
//
//  Created by Thiện on 28/12/2021.
//

#import "TabCellObject.h"
#import "TabCell.h"

@implementation TabItem

- (instancetype)initWithName:(NSString *)name andNumber:(int)number {
    self = [super init];
    self.name = name;
    self.number = number;
    return self;
}

@end

@implementation TabCellObject

- (instancetype)initWithTabItem:(NSMutableArray<TabItem *>*)tabItems {
    self = [super initWithCellClass:[TabCell class]];
    self.tabItems = tabItems;
    return self;
}

@end
