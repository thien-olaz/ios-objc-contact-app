//
//  Contact.m
//  zalo-contact
//
//  Created by LAp14886 on 15/11/2021.
//

#import "Contact.h"

@interface Contact ()

@property NSString *firstName;
@property NSString *lastName;
@property NSString *phoneNumber;
@end
@implementation Contact

- (id) init {
    return [self initWithFirstName:@"" lastName:@"" phoneNumber:@""];
}

- (id) initWithFirstName:(NSString *)firstName
                lastName:(NSString *)lastName
    phoneNumber:(NSString *)phoneNumber {
    self = super.init;
    _header = lastName && lastName.length > 0 ? [lastName substringToIndex:1] : [firstName substringToIndex:1];
    
    _firstName = firstName;
    _lastName = lastName;
    _phoneNumber = phoneNumber;
    return self;
}

- (NSString *) fullName {
    return [NSString stringWithFormat:@"%@ %@", _lastName, _firstName];
}

- (NSString *) phoneNumber{
    return _phoneNumber;
}

@end
