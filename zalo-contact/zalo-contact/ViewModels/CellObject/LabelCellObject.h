//
//  LabelCellObject.h
//  zalo-contact
//
//  Created by Thiện on 08/12/2021.
//

#import <Foundation/Foundation.h>
#import "CellObject.h"
#import "CommonCell.h"
#import "LabelCell.h"
@import UIKit;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, LabelCellType) {
    shortCell,
    tallCell,
};

@interface LabelCellObject : CellObject

@property NSTextAlignment alignment;
@property NSString *title;
@property UIColor *backgroundColor;
@property CGFloat cellHeight;

- (instancetype)initWithTitle:(NSString *)title;
- (instancetype)initWithTitle:(NSString *)title andTextAlignment:(NSTextAlignment)alignment;
- (instancetype)initWithTitle:(NSString *)title andTextAlignment:(NSTextAlignment)alignment
                        color:(UIColor *)backgroundColor
                     cellType:(LabelCellType)type;
@end

NS_ASSUME_NONNULL_END
