//
//  NullFooterView.m
//  zalo-contact
//
//  Created by Thiện on 09/12/2021.
//

#import "NullFooterView.h"

@implementation NullFooterView

+ (CGFloat)heightForFooterWithObject:(FooterObject *)object {
    return 0;
}

- (void)setNeedsObject:(nonnull FooterObject *)object {
    return;
}

@end
