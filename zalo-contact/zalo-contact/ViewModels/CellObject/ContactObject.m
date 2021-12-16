//
//  ContactObject.m
//  zalo-contact
//
//  Created by Thiện on 29/11/2021.
//

#import "ContactObject.h"

@implementation ContactObject

- (instancetype)initWithContactEntity:(ContactEntity *)contact {
    self = [super initWithCellClass:[ContactCell class]];
    _contact = contact;
    return self;
}

- (BOOL)isEqual:(id)object {
    ContactObject *contact = (ContactObject *)object;
    if (!contact) {
        return NO;
    }
    if ([contact isKindOfClass:ContactObject.class]) {
    return [self.contact compare:contact.contact] == NSOrderedSame;
    }
    return NO;
}

- (NSComparisonResult)compare:(ContactObject *)object {
    ContactObject *contact = (ContactObject *)object;
    if (!contact) {
        return NO;
    }
    return [self.contact compare:contact.contact];
}

- (NSComparisonResult)compareToSearch:(ContactObject *)object {
    NSComparisonResult res;
    if ([self.contact.accountId compare:object.contact.accountId] == NSOrderedSame) return NSOrderedSame;
    
    res = [self.contact.lastName compare:object.contact.lastName];
    if ( res != NSOrderedSame) {
        return res;
    }
    
    res = [self.contact.firstName compare:object.contact.firstName];
    if ( res != NSOrderedSame) {
        return res;
    }

    res = [self.contact.phoneNumber compare:object.contact.phoneNumber];
    if ( res != NSOrderedSame) {
        return res;
    }

    return [self.contact.accountId compare:object.contact.accountId];
}

@end


