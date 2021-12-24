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
    AccountMutableDictionary *newDict = self.accountDictionary.mutableCopy;
    AccountMutableDictionary *oldDict = self.oldAccountDictionary.mutableCopy;
    
    NSMutableSet *addSet = [NSMutableSet setWithArray:newDict.allKeys];
    [addSet  minusSet:[NSSet setWithArray:oldDict.allKeys]];
    
    NSMutableSet *removeSet = [NSMutableSet setWithArray:oldDict.allKeys];
    [removeSet  minusSet:[NSSet setWithArray:newDict.allKeys]];
    
    NSMutableSet *updateSet = [NSMutableSet setWithArray:newDict.allKeys];
    [updateSet minusSet:addSet];
    
    dispatch_async(self.contactServiceStorageQueue, ^{
        for (NSString *accountId in removeSet) [[ContactDataManager sharedInstance] deleteContactFromData:accountId];
        for (NSString *accountId in addSet) [[ContactDataManager sharedInstance] addContactToData:newDict[accountId]];
        for (NSString *accountId in updateSet.copy) {
            if (oldDict[accountId].diffHash != newDict[accountId].diffHash) {
                [[ContactDataManager sharedInstance] updateContactInData:newDict[accountId]];
            }
        }
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
