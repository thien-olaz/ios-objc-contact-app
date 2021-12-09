//
//  LabelCellObject.m
//  zalo-contact
//
//  Created by Thiện on 08/12/2021.
//

#import "LabelCellObject.h"

@implementation LabelCellObject

- (instancetype)init {
    self = [super initWithCellClass:LabelCell.class];
    return self;
}

- (instancetype)initWithTitle:(NSString *)title {
    self = self.init;
    self.title = title;
    self.alignment = NSTextAlignmentLeft;
    return self;
}

- (instancetype)initWithTitle:(NSString *)title andTextAlignment:(NSTextAlignment)alignment {
    self = [self initWithTitle:title];
    self.alignment = alignment;
    return self;
}

- (instancetype)initWithTitle:(NSString *)title andTextAlignment:(NSTextAlignment)alignment
                        color:(UIColor *)backgroundColor
                     cellType:(LabelCellType)type {
    self = [self initWithTitle:title];
    self.alignment = alignment;
    if (type == shortCell) {
        self.cellHeight = UIConstants.addContactLabelHeight + (CGFloat)8;
    } else {
        self.cellHeight = UIConstants.addContactLabelHeight + (CGFloat)20 * 2;
    }
    self.backgroundColor = backgroundColor;
    return self;
}

@end
