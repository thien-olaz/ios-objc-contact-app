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

@end

@implementation ContactCell

@synthesize didSetupConstraints = _didSetupConstraints;

- (instancetype) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    [self addSubview:self.nameLabel];
    [self addSubview:self.avatarImageView];
    [self addSubview:self.callButton];
        
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
    
//    NSDate *start = [NSDate date];
    
    [[self.avatarImageView layer] setCornerRadius:25];
    [self.avatarImageView layer].masksToBounds = YES;
    [self.avatarImageView setImage:image];
    
//    NSDate *end = [NSDate date];
    
//    NSLog(@"time: %f", (end.timeIntervalSince1970 - start.timeIntervalSince1970) * 100000 );
    
}

- (void) updateConstraints {
    if (!self.didSetupConstraints) {
        
        [self.avatarImageView autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
        [self.avatarImageView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:20];
        [self.avatarImageView autoSetDimensionsToSize:CGSizeMake(50, 50)];
        
        [self.nameLabel autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
        [self.nameLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.avatarImageView withOffset:40];
        
        [self.callButton autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:20];
        [self.callButton autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
        [self.callButton autoSetDimensionsToSize:CGSizeMake(50, 50)];
        
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
 
- (UIImageView *) avatarImageView {
    if (!_avatarImageView) {
        _avatarImageView = [UIImageView new];
        _avatarImageView.backgroundColor = UIColor.clearColor;
    }
    return  _avatarImageView;
}

- (UIButton *) callButton {
    if (!_callButton) {
        _callButton = [UIButton new];
        [_callButton setImage:[UIImage imageNamed:@"ct_call"]  forState:UIControlStateNormal];
        //add call action
    }
    return  _callButton;
}

@end
