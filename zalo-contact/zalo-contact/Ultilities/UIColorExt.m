//
//  UIColorExt.m
//  zalo-contact
//
//  Created by Thiện on 21/11/2021.
//

#import "UIColorExt.h"

@implementation UIColor (Common)

+ (UIColor *)zaloBackgroundColor {
    return UIColor.whiteColor;
}

+ (UIColor *)zaloPrimaryColor {
    return [UIColor.alloc initWithRed:24.0f/255.0f green:90.0f/255.0f blue:226.0f/255.0f alpha:1.0f];
}

+ (UIColor *)neonGreen {
    return [UIColor.alloc initWithRed:36.0f/255.0f green:184.0f/255.0f blue:98.0f/255.0f alpha:1.0f];
}

+ (UIColor *)zaloLightGrayColor {
    return [UIColor.alloc initWithRed:242.0f/255.0f green:242.0f/255.0f blue:242.0f/255.0f alpha:0.8f];
}

+ (UIColor *)grayColor {
    return [UIColor.alloc initWithRed:74.0f/255.0f green:74.0f/255.0f blue:74.0f/255.0f alpha:1.0f];
}

+ (UIColor *)darkGrayColor {
    return [UIColor.alloc initWithRed:17.0f/255.0f green:17.0f/255.0f blue:17.0f/255.0f alpha:1.0f];
}

+ (UIColor *)buttonGrayColor {
    return [UIColor.alloc initWithRed:74.0f/255.0f green:74.0f/255.0f blue:74.0f/255.0f alpha:1.0f];
}

+ (UIColor *)cellHighlightColor {
    return [UIColor.alloc initWithRed:12.0f/255.0f green:107.0f/255.0f blue:255.0f/255.0f alpha:0.4f];
}

+ (UIColor *)badgeColor {
    return [UIColor.alloc initWithRed:29.0f/255.0f green:199.0f/255.0f blue:90.0f/255.0f alpha:1.0f];
}

@end
