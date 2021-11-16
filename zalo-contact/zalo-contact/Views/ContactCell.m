//
//  ContactCell.m
//  zalo-contact
//
//  Created by Thiện on 16/11/2021.
//

#import "ContactCell.h"

@implementation ContactCell {
    UIImageView *avatarImgView;
    UILabel *nameLabel;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    nameLabel = [UILabel new];
    [self addSubview:nameLabel];
    return self;
}

- (void) setNameWith:(NSString *)name {
    [nameLabel setText:name];
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [nameLabel setFrame: self.bounds];
}

@end
