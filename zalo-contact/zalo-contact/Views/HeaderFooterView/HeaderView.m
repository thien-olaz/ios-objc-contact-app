//
//  ContactSectionCell.m
//  zalo-contact
//
//  Created by Thiện on 16/11/2021.
//

#import "HeaderView.h"

@interface HeaderView ()

@property (nonatomic, assign) BOOL didSetupConstraints;
@property (nonatomic, strong) UILabel *sectionHeaderLabel;

@end

@implementation HeaderView

- (instancetype)initWithTitle:(NSString *)title {
    self = [super init];
    [self commonInit];
    [self setSectionTitle:title];
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    [self commonInit];
    return self;
}

- (void)commonInit {
    [self setBackgroundColor: UIColor.zaloBackgroundColor];
    [self addSubview:self.sectionHeaderLabel];
    [self setNeedsUpdateConstraints];
}

- (void)updateConstraints {
    if (!_didSetupConstraints) {
        [self.sectionHeaderLabel autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
        [self.sectionHeaderLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft
                                                  withInset:UIConstants.contactCellMinHorizontalInset];
        _didSetupConstraints = YES;
        
    }
    [super updateConstraints];
}

- (void)setSectionTitle:(NSString *)title {
    [self.sectionHeaderLabel setText:title];
}

- (UILabel *)sectionHeaderLabel {
    if (!_sectionHeaderLabel) {
        _sectionHeaderLabel = [UILabel new];
        [_sectionHeaderLabel setFont:[UIFont systemFontOfSize:UIConstants.contactHeaderFontSize weight:(UIFontWeightMedium)]];
    }
    return _sectionHeaderLabel;
}

- (void)setNeedsObject:(nonnull ShortHeaderObject *)object {
    [self setSectionTitle:object.title];
}

+ (CGFloat)heightForHeaderWithObject:(ShortHeaderObject *)object {
    return 28;
}

@end
