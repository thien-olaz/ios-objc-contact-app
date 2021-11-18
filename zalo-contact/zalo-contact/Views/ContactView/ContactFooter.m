//
//  ContactFooter.m
//  zalo-contact
//
//  Created by Thiện on 18/11/2021.
//

#import "ContactFooter.h"

@interface ContactFooter ()

@property (nonatomic, assign) BOOL didSetupConstraints;
@property (nonatomic, strong) UIView *separateLineview;

@end

@implementation ContactFooter
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    [self addSubview:self.separateLineview];
    
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
