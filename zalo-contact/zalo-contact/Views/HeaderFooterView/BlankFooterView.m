//
//  BlankFooterCell.m
//  zalo-contact
//
//  Created by Thiện on 24/11/2021.
//

#import "BlankFooterView.h"
#import "UIColorExt.h"
@implementation BlankFooterView

- (instancetype)init {
    self = [super init];
    [self setBackgroundColor: UIColor.zaloLightGrayColor];
    return self;
}

+ (CGFloat)heightForFooterWithObject:(FooterObject *)object {
    return 4;
}

@end
