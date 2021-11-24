//
//  ContactFooter.m
//  zalo-contact
//
//  Created by Thiện on 18/11/2021.
//

#import "ContactFooterCell.h"

@interface ContactFooterCell ()

@property (nonatomic, assign) BOOL didSetupConstraints;
@property (nonatomic, strong) UIView *separateLineview;

@end

@implementation ContactFooterCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    [self.contentView addSubview:self.separateLineview];
    [self setBackgroundColor: UIColor.darkGrayColor];
    [self setNeedsUpdateConstraints];
    return self;
}

- (UIView *)separateLineview {
    if (!_separateLineview) {
        _separateLineview = [UIView.alloc init];
        _separateLineview.backgroundColor = UIColor.systemGray6Color;
    }
    return _separateLineview;
}

- (void) updateConstraints {
    if (!_didSetupConstraints) {
        [self.separateLineview autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
        [self.separateLineview autoPinEdgeToSuperviewEdge:ALEdgeLeft
                                                withInset:UIConstants.contactMinHorizontalSpacing];
        [self.separateLineview autoPinEdgeToSuperviewEdge:ALEdgeRight
                                                withInset:UIConstants.contactMinHorizontalSpacing];
        [self.separateLineview autoSetDimension:ALDimensionHeight
                                         toSize:2];
        _didSetupConstraints = YES;
    }
    [super updateConstraints];
}
@end
