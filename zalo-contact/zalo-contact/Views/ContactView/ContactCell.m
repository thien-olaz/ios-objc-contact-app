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
@property (nonatomic, strong) UIButton *callButton;
@property (nonatomic, strong) UIButton *videoCallButton;
@property (nonatomic, strong) UIView *newFriendMarkView;

@end

@implementation ContactCell

@synthesize didSetupConstraints = _didSetupConstraints;

- (instancetype) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    [self addSubview:self.nameLabel];
    [self addSubview:self.avatarImageView];
    [self addSubview:self.callButton];
    [self addSubview:self.videoCallButton];
    [self addSubview:self.newFriendMarkView];
    
    [self setNeedsUpdateConstraints];
    
    return self;
}

- (void) setNameWith:(NSString *)name {
    [self.nameLabel setText:name];
}

- (void) setAvatarImage:(nonnull UIImage*)image {
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

- (void) setAvatarImageUrl:(NSString * __nullable)url {
    if (url) {
        [_avatarImageView sd_setImageWithURL: [NSURL.alloc initWithString:url] placeholderImage:[UIImage imageNamed:@"ct_avt_placeholder"]];
    } else {
        UIImage *placeholderImage = [UIImage imageNamed:@"ct_avt_placeholder"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->_avatarImageView setImage: placeholderImage];
        });
    }
}

- (void) updateConstraints {
    if (!self.didSetupConstraints) {
        
        [self.avatarImageView autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
        [self.avatarImageView autoPinEdgeToSuperviewEdge:ALEdgeLeft
                                               withInset:UIConstants.contactCellMinHorizontalInset];
        [self.avatarImageView autoSetDimensionsToSize:UIConstants.contactCellAvatarSize];
        
        
        [self.nameLabel autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
        [self.nameLabel autoPinEdge:ALEdgeLeft
                             toEdge:ALEdgeRight
                             ofView:self.avatarImageView
                         withOffset:UIConstants.contactMinHorizontalSpacing];
        
        [self.newFriendMarkView autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
        [self.newFriendMarkView autoPinEdge:ALEdgeLeft
                                     toEdge:ALEdgeRight
                                     ofView:self.nameLabel
                                 withOffset:UIConstants.contactMinHorizontalSpacing];
        
        [self.callButton autoPinEdgeToSuperviewEdge:ALEdgeRight
                                          withInset:UIConstants.contactCellMinHorizontalInset];
        [self.callButton autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
        [self.callButton autoSetDimensionsToSize:UIConstants.contactCellButtonSize];
        
        [self.videoCallButton autoPinEdge:ALEdgeRight toEdge:ALEdgeLeft ofView:self.callButton];
        [self.videoCallButton autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
        [self.videoCallButton autoSetDimensionsToSize:UIConstants.contactCellButtonSize];
        
        self.didSetupConstraints = YES;
    }
    [super updateConstraints];
}

- (UILabel *) nameLabel {
    if (!_nameLabel) {
        _nameLabel = [UILabel new];
    }
    return _nameLabel;
}

- (UIView *) newFriendMarkView {
    if (!_newFriendMarkView) {
        _newFriendMarkView = [UIView new];
        [_newFriendMarkView setBackgroundColor:UIColor.grayColor];
        [_newFriendMarkView.layer setCornerRadius:5];
        
        UILabel *label = UILabel.new;
        [label setText:@"Mới"];
        [label setTextColor:UIColor.neonGreen];
        
        UIImageView *icon = [UIImageView new];
        icon.image =  [[UIImage imageNamed:@"tb_user"]
                       imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [icon setTintColor:UIColor.neonGreen];
        
        [_newFriendMarkView addSubview:icon];
        [_newFriendMarkView addSubview:label];
        
        [label autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(2, 6, 2, 0) excludingEdge:ALEdgeRight];
        
        [icon autoSetDimensionsToSize:CGSizeMake(20, 20)];
        [icon autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:label withOffset:6];
        [icon autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
        [icon autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:6];
        
    }
    return _newFriendMarkView;
}

- (UIImageView *) avatarImageView {
    if (!_avatarImageView) {
        _avatarImageView = [UIImageView new];
        _avatarImageView.backgroundColor = UIColor.clearColor;
        [[_avatarImageView layer] setCornerRadius:UIConstants.cornerRadius];
        [_avatarImageView layer].masksToBounds = YES;
    }
    return  _avatarImageView;
}

- (UIButton *) callButton {
    if (!_callButton) {
        _callButton = [UIButton new];
        [_callButton setImage:[UIImage imageNamed:@"ct_call"]  forState:UIControlStateNormal];
        //add action
    }
    return  _callButton;
}

- (UIButton *) videoCallButton {
    if (!_videoCallButton) {
        _videoCallButton = [UIButton new];
        [_videoCallButton setImage:[UIImage imageNamed:@"ct_videoCall"]  forState:UIControlStateNormal];
        //add action
    }
    return  _videoCallButton;
}
@end
