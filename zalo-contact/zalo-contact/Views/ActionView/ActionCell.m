//
//  FriendRequestsCell.m
//  zalo-contact
//
//  Created by Thiện on 24/11/2021.
//

#import "ActionCell.h"

@interface ActionCell ()

@property (nonatomic, assign) BOOL didSetupConstraints;
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation ActionCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    UIView *bgView = [UIView.alloc init];
    [bgView setBackgroundColor:UIColor.cellHighlightColor];
    [self setSelectedBackgroundView:bgView];
    [self setSelectionStyle:(UITableViewCellSelectionStyleGray)];
    
    [self setBackgroundColor:UIColor.darkGrayColor];
    [self.contentView addSubview:self.iconImageView];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView setNeedsUpdateConstraints];
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

- (void) prepareForReuse {
    [super prepareForReuse];
    [self.titleLabel setTextColor:nil];
    [self.iconImageView setTintColor:nil];
}

- (void) setTitleTintColor:(UIColor *)color {
    [self.titleLabel setTextColor:color];
    [self.iconImageView setTintColor:color];
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
        _iconImageView.backgroundColor = UIColor.buttonGrayColor;
        [_iconImageView setContentMode:(UIViewContentModeScaleAspectFit)];
        [_iconImageView.layer setCornerRadius:UIConstants.cornerRadius];
        [_iconImageView.layer setMasksToBounds:YES];
    }
    return  _iconImageView;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:NO];
    if (self.selected) {
        
        if (_block) _block();
    }
}

@end
