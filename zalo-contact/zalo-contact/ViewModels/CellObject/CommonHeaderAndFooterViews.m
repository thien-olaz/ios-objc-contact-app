//
//  CommonHeaderAndFooterViews.m
//  zalo-contact
//
//  Created by Thiện on 30/11/2021.
//

#import "CommonHeaderAndFooterViews.h"

@implementation BlankFooterObject

- (instancetype)init {
    self = [super initWithFooterClass:BlankFooterCell.class];
    return self;
}

@end


@implementation ShortHeaderObject

- (instancetype)init {
    self = [super initWithHeaderClass:HeaderCell.class];
    return self;
}

- (instancetype)initWithTitle:(NSString *)title {
    self = self.init;
    _title = title;
    return self;
}

@end

@implementation NullHeaderObject
- (instancetype)init {
    self = [super initWithHeaderClass:NullHeaderView.class];
    return self;
}
@end
