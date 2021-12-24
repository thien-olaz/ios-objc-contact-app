//
//  ContactAdapter.m
//  zalo-contact
//
//  Created by Thiện on 17/11/2021.
//

#import "CNContactEntityAdapter.h"

@interface CNContactEntityAdapter ()
@property CNContact *contact;
@end

@implementation CNContactEntityAdapter

- (id)initWithCNContact:(CNContact *)contact {
    
    NSString *pn = @"";
    BOOL hasPhoneNumber = 0 < [contact.phoneNumbers count] ? YES : NO;
    if (hasPhoneNumber) {
        pn = ((CNPhoneNumber *)contact.phoneNumbers[0].value).stringValue;
    }
    NSString *email = @"";
    if (contact.emailAddresses.count) {
        email = contact.emailAddresses[0].value;
    }
    
    self = [super initWithAccountId:pn firstName:contact.givenName lastName:contact.familyName phoneNumber:pn subtitle:nil email:email];
    
    self.contact = contact;
    
    return self;
}

@end
