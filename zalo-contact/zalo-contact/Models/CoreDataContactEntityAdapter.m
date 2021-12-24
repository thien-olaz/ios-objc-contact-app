//
//  CoreDataContactEntityAdapter.m
//  zalo-contact
//
//  Created by Thiện on 24/12/2021.
//

#import "CoreDataContactEntityAdapter.h"

@interface CoreDataContactEntityAdapter ()
@property Contact *ct;
@end

@implementation CoreDataContactEntityAdapter

- (id)initWithContact:(Contact *)contact {
    self = [super initWithAccountId:contact.accountId firstName:contact.firstName lastName:contact.lastName phoneNumber:contact.phoneNumber subtitle:contact.subtitle email:contact.email];
    self.ct = contact;
    return self;
}

@end
