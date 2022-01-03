//
//  TabCellObject.m
//  zalo-contact
//
//  Created by Thiện on 28/12/2021.
//

#import "TabCellObject.h"
#import "TabCell.h"

@interface TabItem () {
    NSUInteger cacheHash;
}

@end

@implementation TabItem

//hash for nsorderset
- (NSUInteger)hash {
    return cacheHash;
}

- (instancetype)initWithName:(NSString *)name andNumber:(int)number {
    self = [super init];
    self.name = name;
    self.number = number;
    cacheHash = name.hash;
    self.indentity = self.name.hash;
    return self;
}

@end

@implementation TabCellObject

- (instancetype)initWithTabItem:(NSMutableArray<TabItem *>*)tabItems selectedIndex:(int)index withDidClickBlock:(OnTabItemClick)block {
    self = [self initWithTabItem:tabItems];
    self.selectedIndex = index;
    [self setDidClick:block];
    return self;
}


- (instancetype)initWithTabItem:(NSMutableArray<TabItem *>*)tabItems {
    self = [super initWithCellClass:[TabCell class]];
    self.tabItems = tabItems;
    return self;
}

@end
