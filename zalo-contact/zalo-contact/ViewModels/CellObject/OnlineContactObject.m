//
//  OnlineContactObject.m
//  zalo-contact
//
//  Created by Thiện on 15/12/2021.
//

#import "OnlineContactObject.h"
#import "ContactCell.h"

@implementation OnlineContactObject

- (instancetype)initWithContactEntity:(OnlineContactEntity *)contact {
    self = [super initWithCellClass:[ContactCell class]];
    _contact = contact;
    return self;
}

- (BOOL)isEqual:(id)object {
    OnlineContactObject *contact = (OnlineContactObject *)object;
    if (!contact) {
        return NO;
    }
    if ([contact isKindOfClass:ContactObject.class]) {
    return [self.contact compare:contact.contact] == NSOrderedSame;
    }
    return NO;
}

- (NSComparisonResult)compare:(OnlineContactObject *)object {
    OnlineContactObject *contact = (OnlineContactObject *)object;
    return [self.contact compareTime:contact.contact];
}

- (NSComparisonResult)revertCompare:(OnlineContactObject *)object {
    OnlineContactObject *contact = (OnlineContactObject *)object;
    return [contact.contact compareTime:self.contact];
}

@end


