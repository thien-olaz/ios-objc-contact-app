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
    dispatch_queue_t _fetchDataqueue = dispatch_queue_create("_fetchDataqueue", qos);
    
    if (self.checkDate) {
        NSTimeInterval secondsBetween = [now timeIntervalSinceDate:self.checkDate];
        double numberOfDays = secondsBetween / 86400.0;
        
        if (numberOfDays > 0.0000001) {
            LOG(@"SCHEDULED GET CONTACTS FROM SERVER");
            //dispatch work item
            dispatch_group_t group = dispatch_group_create();
            dispatch_block_t leaveBlock = ^{dispatch_group_leave(group);};
            
            dispatch_group_enter(group);
            DISPATCH_ASYNC_IF_NOT_IN_QUEUE(_fetchDataqueue, ^{
                [self fetchLocalDataWithCompletionHandler:leaveBlock andOnFailedHandler:leaveBlock];
            });
            
            dispatch_group_enter(group);
            DISPATCH_ASYNC_IF_NOT_IN_QUEUE(_fetchDataqueue, ^{
                [self autoRetryGetServerData:leaveBlock];
            });
            
            DISPATCH_ASYNC_IF_NOT_IN_QUEUE(_fetchDataqueue, ^{
                dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
                [self setUp];
            });
            
        } else {
            DISPATCH_ASYNC_IF_NOT_IN_QUEUE(_fetchDataqueue, ^{
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
        DISPATCH_ASYNC_IF_NOT_IN_QUEUE(_fetchDataqueue, ^{
            [self autoRetryGetServerData:nil];
        });
    }
}

// server trước local - done 2 task
/// Get server data with 3 instance retry and scheduled retry each 10 minutes
- (void)autoRetryGetServerData:(ActionBlock)onCompleteBlock {
    [self getServerDataWithRetryTime:3 eachSecond:3 completionHandler:^{
        LOG(@"GET SERVER DATA SUCCESS");
        if (onCompleteBlock) onCompleteBlock();
        else [self setUp];
    } andOnFailedHandler:^{
        LOG(@"GET SERVER DATA FAILED");
        [NSTimer scheduledTimerWithTimeInterval:(10 * 60 * NSEC_PER_SEC) repeats:NO block:^(NSTimer * _Nonnull timer){
            [self autoRetryGetServerData:nil];
        }];
    }];
}

/// Retry in the next {sec} seconds till retry time is 0
- (void)getServerDataWithRetryTime:(int)retryTime eachSecond:(int)sec completionHandler:(ActionBlock)onCompleteBlock andOnFailedHandler:(ActionBlock)onFailedBlock {
    DISPATCH_ASYNC_IF_NOT_IN_QUEUE(GLOBAL_QUEUE, ^{
        [self fetchServerDataWithCompletionHandler:onCompleteBlock andOnFailedHandler:^{
            if (retryTime > 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    LOG(@"GET SERVER DATA FAILED - RETRYING!");
                    [NSTimer scheduledTimerWithTimeInterval:(3) repeats:NO block:^(NSTimer * _Nonnull timer){
                        [self getServerDataWithRetryTime:(retryTime - 1) eachSecond:sec * 2 completionHandler:onCompleteBlock andOnFailedHandler:onFailedBlock];
                    }];
                });
            } else {
                if (onFailedBlock) onFailedBlock();
                return;
            }
        }];
    });
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
    if (![self.accountDictionary count]) {
        dispatch_async(self.apiServiceQueue, ^{
            [self applyDataFrom:tempContact andAccountDict:tempAccount];
            [self cacheChanges];
            for (id<ZaloContactEventListener> listener in self.listeners) {
                if ([listener respondsToSelector:@selector(onChangeWithFullNewList:andAccount:)]) {
                    [listener onChangeWithFullNewList:[self getContactDictCopy] andAccount:self.accountDictionary.mutableCopy];
                }
            }
        });
    }
    
    if (onCompleteBlock) onCompleteBlock();
    
}

- (NSDate *)getSavedCheckDate {
    NSError *err = nil;
    NSData *checkedDateDecord = [NSUserDefaults.standardUserDefaults objectForKey:@"checkedDate"];
    NSSet *classes = [NSSet setWithObjects:[NSDate class], nil];
    NSDate *date = (NSDate*)[NSKeyedUnarchiver unarchivedObjectOfClasses:classes fromData:checkedDateDecord error:&err];
    if (err) {
        LOG(err.description);
    }
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

