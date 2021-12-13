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
    NSArray<CNContact *> *defaultData;
    NSArray<CNContact *> *dataToPush;
    NSArray<CNContact *> *dataToDelete;
    
    int addIndex;
    int deleteIndex;
    
    //
    BOOL isContact1;
    ContactEntity *contact1;
    ContactEntity *contact2;
}

@synthesize onContactUpdated;

@synthesize onContactAdded;

@synthesize onContactDeleted;

@synthesize onContactUpdatedWithPhoneNumber;

- (instancetype)init {
    self = super.init;
    [self getContactsFromFile];
    isContact1 = YES;
    [self configContact1and2];
    addIndex = 0;
    return self;
}

// MARK: - Race condition
- (void)fakeServerUpdate {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0ul), ^{
        [self addNewContact];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 4 * NSEC_PER_SEC), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0ul), ^{        
        [self deleteContact];
    });

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0ul), ^{
//        [self updateContact];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.4 * NSEC_PER_SEC), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0ul), ^{
//        [self updateContactWithPhoneNumber];
    });
}

- (void)configContact1and2 {
    contact1 = [ContactEntity.alloc initWithFirstName:@"Nguyễn" lastName:@"Thiện" phoneNumber:@"0123456789" subtitle:@"Subtitle 1"];
    
    contact2 = [ContactEntity.alloc initWithFirstName:@"Nguyễn" lastName:@"Thiện" phoneNumber:@"0123456789" subtitle:@"Subtitle 2"];
}

- (NSArray<CNContact *>*)getDataFromFile:(NSString *)fileName {
    NSString *filepath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"vcf"];

    NSError *error;
    NSString *fileContents = [NSString stringWithContentsOfFile:filepath encoding:NSUTF8StringEncoding error:&error];
    
    if (error) {
        LOG(error.description);
    }
    
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
        strongSelf->dataToDelete = [strongSelf getDataFromFile:@"normal-contacts"];
        
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
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0ul), ^{
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
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0ul), ^{
            [self deleteContact];
        });
    };
    
}

- (void)updateContact {
    if (!onContactUpdated) return;
    
//    use contact 2
    if (isContact1) {
        onContactUpdated(contact1, contact2);
    } else {
        onContactUpdated(contact2, contact1);
    }
    isContact1 = !isContact1;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0ul), ^{
        [self updateContact];
    });
}

- (void)updateContactWithPhoneNumber {
    if (!onContactUpdatedWithPhoneNumber) return;
    
//    use contact 2
    if (isContact1) {
        onContactUpdatedWithPhoneNumber(contact1.phoneNumber, contact2);
    } else {
        onContactUpdatedWithPhoneNumber(contact2.phoneNumber, contact1);
    }
    isContact1 = !isContact1;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0ul), ^{
        [self updateContactWithPhoneNumber];
    });

}

@end
