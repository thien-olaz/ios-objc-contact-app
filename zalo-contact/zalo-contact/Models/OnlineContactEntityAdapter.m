//
//  OnlineContactEntityAdapter.m
//  zalo-contact
//
//  Created by Thiện on 15/12/2021.
//

#import "OnlineContactEntityAdapter.h"

@interface OnlineContactEntityAdapter ()
@property CNContact *contact;
@end

@implementation OnlineContactEntityAdapter

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
