//
//  ZaloContactService+Storage.m
//  zalo-contact
//
//  Created by Thiện on 10/12/2021.
//

#import "ZaloContactService+Storage.h"
#import "ZaloContactService+Private.h"
#import "ContactDataController.h"

@interface ZaloContactService (Storage)

@end

@implementation ZaloContactService (Storage)

- (void)saveFull {
    dispatch_async(self.contactServiceStorageQueue, ^{
        [[ContactDataController sharedInstance] saveContactArrayToData:self.accountDictionary.allValues.copy];
    });
}

- (void)saveAdd:(ContactEntity *)contact {
    dispatch_async(self.contactServiceStorageQueue, ^{
        [[ContactDataController sharedInstance] addContactToData:contact];
    });
}

- (void)saveUpdate:(ContactEntity *)contact {
    dispatch_async(self.contactServiceStorageQueue, ^{
        [[ContactDataController sharedInstance] updateContactInData:contact];
    });
}

- (void)saveDelete:(NSString *)accountId {
    dispatch_async(self.contactServiceStorageQueue, ^{
        [[ContactDataController sharedInstance] deleteContactFromData:accountId];
    });
}

@end
