//
//  APIService.m
//  zalo-contact
//
//  Created by Thiện on 06/12/2021.
//

#import "MockAPIService.h"
#import "NSStringExt.h"
#import "CNContactEntityAdapter.h"
#import "OnlineContactEntityAdapter.h"
#include <stdlib.h>

@implementation MockAPIService {
    NSArray<CNContact *> *defaultData;
    NSArray<CNContact *> *dataToPush;
    NSArray<CNContact *> *dataToDelete;
    NSArray<CNContact *> *dataToUpdate;
    NSArray<CNContact *> *dataToPushToOnlineGroup;
    CGFloat secDevideConstant;
    int addIndex;
    int deleteIndex;
    int updateIndex;
    int onlineIndex;
    int deleteOnlineIndex;
    int getTime;
}
@synthesize onOnlineContactAdded;

@synthesize onOnlineContactDeleted;

@synthesize onContactUpdated;

@synthesize onContactAdded;

@synthesize onContactDeleted;

@synthesize onOnlineContactUpdate;

@synthesize onContactUpdatedWithPhoneNumber;

- (instancetype)init {
    self = super.init;
    [self getContactsFromFile];
    deleteIndex = 0;
    addIndex = 0;
    updateIndex = 0;
    onlineIndex = 0;
    secDevideConstant = 200.0;
    getTime = 0;
    return self;
}

- (void)fakeServerUpdate {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0 * NSEC_PER_SEC), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0ul), ^{
        [self addNewContact];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0 * NSEC_PER_SEC), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0ul), ^{
        [self deleteContact];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0 * NSEC_PER_SEC), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0ul), ^{
        [self updateContact];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.4 * NSEC_PER_SEC), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0ul), ^{
        //       [self updateContactWithPhoneNumber];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 4 * NSEC_PER_SEC), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0ul), ^{
               [self pushOnlineContact];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 4 * NSEC_PER_SEC), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0ul), ^{
//               [self deleteOnlineContact];
    });
}

- (NSArray<CNContact *>*)getDataFromFile:(NSString *)fileName {
    NSString *filepath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"vcf"];
    NSError *error;
    NSString *fileContents = [NSString stringWithContentsOfFile:filepath encoding:NSUTF8StringEncoding error:&error];
    if (error) NSLog(@"%s %@", __PRETTY_FUNCTION__ ,error.description);
    NSData *data = [fileContents dataUsingEncoding:NSUTF8StringEncoding];
    return [CNContactVCardSerialization contactsWithData:data error:&error];
}

- (void)getContactsFromFile {
    __weak typeof(self) weakSelf = self;
    DISPATCH_ASYNC_IF_NOT_IN_QUEUE(GLOBAL_QUEUE, ^{
        if (!weakSelf) return;
        MockAPIService *strongSelf = weakSelf;
        if (!strongSelf) return;
//        super-short-contact
        strongSelf->defaultData = [strongSelf getDataFromFile:@"short-contacts"];
        strongSelf->dataToPush = [strongSelf getDataFromFile:@"medium-contacts"];
        strongSelf->dataToDelete = [strongSelf getDataFromFile:@"medium-contacts"];
        strongSelf->dataToUpdate = [strongSelf getDataFromFile:@"medium-contacts2"];
        
        strongSelf->dataToPushToOnlineGroup = [strongSelf getDataFromFile:@"medium-contacts"];
        
        [strongSelf fakeServerUpdate];
    });
}

// MARK: Fake a api request with 1 sec delay
- (void)fetchContacts:(OnData)successBlock onFailed:(ActionBlock)failBlock {
    getTime -= 1;
    if (getTime > 0) failBlock();
    else {
        __weak typeof(self) weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0ul), ^{
            if (!weakSelf) return;
            MockAPIService *strongSelf = weakSelf;
            
            NSMutableArray<ContactEntity *> *apiContactsResult = NSMutableArray.new;
            for (CNContact *cnct in strongSelf->defaultData) {
                CNContactEntityAdapter *entity = [CNContactEntityAdapter.alloc initWithCNContact:cnct];
                [apiContactsResult addObject:entity];
            }
            successBlock(apiContactsResult);
        });
    }
}


- (void)addNewContact {
    if (addIndex < dataToPush.count) {
        CNContactEntityAdapter *enity = [CNContactEntityAdapter.alloc initWithCNContact:dataToPush[addIndex]];
        //NSLog(@"☁️ Server:: ++ %@", enity.fullName);
        if (onContactAdded) onContactAdded(enity);
        addIndex += 1;
        int random = arc4random_uniform(300);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (random / secDevideConstant) * NSEC_PER_SEC), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0ul), ^{
            [self addNewContact];
        });
    };
}

- (void)deleteContact {
    if (deleteIndex < dataToDelete.count) {
        CNContactEntityAdapter *entity = [CNContactEntityAdapter.alloc initWithCNContact:dataToDelete[deleteIndex]];
        //NSLog(@"☁️ Server:: -- %@", entity.fullName);
        if (onContactDeleted) onContactDeleted(entity.accountId);
        deleteIndex += 1;
        int random = arc4random_uniform(300);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (random / secDevideConstant) * NSEC_PER_SEC), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0ul), ^{
            [self deleteContact];
        });
    };
}

- (void)updateContact {
    if (updateIndex < dataToUpdate.count) {
        CNContactEntityAdapter *enity = [CNContactEntityAdapter.alloc initWithCNContact:dataToUpdate[updateIndex]];
        //NSLog(@"☁️ Server:: ~~ %@", enity.fullName);
        if (onContactUpdated) onContactUpdated(enity);
        updateIndex += 1;
        int random = arc4random_uniform(300);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (random / secDevideConstant) * NSEC_PER_SEC), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0ul), ^{
            [self updateContact];
        });
    };
}

- (void)pushOnlineContact {
    if (onlineIndex < dataToPushToOnlineGroup.count) {
        OnlineContactEntityAdapter *contact = [[OnlineContactEntityAdapter alloc] initWithCNContact:dataToPushToOnlineGroup[onlineIndex]];
        
        [contact setOnlineTime:[NSDate date]];
        //NSLog(@"☁️ Server:: @@ %@", contact.fullName);
        
        if (onOnlineContactAdded) onOnlineContactAdded(contact);
        
        onlineIndex += 1;
        int random = arc4random_uniform(700);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (random / secDevideConstant) * NSEC_PER_SEC), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0ul), ^{
            [self pushOnlineContact];
        });
    };
}

- (void)deleteOnlineContact {
    if (deleteOnlineIndex < dataToPushToOnlineGroup.count) {
        OnlineContactEntityAdapter *contact = [[OnlineContactEntityAdapter alloc] initWithCNContact:dataToPushToOnlineGroup[deleteOnlineIndex]];
        
        [contact setOnlineTime:[NSDate date]];
        //NSLog(@"☁️ Server:: @@ %@", contact.fullName);
        
        if (onOnlineContactDeleted) onOnlineContactDeleted(contact);
        
        deleteOnlineIndex += 1;
        int random = arc4random_uniform(700);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (random / secDevideConstant) * NSEC_PER_SEC), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0ul), ^{
            [self deleteOnlineContact];
        });
    };
}


@end
