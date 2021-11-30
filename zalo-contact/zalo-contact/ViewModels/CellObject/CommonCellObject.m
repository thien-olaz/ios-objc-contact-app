//
//  NormalCellObject.m
//  zalo-contact
//
//  Created by Thiện on 30/11/2021.
//

#import "CommonCellObject.h"

@implementation CommonCellObject

- (instancetype)initWithTitle:(NSString *)title
                        image:(UIImage *)image
                    tintColor:(UIColor *)color {
    self = [super initWithCellClass:CommonCell.class];
    _title = title;
    _image = image;
    _tintColor = color;
    return self;
}

@end
