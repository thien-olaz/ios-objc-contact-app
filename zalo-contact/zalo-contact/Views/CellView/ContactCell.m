//
//  ContactCell.m
//  zalo-contact
//
//  Created by Thiện on 16/11/2021.
//

#import "ContactCell.h"

@interface ContactCell ()

@property (nonatomic, assign) BOOL didSetupConstraints;
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;
@property (nonatomic, strong) UIButton *callButton;
@property (nonatomic, strong) UIButton *videoCallButton;
@property (nonatomic, strong) UIView *newFriendMarkView;
@property (nonatomic, strong) UIStackView *nameView;
@property (nonatomic, strong) UILabel *isNewLabel;
@property (nonatomic, strong) UIImageView *isNewImageView;
@property (nonatomic, strong) UIView *badgeView;
@end

@implementation ContactCell

@synthesize didSetupConstraints = _didSetupConstraints;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    [self setBackgroundColor: UIColor.zaloBackgroundColor];
    [self.contentView addSubview:self.nameView];
    [self.contentView addSubview:self.avatarImageView];
    [self.contentView addSubview:self.badgeView];
    [self.contentView addSubview:self.callButton];
    [self.contentView addSubview:self.videoCallButton];
    [self.contentView addSubview:self.newFriendMarkView];
    
    [self.newFriendMarkView setHidden:YES];
    
    [self setNeedsUpdateConstraints];
    
    return self;
}

- (void)setOnline {
    [self.badgeView setBackgroundColor:UIColor.badgeColor];
}

- (void)setNameWith:(NSString *)name {
    [self.nameLabel setText:name];
}

- (void)setSubtitleWith:(NSString *)subtitle {
    [self.subtitleLabel setText:subtitle];
}

- (void)setAvatarImage:(nonnull UIImage*)image {
    //    UIImage *cropImage = nil;
    
    //    UIGraphicsBeginImageContext(image.size);
    //    {
    //        CGContextRef ctx = UIGraphicsGetCurrentContext();
    //        CGAffineTransform trnsfrm = CGAffineTransformConcat(CGAffineTransformIdentity, CGAffineTransformMakeScale(1.0, -1.0));
    //        trnsfrm = CGAffineTransformConcat(trnsfrm, CGAffineTransformMakeTranslation(0.0, image.size.height));
    //        CGContextConcatCTM(ctx, trnsfrm);
    //        CGContextBeginPath(ctx);
    //        CGContextAddEllipseInRect(ctx, CGRectMake(0.0, 0.0, image.size.width, image.size.height));
    //        CGContextClip(ctx);
    //        CGContextDrawImage(ctx, CGRectMake(0.0, 0.0, image.size.width, image.size.height), image.CGImage);
    //        cropImage = UIGraphicsGetImageFromCurrentImageContext();
    //        UIGraphicsEndImageContext();
    //    }
    
    //MARK :- resize - mask - cache
    [self.avatarImageView setImage:image];
}

- (void)setAvatarImageUrl:(NSString * __nullable)url {
    if (url) {
        [_avatarImageView sd_setImageWithURL: [NSURL.alloc initWithString:url] placeholderImage:[UIImage imageNamed:@"ct_avt_placeholder"]];
    } else {
        UIImage *placeholderImage = [UIImage imageNamed:@"ct_avt_placeholder"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->_avatarImageView setImage: placeholderImage];
        });
    }
}

