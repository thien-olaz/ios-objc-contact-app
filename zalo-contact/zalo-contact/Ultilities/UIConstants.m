//
//  UIConstants.m
//  zalo-contact
//
//  Created by Thiện on 18/11/2021.
//

#import "UIConstants.h"

@implementation UIConstants

static int _ctIndex;
static int _onlineCtIndex;

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
    return 48;
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

+ (CGFloat)contactHeaderFontSize {
    return 11;
}

+ (CGFloat)contactHeaderButtonFontSize {
    return 11;
}

+ (CGFloat)contactCellFontSize {
    return 13;
}

+ (CGFloat)addContactLabelHeight {
    return 28;
}

+ (CGFloat)addContactButtonHeight {
    return 32;
}

+ (int)getContactIndex {
    if (!_ctIndex) _ctIndex = 4;
    return _ctIndex;
}

+ (void)setContactIndex:(int)index {
    _ctIndex = index;
}

+ (int)getOnlineContactIndex {
    if (!_onlineCtIndex) _onlineCtIndex = 2;
    return _onlineCtIndex;
}

+ (void)setOnlineContactIndex:(int)index {
    _onlineCtIndex = index;
}

@end
