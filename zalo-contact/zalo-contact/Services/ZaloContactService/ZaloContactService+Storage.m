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
    LOG(@"Save full list of data");
    LOG2(@"old count %lu", (unsigned long)oldDict.count);
    LOG2(@"new count %lu", (unsigned long)newDict.count);
    LOG2(@"add count %lu", (unsigned long)addSet.count);
    LOG2(@"remove count %lu", (unsigned long)removeSet.count);
    
    DISPATCH_ASYNC_IF_NOT_IN_QUEUE(self.contactServiceStorageQueue, ^{
        for (NSString *accountId in removeSet) [[ContactDataManager sharedInstance] deleteContactFromData:accountId];
        for (NSString *accountId in addSet) [[ContactDataManager sharedInstance] addContactToData:newDict[accountId]];
        int count = 0;
        for (NSString *accountId in updateSet.copy) {
            if (oldDict[accountId].diffHash != newDict[accountId].diffHash) {
                count++;
                [[ContactDataManager sharedInstance] updateContactInData:newDict[accountId]];
            }
        }
        LOG2(@"update count %d", count);
    });
}

- (void)saveAdd:(ContactEntity *)contact {
    DISPATCH_ASYNC_IF_NOT_IN_QUEUE(self.contactServiceStorageQueue, ^{
        [[ContactDataManager sharedInstance] addContactToData:contact];
    });
}

- (void)saveUpdate:(ContactEntity *)contact {
    DISPATCH_ASYNC_IF_NOT_IN_QUEUE(self.contactServiceStorageQueue, ^{
        [[ContactDataManager sharedInstance] updateContactInData:contact];
    });
}

- (void)saveDelete:(NSString *)accountId {
    DISPATCH_ASYNC_IF_NOT_IN_QUEUE(self.contactServiceStorageQueue, ^{
        [[ContactDataManager sharedInstance] deleteContactFromData:accountId];
    });
}

@end
