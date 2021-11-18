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
    
    contactsArray = [[NSMutableArray alloc] initWithArray: @[]];
    //sample data
    [contactsArray addObjectsFromArray:[[NSMutableArray alloc] initWithArray: @[
                [[Contact alloc] initWithFirstName:@"Thien"
                                          lastName:@"Nguyen"
                                       phoneNumber:@"0123456789"],
                [[Contact alloc] initWithFirstName:@"Thien"
                                          lastName:@"Ho"
                                       phoneNumber:@"0123456789"],
                [[Contact alloc] initWithFirstName:@"Tinh"
                                          lastName:@"Thien"
                                       phoneNumber:@"0123456789"],
                [[Contact alloc] initWithFirstName:@"Nhung"
                                          lastName:@"Ho"
                                       phoneNumber:@"0123456789"],
                [[Contact alloc] initWithFirstName:@"Van"
                                          lastName:@"Ho"
                                       phoneNumber:@"0123456789"],
                [[Contact alloc] initWithFirstName:@"Van"
                                          lastName:@"Le"
                                       phoneNumber:@"0123456789"],
            ]]];
    
    //add
    for (CNContact *contact in UserContacts.sharedInstance.getContactList) {
        [contactsArray addObject:[ContactAdapter.alloc initWithCNContact: contact]];
    }
    
///stress test the list
//    for (int i = 0; i < 10000; i++) {
//        [contactsArray addObjectsFromArray:[[NSMutableArray alloc] initWithArray: @[
//            [[Contact alloc] initWithFirstName:@"Thien"
//                                      lastName:@"Nguyen"
//                                   phoneNumber:@"0123456789"],
//            [[Contact alloc] initWithFirstName:@"Thien"
//                                      lastName:@"Ho"
//                                   phoneNumber:@"0123456789"],
//        ]]];
//    }

}

@end
