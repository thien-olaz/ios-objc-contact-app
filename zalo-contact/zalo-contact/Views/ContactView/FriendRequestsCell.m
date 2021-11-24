//
//  FriendRequestsCell.m
//  zalo-contact
//
//  Created by Thiện on 24/11/2021.
//

#import "FriendRequestsCell.h"

@interface FriendRequestsCell ()

@property (nonatomic, assign) BOOL didSetupConstraints;
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation FriendRequestsCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    [self setBackgroundColor: UIColor.systemBackgroundColor];
    [self addSubview:self.iconImageView];
    [self addSubview:self.titleLabel];
    [self setNeedsUpdateConstraints];
    return self;
}

-(void) updateConstraints {
    if (!self.didSetupConstraints) {
        
        [self.iconImageView autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
        [self.iconImageView autoPinEdgeToSuperviewEdge:ALEdgeLeft
                                               withInset:UIConstants.contactCellMinHorizontalInset];
        [self.iconImageView autoSetDimensionsToSize:UIConstants.contactCellAvatarSize];
           
        
        [self.titleLabel autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
        [self.titleLabel autoPinEdge:ALEdgeLeft
                             toEdge:ALEdgeRight
                             ofView:self.iconImageView
                         withOffset:UIConstants.contactMinHorizontalSpacing];
        
        
        self.didSetupConstraints = YES;
    }
    [super updateConstraints];
}

- (void) setTitle:(NSString *)title {
    [self.titleLabel setText:title];
}

- (void) setIconImage:(nonnull UIImage*)image {
    [self.iconImageView setImage:image];
}

- (UILabel *) titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
    }
    return _titleLabel;
}

- (UIImageView *) iconImageView {
    if (!_iconImageView) {
        _iconImageView = [UIImageView new];
        _iconImageView.backgroundColor = UIColor.clearColor;
        [[_iconImageView layer] setCornerRadius:UIConstants.cornerRadius];
        [_iconImageView layer].masksToBounds = YES;
    }
    return  _iconImageView;
}

@end
