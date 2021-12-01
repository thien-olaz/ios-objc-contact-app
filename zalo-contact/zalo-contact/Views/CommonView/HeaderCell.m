//
//  ContactSectionCell.m
//  zalo-contact
//
//  Created by Thiện on 16/11/2021.
//

#import "HeaderCell.h"

@interface HeaderCell ()

@property (nonatomic, assign) BOOL didSetupConstraints;
@property (nonatomic, strong) UILabel *sectionHeaderLabel;

@end

@implementation HeaderCell

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

- (UILabel *) sectionHeaderLabel {
    if (!_sectionHeaderLabel) {
        _sectionHeaderLabel = [UILabel new];
    }
    return _sectionHeaderLabel;
}

- (void)setNeedsObject:(nonnull ShortHeaderObject *)object {
    [self setSectionTitle:object.title];
}

+ (CGFloat)heightForHeaderWithObject:(ShortHeaderObject *)object {
    return 20;
}

@end
