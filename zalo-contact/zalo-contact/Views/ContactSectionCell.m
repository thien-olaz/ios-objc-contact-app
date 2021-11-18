//
//  ContactSectionCell.m
//  zalo-contact
//
//  Created by Thiện on 16/11/2021.
//

#import "ContactSectionCell.h"

@interface ContactSectionCell ()

@property (nonatomic, assign) BOOL didSetupConstraints;
@property (nonatomic, strong) UILabel *sectionHeaderLabel;

@end

@implementation ContactSectionCell

@synthesize didSetupConstraints = _didSetupConstraints;

- (instancetype) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    [self addSubview:self.sectionHeaderLabel];
    
    return self;
}

-(void) updateConstraints {
    if (!_didSetupConstraints) {
        [self.sectionHeaderLabel autoSetDimension:ALDimensionHeight toSize:40];
        [self.sectionHeaderLabel autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
        [self.sectionHeaderLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:20];
        
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
