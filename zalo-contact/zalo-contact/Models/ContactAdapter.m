//
//  ContactAdapter.m
//  zalo-contact
//
//  Created by Thiện on 17/11/2021.
//

#import "ContactAdapter.h"

@interface ContactAdapter ()
@property CNContact *contact;
@end

@implementation ContactAdapter

-(id)initWithCNContact:(CNContact *)contact {
    self = [super initWithFirstName:contact.givenName lastName:contact.familyName phoneNumber:@""];
    _contact = contact;
    return self;
}

//just return the first appear phone number
- (NSString  * _Nullable) phoneNumber{
    for (CNLabeledValue<CNPhoneNumber*> *phoneNumber in _contact.phoneNumbers) {
        return phoneNumber.value.stringValue;
    }
    return nil;
}

@end
