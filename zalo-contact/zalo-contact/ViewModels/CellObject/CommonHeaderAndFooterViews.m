//
//  CommonHeaderAndFooterViews.m
//  zalo-contact
//
//  Created by Thiện on 30/11/2021.
//

#import "CommonHeaderAndFooterViews.h"

@implementation BlankFooterObject

- (instancetype)init {
    self = [super initWithFooterClass:BlankFooterView.class];
    return self;
}

@end

@implementation ContactFooterObject

- (instancetype)init {
    self = [super initWithFooterClass:ContactFooterView.class];
    return self;
}

@end


@implementation ShortHeaderObject

- (instancetype)init {
    self = [super initWithHeaderClass:HeaderView.class];
    return self;
}

- (instancetype)initWithTitle:(NSString *)title {
    self = self.init;
    self.title = title;
    return self;
}

- (instancetype)initWithTitle:(NSString *)title andTitleLetter:(NSString *)letter{
    self = self.init;
    self.title = title;
    self.letterTitle = letter;
    return self;
}

@end

@implementation LabelHeaderObject

- (instancetype)init {
    self = [super initWithCellClass:LabelViewCell.class];
    return self;
}

- (instancetype)initWithTitle:(NSString *)title {
    self = self.init;
    self.title = title;
    self.alignment = NSTextAlignmentLeft;
    return self;
}

- (instancetype)initWithTitle:(NSString *)title andTextAlignment:(NSTextAlignment)alignment {
    self = [self initWithTitle:title];
    self.alignment = alignment;
    return self;
}

@end


@implementation NullHeaderObject

- (instancetype)init {
    self = [super initWithHeaderClass:NullHeaderView.class];
    return self;
}

- (instancetype)initWithLeter:(NSString *)letter {
    self = [super initWithHeaderClass:NullHeaderView.class];
    self.letterTitle = letter;
    return self;
}

@end

@implementation NullFooterObject

- (instancetype)init {
    self = [super initWithFooterClass:NullFooterView.class];
    return self;
}

@end

@implementation ActionHeaderObject

- (instancetype)initWithTitle:(NSString *)title andButtonTitle:(NSString *)btnTitle {
    self = [super initWithHeaderClass:ActionHeaderView.class];
    _title = title;
    _buttonTitle = btnTitle;
    return self;
}

@end
