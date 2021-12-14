//
//  APIService.m
//  zalo-contact
//
//  Created by Thiện on 06/12/2021.
//

#import "MockAPIService.h"
#import "NSStringExt.h"
#import "ContactEntityAdapter.h"
#include <stdlib.h>

@implementation MockAPIService {
    NSArray<CNContact *> *defaultData;
    NSArray<CNContact *> *dataToPush;
    NSArray<CNContact *> *dataToDelete;
    NSArray<CNContact *> *dataToUpdate;
    
    int addIndex;
    int deleteIndex;
    int updateIndex;
}

@synthesize onContactUpdated;

@synthesize onContactAdded;

@synthesize onContactDeleted;

@synthesize onContactUpdatedWithPhoneNumber;

- (instancetype)init {
    self = super.init;
    [self getContactsFromFile];
    deleteIndex = 0;
    addIndex = 0;
    updateIndex = 0;
    return self;
}

// MARK: - Race condition
- (void)fakeServerUpdate {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0ul), ^{
        [self addNewContact];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 4 * NSEC_PER_SEC), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0ul), ^{        
//        [self deleteContact];
    });

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 4 * NSEC_PER_SEC), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0ul), ^{
        [self updateContact];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.4 * NSEC_PER_SEC), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0ul), ^{
//        [self updateContactWithPhoneNumber];
    });
}

- (NSArray<CNContact *>*)getDataFromFile:(NSString *)fileName {
    NSString *filepath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"vcf"];
    NSError *error;
    NSString *fileContents = [NSString stringWithContentsOfFile:filepath encoding:NSUTF8StringEncoding error:&error];
    if (error) LOG(error.description);
    NSData *data = [fileContents dataUsingEncoding:NSUTF8StringEncoding];
    return [CNContactVCardSerialization contactsWithData:data error:&error];
}

- (void)getContactsFromFile {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0ul), ^{
        if (!weakSelf) return;
        MockAPIService *strongSelf = weakSelf;
        if (!strongSelf) return;
        
        strongSelf->defaultData = [strongSelf getDataFromFile:@"normal-contacts"];
        strongSelf->dataToPush = [strongSelf getDataFromFile:@"medium-contacts"];
        strongSelf->dataToDelete = [strongSelf getDataFromFile:@"medium-contacts"];
        strongSelf->dataToUpdate = [strongSelf getDataFromFile:@"normal-contacts2"];
        [strongSelf fakeServerUpdate];
    });

}

// MARK: Fake a api request with 1 sec delay
- (void)fetchContacts:(OnData)block {
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0ul), ^{
        if (!weakSelf) return;
        MockAPIService *strongSelf = weakSelf;
               
        NSMutableArray<ContactEntity *> *apiContactsResult = NSMutableArray.new;
        for (CNContact *cnct in strongSelf->defaultData) {
            ContactEntityAdapter *entity = [ContactEntityAdapter.alloc initWithCNContact:cnct];
            [apiContactsResult addObject:entity];
        }
        block(apiContactsResult);
    });
    
}


- (void)addNewContact {
    if (!onContactAdded) return;
    
    if (addIndex < dataToPush.count) {
        ContactEntityAdapter *enity = [ContactEntityAdapter.alloc initWithCNContact:dataToPush[addIndex]];
        NSLog(@"++ %@", enity.fullName);
        onContactAdded(enity);
        addIndex += 1;
        int random = arc4random_uniform(20);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (random / 10.0) * NSEC_PER_SEC), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0ul), ^{
            [self addNewContact];
        });
    };
}

- (void)deleteContact {
    if (!onContactDeleted) return;
    
    if (deleteIndex < dataToDelete.count) {
        ContactEntityAdapter *entity = [ContactEntityAdapter.alloc initWithCNContact:dataToDelete[deleteIndex]];
        NSLog(@"-- %@", entity.fullName);
        onContactDeleted(entity.phoneNumber);
        deleteIndex += 1;
        int random = arc4random_uniform(50);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (2 + random / 10.0) * NSEC_PER_SEC), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0ul), ^{
            [self deleteContact];
        });
    };
}

- (void)updateContact {
    if (!onContactUpdated) return;
    
    if (updateIndex < dataToUpdate.count) {
        ContactEntityAdapter *enity = [ContactEntityAdapter.alloc initWithCNContact:dataToUpdate[updateIndex]];
        NSLog(@"~~ %@", enity.fullName);
        onContactUpdated(enity);
        updateIndex += 1;
        int random = arc4random_uniform(20);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (random / 10.0) * NSEC_PER_SEC), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0ul), ^{
            [self updateContact];
        });
    };
}

@end
