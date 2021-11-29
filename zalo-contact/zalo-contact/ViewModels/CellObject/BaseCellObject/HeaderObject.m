//
//  HeaderObject.m
//  zalo-contact
//
//  Created by Thiện on 29/11/2021.
//

#import "HeaderObject.h"

@implementation HeaderObject

- (instancetype)initWithHeaderClass:(Class)headerClass {
    self = super.init;
    _headerClass = headerClass;
    return self;
}

@end
