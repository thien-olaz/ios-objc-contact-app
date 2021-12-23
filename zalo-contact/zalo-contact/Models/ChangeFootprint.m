//
//  ContactChangeEntity.m
//  zalo-contact
//
//  Created by Thiện on 20/12/2021.
//

#import "ChangeFootprint.h"

@implementation ChangeFootprint

+ (instancetype)initChangeBy:(NSString *)accountId {
    ChangeFootprint *change = [[ChangeFootprint alloc] initWithAccountId:accountId andUpdateTime:[NSDate now]];
    return change;
}

- (instancetype)initWithAccountId:(NSString *)accountId andUpdateTime:(NSDate *)date {
    self = [super init];
    self.date = date;
    self.accountId = accountId;
    return self;
}

- (BOOL)isEqual:(id)object {
    ChangeFootprint *entity = (ChangeFootprint *)object;
    if (!entity) return NO;
    return [self.accountId isEqual:entity.accountId];
}

- (NSUInteger)hash {
    return @(self.accountId.hash).unsignedIntValue;
}

@end
