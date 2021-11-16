//
//  ContactsLoader.m
//  zalo-contact
//
//  Created by LAp14886 on 15/11/2021.
//

#import "ContactsLoader.h"
#import "../Models/Contact.h"

@implementation ContactsLoader

@synthesize contactsArray;

- (void) fetchContacts {
    contactsArray = [[NSMutableArray alloc] initWithArray: @[
        [[Contact alloc] initWith:@"Thien 1" phoneNumber:@"0123456789"],
        [[Contact alloc] initWith:@"Thien 2" phoneNumber:@"0123456789"],
        [[Contact alloc] initWith:@"Thien 1" phoneNumber:@"0123456789"],
        [[Contact alloc] initWith:@"Thien 2" phoneNumber:@"0123456789"],
        [[Contact alloc] initWith:@"Thien 1" phoneNumber:@"0123456789"],
        [[Contact alloc] initWith:@"Thien 2" phoneNumber:@"0123456789"],
        [[Contact alloc] initWith:@"Thien 1" phoneNumber:@"0123456789"],
        [[Contact alloc] initWith:@"Thien 2" phoneNumber:@"0123456789"],
        [[Contact alloc] initWith:@"Thien 1" phoneNumber:@"0123456789"],
        [[Contact alloc] initWith:@"Thien 2" phoneNumber:@"0123456789"],
        [[Contact alloc] initWith:@"Thien 1" phoneNumber:@"0123456789"],
        [[Contact alloc] initWith:@"Thien 2" phoneNumber:@"0123456789"],
        [[Contact alloc] initWith:@"Thien 1" phoneNumber:@"0123456789"],
        [[Contact alloc] initWith:@"Thien 2" phoneNumber:@"0123456789"],
        [[Contact alloc] initWith:@"Thien 1" phoneNumber:@"0123456789"],
        [[Contact alloc] initWith:@"Thien 2" phoneNumber:@"0123456789"],
        [[Contact alloc] initWith:@"Thien 1" phoneNumber:@"0123456789"],
        [[Contact alloc] initWith:@"Thien 2" phoneNumber:@"0123456789"],
        [[Contact alloc] initWith:@"Thien 1" phoneNumber:@"0123456789"],
        [[Contact alloc] initWith:@"Thien 2" phoneNumber:@"0123456789"],
    ]];
    NSLog(@"contects array %lu", (unsigned long)contactsArray.count);
}

@end
