//
//  CellItem.m
//  zalo-contact
//
//  Created by Thiện on 25/11/2021.
//

#import "CellItem.h"

@implementation CellItem

+ (instancetype)initWithType:(NSString *)type data:(NSObject *)data {
    CellItem *item = CellItem.new;
    [item setCellType: type];
    [item setData: data];
    return item;
}

@end
