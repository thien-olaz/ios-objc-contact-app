//
//  ContactFooterView.m
//  zalo-contact
//
//  Created by Thiện on 07/12/2021.
//

#import "ContactFooterView.h"

@implementation ContactFooterView {
    UIView *separateLine;
}

- (instancetype)init {
    self = [super init];
    
    separateLine = [UIView.alloc initWithFrame:self.bounds];
    [separateLine setBackgroundColor: UIColor.zaloLightGrayColor];
    [self addSubview:separateLine];
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    separateLine.frame = CGRectInset(self.bounds, 20, 0);
}

+ (CGFloat)heightForFooterWithObject:(FooterObject *)object {
    return 1;
}

- (void)setNeedsObject:(nonnull FooterObject *)object {
    return;
}

@end
