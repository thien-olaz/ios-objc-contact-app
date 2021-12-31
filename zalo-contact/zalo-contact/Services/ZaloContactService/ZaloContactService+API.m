//
//  ZaloContactService+API.m
//  zalo-contact
//
//  Created by Thiện on 21/12/2021.
//

#import "ZaloContactService+API.h"
#import "ZaloContactService+Storage.h"
#import "ZaloContactService+ChangeHandle.h"
#import "Contact+CoreDataClass.h"
#import "ContactDataManager.h"

typedef void(^ActionBlock) (void);
@interface ZaloContactService (API)

@end

@implementation ZaloContactService (API)

- (void)setupInitData {
    self.checkDate = [self getSavedCheckDate];
    NSDate *now = [NSDate now];
    
    dispatch_queue_attr_t qos = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_CONCURRENT, QOS_CLASS_USER_INITIATED, -1);
    self.fetchDataqueue = dispatch_queue_create("_fetchDataqueue", qos);
    SET_SPECIFIC_FOR_QUEUE(self.fetchDataqueue);
    if (self.checkDate) {
        NSTimeInterval secondsBetween = [now timeIntervalSinceDate:self.checkDate];
        double numberOfDays = secondsBetween / 86400.0;
        if (numberOfDays > 0.0000001) {
            LOG(@"SCHEDULED GET CONTACTS FROM SERVER");
            DISPATCH_ASYNC_IF_NOT_IN_QUEUE(self.fetchDataqueue, ^{
                [self fetchLocalDataWithCompletionHandler:nil andOnFailedHandler:nil];
            });
            DISPATCH_ASYNC_IF_NOT_IN_QUEUE(self.fetchDataqueue, ^{
                [self autoRetryGetServerData:^{
                    LOG(@"GET SERVER DATA SUCCESS!");
                    [self setUp];
                }];
            });
        } else {
            DISPATCH_ASYNC_IF_NOT_IN_QUEUE(self.fetchDataqueue, ^{
                [self fetchLocalDataWithCompletionHandler:^{
                    LOG(@"LOAD LOCAL CONTACTS DATA");
                    [self setUp];
                } andOnFailedHandler:^{
                    LOG(@"LOAD LOCAL CONTACTS FAILED");
                    [self autoRetryGetServerData:nil];
                }];
            });
        }
    } else {
        LOG(@"FIRST TIME RUN - GET CONTACTS FROM SERVER!");
        DISPATCH_ASYNC_IF_NOT_IN_QUEUE(self.fetchDataqueue, ^{
            [self autoRetryGetServerData:nil];
        });
    }
}

// server trước local - done 2 task
/// Get server data with 3 instance retry and scheduled retry each 10 minutes
- (void)autoRetryGetServerData:(ActionBlock)onCompleteBlock {
    [self getServerDataWithRetryTime:3 eachSecond:1 completionHandler:^{
        LOG(@"GET SERVER DATA SUCCESS");
        if (onCompleteBlock) onCompleteBlock();
        else [self setUp];
    } andOnFailedHandler:^{
        LOG(@"GET SERVER DATA FAILED");
        __weak typeof(self) weakSelf = self;
        self.fetchDataBlock = dispatch_block_create(DISPATCH_BLOCK_INHERIT_QOS_CLASS, ^{
            [weakSelf autoRetryGetServerData:onCompleteBlock];
        });
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC), self.fetchDataqueue, self.fetchDataBlock);
    }];
}

- (void)dealloc {
    if (self.fetchDataBlock) dispatch_block_cancel(self.fetchDataBlock);
}

/// Retry in the next {sec} seconds till retry time is 0
- (void)getServerDataWithRetryTime:(int)retryTime eachSecond:(int)sec completionHandler:(ActionBlock)onCompleteBlock andOnFailedHandler:(ActionBlock)onFailedBlock {
    [self fetchServerDataWithCompletionHandler:onCompleteBlock andOnFailedHandler:^{
        if (retryTime > 0) {
            LOG2(@"GET SERVER DATA FAILED - RETRYING AFTER %d SEC", sec * 2);
            __weak typeof(self) weakSelf = self;
            self.fetchDataBlock = dispatch_block_create(DISPATCH_BLOCK_INHERIT_QOS_CLASS, ^{
                [weakSelf getServerDataWithRetryTime:(retryTime - 1) eachSecond:sec * 2 completionHandler:onCompleteBlock andOnFailedHandler:onFailedBlock];
            });
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, sec * NSEC_PER_SEC), self.fetchDataqueue, self.fetchDataBlock);
        } else {
            if (onFailedBlock) onFailedBlock();
            return;
        }
    }];
}

- (void)applyDataFrom:(ContactMutableDictionary *)contactDict andAccountDict:(AccountMutableDictionary *)accountDict {
    //cache first
    [self cacheChanges];
    
    //apply second
    self.contactDictionary = contactDict.mutableCopy;
    self.accountDictionary = accountDict.mutableCopy;
    
    [self cleanUpIncommingData];
}

