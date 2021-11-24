//
//  UpdateContactCell.m
//  zalo-contact
//
//  Created by Thiện on 24/11/2021.
//

#import "UpdateContactCell.h"
#import "UIConstants.h"
@interface UpdateContactCell ()

@property (nonatomic, assign) BOOL didSetupConstraints;
@property (nonatomic, strong) UILabel *sectionHeaderLabel;
@property (nonatomic, strong) UIButton *updateButton;

@end

@implementation UpdateContactCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    [self setSelectionStyle:(UITableViewCellSelectionStyleNone)];
    [self setBackgroundColor: UIColor.darkGrayColor];
    [self addSubview:self.sectionHeaderLabel];
    [self addSubview:self.updateButton];
    [self setNeedsUpdateConstraints];
    return self;
}

-(void) updateConstraints {
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

- (void) setSectionTitle:(NSString *)title {
    [self.sectionHeaderLabel setText:title];
}

- (void) setButtonTitle:(NSString *)title {
    [self.updateButton setTitle:title forState:(UIControlStateNormal)];
}

- (UILabel *) sectionHeaderLabel {
    if (!_sectionHeaderLabel) {
        _sectionHeaderLabel = [UILabel new];
    }
    return _sectionHeaderLabel;
}

- (UIButton *) updateButton {
    if (!_updateButton) {
        _updateButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_updateButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [_updateButton setTintColor:UIColor.systemBlueColor];
        // add action block
    }
    return _updateButton;
}
@end
