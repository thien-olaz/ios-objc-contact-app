//
//  CenterLabelHeaderView.m
//  zalo-contact
//
//  Created by Thiện on 08/12/2021.
//

#import "LabelViewCell.h"

@interface LabelViewCell ()

@property (nonatomic, strong) UILabel *sectionHeaderLabel;

@end

@implementation LabelViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    [self commonInit];
    return self;
}

- (void)commonInit {
    [self setBackgroundColor: UIColor.whiteColor];
    [self addSubview:self.sectionHeaderLabel];
}

- (void)setTextAlignment:(NSTextAlignment)alignment {
    [self.sectionHeaderLabel setTextAlignment:alignment];
}

- (void)setSectionTitle:(NSString *)title {
    [self.sectionHeaderLabel setText:title];
}

- (UILabel *)sectionHeaderLabel {
    if (!_sectionHeaderLabel) {
        _sectionHeaderLabel = [UILabel.alloc init];
        [_sectionHeaderLabel setFont:[UIFont systemFontOfSize:UIConstants.contactHeaderFontSize weight:(UIFontWeightMedium)]];
    }
    return _sectionHeaderLabel;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _sectionHeaderLabel.frame = self.bounds;
}

- (void)setNeedsObject:(nonnull LabelHeaderObject *)object {
    [self setSectionTitle:object.title];
    [self setTextAlignment:object.alignment];
}

+ (CGFloat)heightForHeaderWithObject:(ShortHeaderObject *)object {
    return 28;
}

@end
