//
//  ContactSectionCell.m
//  zalo-contact
//
//  Created by Thiện on 16/11/2021.
//

#import "ContactHeaderCell.h"

@interface ContactHeaderCell ()

@property (nonatomic, assign) BOOL didSetupConstraints;
@property (nonatomic, strong) UILabel *sectionHeaderLabel;

@end

@implementation ContactHeaderCell

- (instancetype) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    [self addSubview:self.sectionHeaderLabel];
    [self setNeedsUpdateConstraints];
    return self;
}

-(void) updateConstraints {
    if (!_didSetupConstraints) {
        [self.sectionHeaderLabel autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
        [self.sectionHeaderLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft
                                                  withInset:UIConstants.contactCellMinHorizontalInset];
        _didSetupConstraints = YES;
        
    }
    [super updateConstraints];
}

- (void) setSectionTitle:(NSString *)title {
    [self.sectionHeaderLabel setText:title];
}

- (UILabel *) sectionHeaderLabel {
    if (!_sectionHeaderLabel) {
        _sectionHeaderLabel = [UILabel new];
    }
    return _sectionHeaderLabel;
}

@end