- (void)updateConstraints {
    if (!self.didSetupConstraints) {
        
        [self.avatarImageView autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
        [self.avatarImageView autoPinEdgeToSuperviewEdge:ALEdgeLeft
                                               withInset:UIConstants.contactCellMinHorizontalInset];
        [self.avatarImageView autoSetDimensionsToSize:UIConstants.contactCellAvatarSize];
        
        //badge
        [self.badgeView autoSetDimensionsToSize:CGSizeMake(12, 12)];
        [self.badgeView autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self.avatarImageView];
        [self.badgeView autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.avatarImageView];
        
        //name
        [self.nameView addArrangedSubview:self.nameLabel];
        [self.nameView addArrangedSubview:self.subtitleLabel];
        
        [self.nameView autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
        [self.nameView autoPinEdge:ALEdgeLeft
                            toEdge:ALEdgeRight
                            ofView:self.avatarImageView
                        withOffset:UIConstants.contactMinHorizontalSpacing];
        
        //subtitle label here
        
        [self.newFriendMarkView autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
        [self.newFriendMarkView autoPinEdge:ALEdgeLeft
                                     toEdge:ALEdgeRight
                                     ofView:self.nameLabel
                                 withOffset:UIConstants.contactMinHorizontalSpacing];
        [_isNewLabel autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
        [_isNewLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:6];
        [_isNewLabel autoPinEdge:ALEdgeRight toEdge:ALEdgeLeft ofView:_isNewImageView withOffset:-2];
        
        [_isNewImageView autoSetDimensionsToSize:CGSizeMake(20, 20)];
        [_isNewImageView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(2, 6, 2, 6) excludingEdge:ALEdgeLeft];
        
        [self.videoCallButton autoPinEdgeToSuperviewEdge:ALEdgeRight
                                          withInset:UIConstants.contactCellMinHorizontalInset];
        [self.videoCallButton autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
        [self.videoCallButton autoSetDimensionsToSize:UIConstants.contactCellButtonSize];
        
        [self.callButton autoPinEdge:ALEdgeRight toEdge:ALEdgeLeft ofView:self.videoCallButton];
        [self.callButton autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
        [self.callButton autoSetDimensionsToSize:UIConstants.contactCellButtonSize];
        
        self.didSetupConstraints = YES;
    }
    [super updateConstraints];
}

- (UIStackView *)nameView {
    if (!_nameView) {
        _nameView = [UIStackView new];
        [_nameView setAxis:UILayoutConstraintAxisVertical];
        [_nameView setSpacing:4];
    }
    return _nameView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [UILabel new];
    }
    return _nameLabel;
}

- (UILabel *)subtitleLabel {
    if (!_subtitleLabel) {
        _subtitleLabel = [UILabel new];
        [_subtitleLabel setFont: [_subtitleLabel.font fontWithSize:14]];
        [_subtitleLabel setTextColor:UIColor.lightGrayColor];
    }
    return _subtitleLabel;
}

- (UIView *)newFriendMarkView {
    if (!_newFriendMarkView) {
        _newFriendMarkView = [UIView new];
        [_newFriendMarkView setBackgroundColor:UIColor.zaloLightGrayColor];
        [_newFriendMarkView.layer setCornerRadius:5];
        
        _isNewLabel = UILabel.new;
        [_isNewLabel setText:@"Mới"];
        [_isNewLabel setTextColor:UIColor.neonGreen];
        [_isNewLabel setFont: [_isNewLabel.font fontWithSize:13]];
        
        _isNewImageView = [UIImageView new];
        _isNewImageView.image =  [[UIImage imageNamed:@"tb_user"]
                                  imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [_isNewImageView setTintColor:UIColor.neonGreen];
        
        [_newFriendMarkView addSubview:_isNewImageView];
        [_newFriendMarkView addSubview:_isNewLabel];
        
    }
    return _newFriendMarkView;
}

- (UIView *)badgeView {
    if (!_badgeView) {
        _badgeView = UIView.new;
        [_badgeView setBackgroundColor:UIColor.clearColor];
        [_badgeView.layer setCornerRadius:6];
    }
    return _badgeView;
}


- (UIImageView *)avatarImageView {
    if (!_avatarImageView) {
        _avatarImageView = [UIImageView new];
        _avatarImageView.backgroundColor = UIColor.clearColor;
        [[_avatarImageView layer] setCornerRadius:UIConstants.cornerRadius];
        [_avatarImageView layer].masksToBounds = YES;
    }
    return  _avatarImageView;
}

- (UIButton *)callButton {
    if (!_callButton) {
        _callButton = [UIButton new];
        [_callButton setImage:[UIImage imageNamed:@"ct_call"]  forState:UIControlStateNormal];
        [_callButton addTarget:self
                        action:@selector(phoneCallClicked)
              forControlEvents:UIControlEventTouchUpInside];
    }
    return  _callButton;
}

- (void)phoneCallClicked {
    if (_phoneBlock) _phoneBlock();
}

- (UIButton *)videoCallButton {
    if (!_videoCallButton) {
        _videoCallButton = [UIButton new];
        [_videoCallButton setImage:[UIImage imageNamed:@"ct_videoCall"]  forState:UIControlStateNormal];
        [_videoCallButton addTarget:self
                             action:@selector(videoCallClicked)
                   forControlEvents:UIControlEventTouchUpInside];
    }
    return  _videoCallButton;
}

- (void)videoCallClicked {
    if (_videoBlock) _videoBlock();
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self.badgeView setBackgroundColor:UIColor.clearColor];
}

- (void)setNeedsObject:(ContactObject *)object {
    [self setNameWith:object.contact.fullName];
    [self setAvatarImageUrl:object.contact.imageUrl];
    if (object.contact.subtitle) {
        [self setSubtitleWith:object.contact.subtitle];
    }
    
}

+ (CGFloat)heightForRowWithObject:(CellObject *)object {
    return 60;
}

@end

