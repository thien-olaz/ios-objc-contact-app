//
//  FooterObject.m
//  zalo-contact
//
//  Created by Thiện on 29/11/2021.
//

#import "FooterObject.h"

@implementation FooterObject

- (instancetype)initWithFooterClass:(Class)footerClass {
    self = super.init;
    _footerClass = footerClass;
    return self;
}

@end
