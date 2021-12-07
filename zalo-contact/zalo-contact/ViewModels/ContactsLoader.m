//
//  ContactsLoader.m
//  zalo-contact
//
//  Created by LAp14886 on 15/11/2021.
//

#import "ContactsLoader.h"
#import "ContactEntity.h"
#import "ZaloContactService.h"
@import IGListKit;

extern int repeatTime = 0;

@implementation ContactsLoader {
    NSArray<ContactGroupEntity *> *_contactGroups;
    NSMutableDictionary<NSString*, NSArray<ContactEntity*>*> *currentContacts;
}

#warning @"Make sure this function call after the permission checking in vm"

@end