- (void)fetchServerDataWithCompletionHandler:(ActionBlock)onCompleteBlock andOnFailedHandler:(ActionBlock)onFailedBlock {
    // save time at each fetch
    NSDate *now = [NSDate now];
    self.checkDate = now;
    [self savedCheckDate:now];
    
    // fetching
    [self.apiService fetchContacts:^(NSArray<ContactEntity *> * contactsFromServer) {
        NSArray<ContactEntity *> *sortedArray = [ContactEntity insertionSort:contactsFromServer];
        
        ContactMutableDictionary *tempContact = [ContactMutableDictionary new];
        AccountMutableDictionary *tempAccount = [AccountMutableDictionary new];
        
        if (sortedArray && [sortedArray count]) {
            NSString *currentHeader;
            ContactEntityMutableArray *contactsInSection = [ContactEntityMutableArray new];
            for (ContactEntity *contact in sortedArray) {
                if (!currentHeader) {
                    currentHeader = contact.header;
                } else if (![contact.header isEqualToString:currentHeader]) {
                    [tempContact setObject:contactsInSection.mutableCopy forKey:currentHeader];
                    currentHeader = contact.header;
                    contactsInSection = NSMutableArray.new;
                }
                [contactsInSection addObject:contact];
                [tempAccount setObject:contact forKey:contact.accountId];
            }
            [tempContact setObject:contactsInSection forKey:currentHeader];
        }
        // bind fetched data
        dispatch_async(self.apiServiceQueue, ^{
            [self applyDataFrom:tempContact andAccountDict:tempAccount];
            [self saveFull];
            [self cacheChanges];
            for (id<ZaloContactEventListener> listener in self.listeners) {
                if ([listener respondsToSelector:@selector(onChangeWithFullNewList:andAccount:)]) {
                    [listener onChangeWithFullNewList:[self getContactDictCopy] andAccount:self.accountDictionary.mutableCopy];
                }
            }
        });
        if (onCompleteBlock) onCompleteBlock();
    } onFailed:^{
        if (onFailedBlock) onFailedBlock();
    }];
    
}

- (void)fetchLocalDataWithCompletionHandler:(ActionBlock)onCompleteBlock andOnFailedHandler:(ActionBlock)onFailedBlock {
    NSArray<ContactEntity *> *contactLoaded = [[ContactDataManager sharedInstance] getSavedData];
    if (!contactLoaded) {
        if (onFailedBlock) onFailedBlock();
        return;
    }
    NSArray<ContactEntity *> *sortedArray = [ContactEntity insertionSort:contactLoaded];
    
    ContactMutableDictionary *tempContact = [ContactMutableDictionary new];
    AccountMutableDictionary *tempAccount = [AccountMutableDictionary new];
    
    if (sortedArray && [sortedArray count]) {
        NSString *currentHeader;
        ContactEntityMutableArray *contactsInSection = [ContactEntityMutableArray new];
        for (ContactEntity *contact in sortedArray) {
            if (!currentHeader) {
                currentHeader = contact.header;
            } else if (![contact.header isEqualToString:currentHeader]) {
                [tempContact setObject:contactsInSection.mutableCopy forKey:currentHeader];
                currentHeader = contact.header;
                contactsInSection = NSMutableArray.new;
            }
            [contactsInSection addObject:contact];
            [tempAccount setObject:contact forKey:contact.accountId];
        }
        [tempContact setObject:contactsInSection forKey:currentHeader];
    }
    
    // bind fetched data
    dispatch_async(self.apiServiceQueue, ^{
        if ([self.accountDictionary count]) return;
        [self applyDataFrom:tempContact andAccountDict:tempAccount];
        [self cacheChanges];
        for (id<ZaloContactEventListener> listener in self.listeners) {
            if ([listener respondsToSelector:@selector(onChangeWithFullNewList:andAccount:)]) {
                [listener onChangeWithFullNewList:[self getContactDictCopy] andAccount:self.accountDictionary.mutableCopy];
            }
        }
    });
    
    if (onCompleteBlock) onCompleteBlock();
    
}

- (NSDate *)getSavedCheckDate {
    NSError *err = nil;
    NSData *checkedDateDecord = [NSUserDefaults.standardUserDefaults objectForKey:@"checkedDate"];
    NSSet *classes = [NSSet setWithObjects:[NSDate class], nil];
    NSDate *date = (NSDate*)[NSKeyedUnarchiver unarchivedObjectOfClasses:classes fromData:checkedDateDecord error:&err];
    return date;
}

- (void)savedCheckDate:(NSDate *)date {
    NSError *err = nil;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:date requiringSecureCoding:NO error:&err];
    if (err) {
        LOG(err.description);
        return;
    }
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"checkedDate"];
}

@end

