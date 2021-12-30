//
//  ZaloContactService+Storage.m
//  zalo-contact
//
//  Created by Thiện on 10/12/2021.
//

#import "ZaloContactService+Storage.h"
#import "ZaloContactService+Private.h"
#import "ContactDataManager.h"

@interface ZaloContactService (Storage) <ContactDataErrorManager>

@end

@implementation ZaloContactService (Storage)

- (void)setUpStorageErrorHandler {
    [[ContactDataManager sharedInstance] setErrorManager:self];
}

- (void)saveFull {
    AccountMutableDictionary *newDict = self.accountDictionary.mutableCopy;
    AccountMutableDictionary *oldDict = self.oldAccountDictionary.mutableCopy;
    
    NSMutableSet *addSet = [NSMutableSet setWithArray:newDict.allKeys];
    [addSet  minusSet:[NSSet setWithArray:oldDict.allKeys]];
    
    NSMutableSet *removeSet = [NSMutableSet setWithArray:oldDict.allKeys];
    [removeSet  minusSet:[NSSet setWithArray:newDict.allKeys]];
    
    NSMutableSet *updateSet = [NSMutableSet setWithArray:newDict.allKeys];
    [updateSet minusSet:addSet];

    DISPATCH_ASYNC_IF_NOT_IN_QUEUE(self.contactServiceStorageQueue, ^{
        for (NSString *accountId in removeSet) [[ContactDataManager sharedInstance] deleteContactFromData:accountId];
        for (NSString *accountId in addSet) [[ContactDataManager sharedInstance] addContactToData:newDict[accountId]];
        for (NSString *accountId in updateSet.copy) {
            if (oldDict[accountId].diffHash != newDict[accountId].diffHash) {
                [[ContactDataManager sharedInstance] updateContactInData:newDict[accountId]];
            }
        }
    });
}

// báo lại cho server lưu được hay chưa
- (void)saveAdd:(ContactEntity *)contact {
    DISPATCH_ASYNC_IF_NOT_IN_QUEUE(self.contactServiceStorageQueue, ^{
        [[ContactDataManager sharedInstance] addContactToData:contact];
    });
}

// báo lại cho server lưu được hay chưa
- (void)saveUpdate:(ContactEntity *)contact {
    DISPATCH_ASYNC_IF_NOT_IN_QUEUE(self.contactServiceStorageQueue, ^{
        [[ContactDataManager sharedInstance] updateContactInData:contact];
    });
}

// báo lại cho server lưu được hay chưa
- (void)saveDelete:(NSString *)accountId {
    DISPATCH_ASYNC_IF_NOT_IN_QUEUE(self.contactServiceStorageQueue, ^{
        [[ContactDataManager sharedInstance] deleteContactFromData:accountId];
    });
}

/// This function will be called when data save failed
/// param is a list of failed to save contact
- (void)onStorageError:(NSArray*)failedToSaveContactArray {
    NSLog(@"onStorageError");
    NSLog(@"%@",failedToSaveContactArray);
}

@end

