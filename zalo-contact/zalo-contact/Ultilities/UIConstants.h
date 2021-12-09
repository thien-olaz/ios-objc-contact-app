//
//  UIConstants.h
//  zalo-contact
//
//  Created by Thiện on 18/11/2021.
//

#import <Foundation/Foundation.h>
@import CoreGraphics;
@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@interface UIConstants : NSObject

// MARK: - Contact Section Cell UI Constant
+ (UIEdgeInsets)contactHeaderEdgeInset;
+ (CGFloat)contactHeaderHeight;

// MARK: - Contact Cell UI Constant
+ (UIEdgeInsets)contactCellEdgeInset;

+ (CGFloat)contactCellHeight;
+ (CGFloat)contactFooterHeight;

+ (CGFloat)contactCellMinHorizontalInset;
+ (CGFloat)contactMinHorizontalSpacing;
+ (CGFloat)contactCellDimensionSize;
+ (CGFloat)cornerRadius;
+ (CGSize)contactCellAvatarSize;
+ (CGSize)contactCellButtonSize;
+ (CGFloat)contactHeaderFontSize;
+ (CGFloat)contactHeaderButtonFontSize;
+ (CGFloat)contactCellFontSize;
+ (CGFloat)addContactLabelHeight;
+ (CGFloat)addContactButtonHeight;

@end

NS_ASSUME_NONNULL_END
