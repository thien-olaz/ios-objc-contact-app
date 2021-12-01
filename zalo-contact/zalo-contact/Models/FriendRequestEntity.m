//
//  FriendRequest.m
//  zalo-contact
//
//  Created by Thiện on 16/11/2021.
//

#import "FriendRequestEntity.h"

@implementation FriendRequestEntity
- (id)init {
    return [self initWithFirstName: @""
                          lastName: @""
                       phoneNumber: @""
                       receiveDate: [NSDate date]
                      requestTyppe: @""];
}

- (id)initWithFirstName:(NSString *)firstName
               lastName:(NSString *)lastName
            phoneNumber:(NSString *)phoneNumber
            receiveDate:(NSDate *)date
           requestTyppe:(NSString *)type {
    self = super.init;
    _fistName = firstName;
    _lastName = lastName;
    _phoneNumber = phoneNumber;
    _receiveDate = date;
    _requestType = type;
    // created when receiving a new request, always not viewed yet
    _viewed = NO;
    
    return self;
}

@end
