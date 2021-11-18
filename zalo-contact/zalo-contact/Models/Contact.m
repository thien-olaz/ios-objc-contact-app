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
@property (nonatomic) NSString *phoneNumber;
@property (nullable) NSString *imageUrl;
@end

@implementation Contact

- (id) init {
    return [self initWithFirstName:@"" lastName:@"" phoneNumber:@""];
}

- (id) initWithFirstName:(NSString *)firstName
                lastName:(NSString *)lastName
             phoneNumber:(NSString *)phoneNumber {
    self = super.init;
    _firstName = firstName;
    _lastName = lastName;
    _phoneNumber = phoneNumber;
    return self;
}

- (id) initWithFirstName:(NSString *)firstName
                lastName:(NSString *)lastName
             phoneNumber:(NSString *)phoneNumber
                imageUrl:(NSString *)url {
    self = [self initWithFirstName:firstName lastName:lastName phoneNumber:phoneNumber];
    _imageUrl = url;
    return self;
}

- (NSString *) fullName {
    return [NSString stringWithFormat:@"%@ %@", _lastName, _firstName];
}

- (NSString *) phoneNumber{
    return _phoneNumber;
}

- (NSString *) header{
    return _lastName && _lastName.length > 0 ? [_lastName substringToIndex:1] : [_firstName substringToIndex:1];;
}

- (NSString * __nullable) imageUrl {
    return _imageUrl;
}

@end
