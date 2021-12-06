//
//  ContactAdapter.m
//  zalo-contact
//
//  Created by Thiện on 17/11/2021.
//

#import "ContactEntityAdapter.h"

@interface ContactEntityAdapter ()
@property CNContact *contact;
@end

@implementation ContactEntityAdapter

- (id)initWithCNContact:(CNContact *)contact {
    
    NSString *pn = @"";
    BOOL hasPhoneNumber = 0 < [contact.phoneNumbers count] ? YES : NO;
    if (hasPhoneNumber) {
        pn = ((CNPhoneNumber *)contact.phoneNumbers[0].value).stringValue;
    }
    
    self = [super initWithFirstName:contact.givenName lastName:contact.familyName phoneNumber:pn];
    _contact = contact;
    return self;
}

@end
