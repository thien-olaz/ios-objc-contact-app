//
//  UIConstants.m
//  zalo-contact
//
//  Created by Thiện on 18/11/2021.
//

#import "UIConstants.h"

@implementation UIConstants
+ (UIEdgeInsets) contactHeaderEdgeInset {
    return UIEdgeInsetsMake(0, 0, 15, 0);
}

+ (CGFloat)contactHeaderHeight {
    return 30;
}

+ (UIEdgeInsets)contactCellEdgeInset {
    return UIEdgeInsetsMake(0, 0, 15, 0);
}

+ (CGFloat)contactCellHeight {
    return 60.0;
}

+ (CGFloat)contactFooterHeight {
    return 16.0;
}

+ (CGFloat)contactCellMinHorizontalInset {
    return 20.0;
}

+ (CGFloat)contactMinHorizontalSpacing {
    return 10.0;
}

+ (CGFloat)contactCellDimensionSize {
    return 44;
}

+ (CGFloat)cornerRadius {
    return self.contactCellDimensionSize / 2;
}

+ (CGSize)contactCellAvatarSize {
    return CGSizeMake(self.contactCellDimensionSize, self.contactCellDimensionSize);
}

+ (CGSize)contactCellButtonSize {
    return CGSizeMake(40, 40);
}

@end
