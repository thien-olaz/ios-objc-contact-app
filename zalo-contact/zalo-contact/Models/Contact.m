//
//  Contact.m
//  zalo-contact
//
//  Created by LAp14886 on 15/11/2021.
//

#import "Contact.h"

@implementation Contact

- (id) init {
    return [self initWith:@"" phoneNumber:@""];
}

- (id) initWith:(NSString *)name
    phoneNumber:(NSString *)phoneNumber {
    self = super.init;
    _name = name;
    _phoneNumber = phoneNumber;
    return self;
}

@end
