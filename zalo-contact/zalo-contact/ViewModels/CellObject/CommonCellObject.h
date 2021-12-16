//
//  NormalCellObject.h
//  zalo-contact
//
//  Created by Thiện on 30/11/2021.
//

#import "CellObject.h"
#import "CommonCell.h"
@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@interface CommonCellObject : CellObject

@property UIViewContentMode logoMode;
@property NSString *title;
@property UIImage *image;
@property UIColor *tintColor;

- (instancetype)initWithTitle:(NSString *)title image:(UIImage *)image tintColor:(UIColor *)color;

@end

NS_ASSUME_NONNULL_END
