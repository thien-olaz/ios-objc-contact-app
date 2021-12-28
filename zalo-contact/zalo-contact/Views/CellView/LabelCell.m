//
//  LabelCell.m
//  zalo-contact
//
//  Created by Thiện on 08/12/2021.
//

#import "LabelCell.h"
#import "LabelCellObject.h"

@interface LabelCell ()

@property (nonatomic, strong) UILabel *label;

@end

@implementation LabelCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    [self commonInit];
    return self;
}

- (void)commonInit {
    [self setSelectionStyle:(UITableViewCellSelectionStyleNone)];
    [self setBackgroundColor:UIColor.zaloLightGrayColor];
    [self.contentView addSubview:self.label];
}

- (void)setLabelAlignment:(NSTextAlignment)alignment {
    [self.label setTextAlignment:alignment];
}

- (void)setSectionTitle:(NSString *)title {
    [self.label setText:title];
}

- (UILabel *)label {
    if (!_label) {
        _label = [UILabel.alloc init];
        [_label setNumberOfLines:0];
        [_label setTextColor:UIColor.lightGrayColor];
        [_label setFont:[UIFont systemFontOfSize:UIConstants.contactHeaderFontSize weight:(UIFontWeightMedium)]];
    }
    return _label;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect newFrame = CGRectZero;
    newFrame.size = CGSizeMake(self.bounds.size.width * 2 / 3, UIConstants.addContactLabelHeight );

    [_label setFrame:newFrame];
    _label.center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
}

- (void)setNeedsObject:(LabelCellObject *)object {
    [self setSectionTitle:object.title];
    [self setLabelAlignment:object.alignment];
    [self setBackgroundColor:object.backgroundColor];
}

+ (CGFloat)heightForRowWithObject:(nonnull LabelCellObject *)object {
    return object.cellHeight;
}

@end

