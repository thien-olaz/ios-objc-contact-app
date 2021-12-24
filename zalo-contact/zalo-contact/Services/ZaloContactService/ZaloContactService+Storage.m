//
//  ZaloContactService+Storage.m
//  zalo-contact
//
//  Created by Thiện on 10/12/2021.
//

#import "ZaloContactService+Storage.h"
#import "ZaloContactService+Private.h"
#import "ContactDataManager.h"

@interface ZaloContactService (Storage)

@end

@implementation ZaloContactService (Storage)

- (void)saveFull {
    dispatch_async(self.contactServiceStorageQueue, ^{
        [[ContactDataManager sharedInstance] saveContactArrayToData:self.accountDictionary.allValues.copy];
    });
}

- (void)saveAdd:(ContactEntity *)contact {
    dispatch_async(self.contactServiceStorageQueue, ^{
        [[ContactDataManager sharedInstance] addContactToData:contact];
    });
}

- (void)saveUpdate:(ContactEntity *)contact {
    dispatch_async(self.contactServiceStorageQueue, ^{
        [[ContactDataManager sharedInstance] updateContactInData:contact];
    });
}

- (void)saveDelete:(NSString *)accountId {
    dispatch_async(self.contactServiceStorageQueue, ^{
        [[ContactDataManager sharedInstance] deleteContactFromData:accountId];
    });
}

@end
