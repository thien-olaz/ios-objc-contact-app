//
//  UpdateContactCell.m
//  zalo-contact
//
//  Created by Thiện on 24/11/2021.
//

#import "ActionHeaderView.h"

@interface ActionHeaderView ()

@property (nonatomic, assign) BOOL didSetupConstraints;
@property (nonatomic, strong) UILabel *sectionHeaderLabel;
@property (nonatomic, strong) UIButton *updateButton;

@end

@implementation ActionHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    [self setBackgroundColor: UIColor.zaloBackgroundColor];
    [self addSubview:self.sectionHeaderLabel];
    [self addSubview:self.updateButton];
    [self setNeedsUpdateConstraints];
    return self;
}

- (void)updateConstraints {
    if (!_didSetupConstraints) {
        [self.sectionHeaderLabel autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
        [self.sectionHeaderLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft
                                                  withInset:UIConstants.contactCellMinHorizontalInset];
        
        [self.updateButton autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
        [self.updateButton autoPinEdgeToSuperviewEdge:ALEdgeRight
                                            withInset:UIConstants.contactCellMinHorizontalInset];
        
        _didSetupConstraints = YES;
        
    }
    [super updateConstraints];
}

- (void)setSectionTitle:(NSString *)title {
    [self.sectionHeaderLabel setText:title];
}

- (void)setButtonTitle:(NSString *)title {
    [self.updateButton setTitle:title forState:(UIControlStateNormal)];
}

- (UILabel *)sectionHeaderLabel {
    if (!_sectionHeaderLabel) {
        _sectionHeaderLabel = [UILabel new];
        [_sectionHeaderLabel setFont:[UIFont systemFontOfSize:UIConstants.contactHeaderFontSize weight:(UIFontWeightMedium)]];
    }
    return _sectionHeaderLabel;
}

- (UIButton *)updateButton {
    if (!_updateButton) {
        _updateButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_updateButton.titleLabel setFont:[UIFont systemFontOfSize:UIConstants.contactHeaderButtonFontSize weight:(UIFontWeightSemibold)]];
        [_updateButton setTintColor:UIColor.zaloPrimaryColor];
        [_updateButton addTarget:self
                          action:@selector(didClick)
                forControlEvents:UIControlEventTouchUpInside];
    }
    return _updateButton;
}

- (void)didClick {
    if (_block) _block();
}

- (void)setNeedsObject:(nonnull ActionHeaderObject *)object {
    [self setSectionTitle:object.title];
    [self setButtonTitle:object.buttonTitle];
    [self setBlock:object.block];
}

+ (CGFloat)heightForHeaderWithObject:(ShortHeaderObject *)object {
    return 28;
}

@end
