//
//  UpdateContactCell.m
//  zalo-contact
//
//  Created by Thiện on 08/12/2021.
//

#import "UpdateContactCell.h"

@interface UpdateContactCell ()

@property (nonatomic, strong) UIButton *button;

@end

@implementation UpdateContactCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    [self commonInit];
    return self;
}

- (void)commonInit {
    [self setSelectionStyle:(UITableViewCellSelectionStyleNone)];
    [self setBackgroundColor:UIColor.zaloLightGrayColor];
    [self.contentView addSubview:self.button];
}

- (void)setButtonTitle:(NSString *)title {
    [self.button setTitle:title forState:(UIControlStateNormal)];
}

- (UIButton *)button {
    if (!_button) {
        _button = [UIButton.alloc init];
        [_button setBackgroundColor:UIColor.zaloPrimaryColor];
        [_button.layer setCornerRadius:UIConstants.addContactButtonHeight / 2];
        [_button setClipsToBounds:YES];
        [_button.titleLabel setFont:[UIFont systemFontOfSize:UIConstants.contactHeaderFontSize weight:(UIFontWeightMedium)]];
        [_button.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [_button addTarget:self
                          action:@selector(didClick)
                forControlEvents:UIControlEventTouchUpInside];
    }
    return _button;
}

- (void)didClick {
    if (_action) _action();
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect newFrame = CGRectZero;
    newFrame.size = CGSizeMake(self.bounds.size.width / 2, UIConstants.addContactButtonHeight);
    
    [_button setFrame:newFrame];
    _button.center = CGPointMake(self.bounds.size.width / 2, _button.center.y);

}

- (void)setNeedsObject:(UpdateContactObject *)object {
    [self setButtonTitle:object.title];
    [self setAction:object.actionBlock];
}

+ (CGFloat)heightForRowWithObject:(nonnull CellObject *)object {
    return UIConstants.addContactButtonHeight + 20;
}

@end
