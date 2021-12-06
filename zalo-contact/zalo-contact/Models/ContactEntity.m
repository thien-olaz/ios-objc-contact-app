//
//  ContactEntity.m
//  zalo-contact
//
//  Created by LAp14886 on 15/11/2021.
//

#import "ContactEntity.h"

@interface ContactEntity ()

@property NSString *firstName;
@property NSString *lastName;
@property (nonatomic) NSString *phoneNumber;
@property (nullable) NSString *imageUrl;
@end

@implementation ContactEntity

- (id)init {
    return [self initWithFirstName:@"" lastName:@"" phoneNumber:@""];
}

- (id)initWithFirstName:(NSString *)firstName
               lastName:(NSString *)lastName
            phoneNumber:(NSString *)phoneNumber {
    self = super.init;
    _firstName = firstName;
    _lastName = lastName;
    _phoneNumber = phoneNumber;
    return self;
}

- (id)initWithFirstName:(NSString *)firstName
               lastName:(NSString *)lastName
            phoneNumber:(NSString *)phoneNumber
               imageUrl:(NSString *)url {
    self = [self initWithFirstName:firstName lastName:lastName phoneNumber:phoneNumber];
    _imageUrl = url;
    return self;
}

- (NSString *)fullName {
    return [NSString stringWithFormat:@"%@ %@", _lastName, _firstName];
}

- (NSString *)lastName {
    return _lastName;
}

- (NSString *)phoneNumber{
    return _phoneNumber;
}

- (NSString *)header{
    return _lastName && _lastName.length > 0 ? [_lastName substringToIndex:1] : [_firstName substringToIndex:1];
}

- (NSString * __nullable)imageUrl {
    return _imageUrl;
}

#pragma mark - NSSecureEncoding

- (instancetype)initWithCoder:(NSCoder *)coder {
    NSString *firstName = [coder decodeObjectForKey:@"fname"];
    NSString *lastName = [coder decodeObjectForKey:@"lname"];
    NSString *phoneNumber = [coder decodeObjectForKey:@"pnumber"];
    NSString *imageUrl = [coder decodeObjectForKey:@"imageUrl"];
    return [self initWithFirstName:firstName lastName:lastName phoneNumber:phoneNumber imageUrl:imageUrl];
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:_firstName forKey:@"fname"];
    [coder encodeObject:_lastName forKey:@"lname"];
    [coder encodeObject:_phoneNumber forKey:@"pnumber"];
    [coder encodeObject:_imageUrl forKey:@"imageUrl"];
}

+ (BOOL)supportsSecureCoding {
   return YES;
}

#pragma mark - IGListDiffable

- (id<NSObject>)diffIdentifier {
    return @(self.fullName.hash);
}

- (BOOL)isEqualToDiffableObject:(id<IGListDiffable>)object {
    ContactEntity *entity = (ContactEntity *)object;
    if (!entity) return NO;
    if (![self.firstName isEqualToString:entity.firstName]) return NO;
    if (![self.lastName isEqualToString:entity.lastName]) return NO;
    if (![self.phoneNumber isEqualToString:entity.phoneNumber]) return NO;
    
    return YES;
}

#pragma mark - Equal
- (NSComparisonResult)compare:(ContactEntity *)entity {
    NSComparisonResult res;
    res = [self.lastName compare:entity.lastName];
    if ( res != NSOrderedSame) {
        return res;
    }
    res = [self.firstName compare:entity.firstName];
    if ( res != NSOrderedSame) {
        return res;
    }
//    res = [self.phoneNumber compare:entity.phoneNumber];
//    if ( res != NSOrderedSame) {
//        return res;
//    }
    return NSOrderedSame;
}
@end
