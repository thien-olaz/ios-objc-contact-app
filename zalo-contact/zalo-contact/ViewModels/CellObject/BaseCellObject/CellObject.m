//
//  CellObject.m
//  zalo-contact
//
//  Created by Thiện on 29/11/2021.
//

#import "CellObject.h"

@implementation CellObject

- (instancetype)initWithCellClass:(Class)cellClass {
    self = super.init;
    _cellClass = cellClass;
    return self;
}

@end
