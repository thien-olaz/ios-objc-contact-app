//
//  HeaderFooterFactory.m
//  zalo-contact
//
//  Created by Thiện on 30/11/2021.
//

#import "HeaderFooterFactory.h"

@implementation HeaderFooterFactory

// Config header
- (UIView *)headerForTableViewWithObject:(HeaderObject *)object {
    UIView *header = object.headerClass.new;
    
    if ([header respondsToSelector:@selector(setNeedsObject:)]) {
        [(id<ZaloHeader>)header setNeedsObject:object];
    }
    
    return header;
}

// Config footer
- (UIView *)footerForTableViewWithObject:(FooterObject *)object {
    UIView *footer = object.footerClass.new;
    
    if ([footer respondsToSelector:@selector(setNeedsObject:)]) {
        [(id<ZaloFooter>)footer setNeedsObject:object];
    }
    
    return footer;
}

- (CGFloat)heightForHeaderWithObject:(HeaderObject *)object {
    Class headerClass = object.headerClass;
    if ([headerClass respondsToSelector:@selector(heightForHeaderWithObject:)]) {
        return [headerClass heightForHeaderWithObject:object];
    }
    return 0;
}


- (CGFloat)heightForFooterWithObject:(FooterObject *)object {
    Class footerClass = object.footerClass;
    if ([footerClass respondsToSelector:@selector(heightForFooterWithObject:)]) {
        return [footerClass heightForFooterWithObject:object];
    }
    return 0;
}

@end
