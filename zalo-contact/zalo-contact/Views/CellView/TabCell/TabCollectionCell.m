//
//  TabCollectionCell.m
//  zalo-contact
//
//  Created by Thiện on 28/12/2021.
//

#import "TabCollectionCell.h"

@interface TabCollectionCell ()

@property (nonatomic, strong) UILabel *cellLabel;
//@property UILabel *cellLabel;

@end

@implementation TabCollectionCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    UIView *bgView = [UIView.alloc init];
    [bgView setBackgroundColor:UIColor.zaloLightGrayColor];
    [self setSelectedBackgroundView:bgView];
    
    self.layer.borderWidth = UIConstants.borderWidth;
    self.layer.borderColor = UIColor.zaloLightGrayColor.CGColor;
    
    bgView.layer.borderWidth = UIConstants.borderWidth;
    bgView.layer.borderColor = UIColor.zaloLightGrayColor.CGColor;
    
    [self.contentView addSubview:self.cellLabel];
    
    return self;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    if (selected) {
        [self.cellLabel setTextColor:UIColor.blackColor];
    } else {
        [self.cellLabel setTextColor:UIColor.lightGrayColor];
    }
}

- (void)setLabelText:(NSString *)text andNumber:(int)number {
    [self.cellLabel setText:[NSString stringWithFormat:@"%@   %d", text, number]];
    [self setNeedsLayout];
}

- (UILabel *)cellLabel {
    if (!_cellLabel) {
        _cellLabel = [UILabel new];
        [_cellLabel setFont:[UIFont systemFontOfSize:UIConstants.contactCellFontSize weight:UIFontWeightBold]];
        [_cellLabel setTextColor:UIColor.lightGrayColor];
    }
    return _cellLabel;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.layer.cornerRadius = self.bounds.size.height / 2;
    self.selectedBackgroundView.layer.cornerRadius = self.layer.cornerRadius;
    
    CGRect newFrame = CGRectZero;
    newFrame.size = CGSizeMake(self.bounds.size.width - 20, UIConstants.addContactLabelHeight);
    
    [self.cellLabel setFrame:newFrame];
    self.cellLabel.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
}

+ (CGSize)calculateTextSize:(NSString *)text andNumber:(int)number {
    CGSize textSize = [[NSString stringWithFormat:@"%@  %d", text, number] sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:UIConstants.contactCellFontSize]}];
    return textSize;
}

@end
