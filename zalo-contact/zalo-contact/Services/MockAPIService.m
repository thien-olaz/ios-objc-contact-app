//
//  APIService.m
//  zalo-contact
//
//  Created by Thiện on 06/12/2021.
//

#import "MockAPIService.h"
#import "NSStringExt.h"
#import "ContactEntityAdapter.h"

@implementation MockAPIService {
    NSArray<CNContact *> *contactsPool;
    NSArray<CNContact *> *fixedContactsPool;
    
    int addIndex;
    int deleteIndex;
}

@synthesize onContactUpdated;

@synthesize onContactAdded;

@synthesize onContactDeleted;

- (instancetype)init {
    self = super.init;
    [self getContactsFromFile];
//    [self mockDeleteContact];
    addIndex = 0;
    return self;
}

- (void)getContactsFromFile {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0ul), ^{
        if (!weakSelf) return;
        MockAPIService *strongSelf = weakSelf;
        NSString *filepath = [[NSBundle mainBundle] pathForResource:@"contacts" ofType:@"vcf"];
        NSError *error;
        NSString *fileContents = [NSString stringWithContentsOfFile:filepath encoding:NSUTF8StringEncoding error:&error];
        
        if (error) {
            LOG(error.description);
            return;
        }
        
        NSData *data = [fileContents dataUsingEncoding:NSUTF8StringEncoding];
        
        if (!strongSelf) return;
        
        strongSelf->contactsPool = [CNContactVCardSerialization contactsWithData:data error:&error];
        if (error) {
            LOG(error.description);
            return;
        }
        [strongSelf fakeServerUpdate];
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0ul), ^{
        if (!weakSelf) return;
        MockAPIService *strongSelf = weakSelf;
        NSString *filepath = [[NSBundle mainBundle] pathForResource:@"fixedContactsList" ofType:@"vcf"];
        NSError *error;
        NSString *fileContents = [NSString stringWithContentsOfFile:filepath encoding:NSUTF8StringEncoding error:&error];
        
        if (error) {
            LOG(error.description);
            return;
        }
        
        NSData *data = [fileContents dataUsingEncoding:NSUTF8StringEncoding];
        
        if (!strongSelf) return;
        
        strongSelf->fixedContactsPool = [CNContactVCardSerialization contactsWithData:data error:&error];
        if (error) {
            LOG(error.description);
            return;
        }
    });
    
}

// MARK: Fake a api request with 1 sec delay
- (void)fetchContacts:(OnData)block {
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0ul), ^{
        if (!weakSelf) return;
        MockAPIService *strongSelf = weakSelf;
        NSMutableArray<ContactEntity *> *apiContactsResult = NSMutableArray.new;
        for (CNContact *cnct in strongSelf->fixedContactsPool) {
            ContactEntityAdapter *entity = [ContactEntityAdapter.alloc initWithCNContact:cnct];
            [apiContactsResult addObject:entity];
        }
        block(apiContactsResult);
    });
    
}

- (void)fakeServerUpdate {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
//        [self addNewContact];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
//        [self deleteContact];
    });
}

- (void)addNewContact {
    if (!onContactAdded) return;
    
    if (addIndex < contactsPool.count) {
        ContactEntityAdapter *enity = [ContactEntityAdapter.alloc initWithCNContact:contactsPool[addIndex]];
        NSLog(@"%@", enity.fullName);
        onContactAdded(enity);
        addIndex += 1;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self addNewContact];
        });
    };
    
}

- (void)deleteContact {
    if (!onContactDeleted) return;
    
    if (deleteIndex < contactsPool.count) {
        ContactEntityAdapter *entity = [ContactEntityAdapter.alloc initWithCNContact:contactsPool[deleteIndex]];
        NSLog(@"%@", entity.fullName);
        onContactDeleted(entity);
        deleteIndex += 1;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self deleteContact];
        });
    };
    
}


@end
