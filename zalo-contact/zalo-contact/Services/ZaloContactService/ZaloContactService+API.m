//
//  ZaloContactService+API.m
//  zalo-contact
//
//  Created by Thiện on 21/12/2021.
//

#import "ZaloContactService+API.h"
#import "ZaloContactService+Storage.h"
#import "ZaloContactService+ChangeHandle.h"


typedef void(^ActionBlock) (void);
@interface ZaloContactService (API)

@end

@implementation ZaloContactService (API)

- (void)setupInitData {
    self.checkDate = [self getSavedCheckDate];
    NSDate *now = [NSDate now];
    if (self.checkDate) {
        NSTimeInterval secondsBetween = [now timeIntervalSinceDate:self.checkDate];
        double numberOfDays = secondsBetween / 86400.0;
        
        if (numberOfDays > 0.00001) {
            LOG(@"Scheduled fetch server data");
            [self loadSavedDataWithCompletionHandler:nil andOnFailedHandler:nil];
            [self getServerData];
        } else {
            LOG(@"Load saved data");
            [self loadSavedDataWithCompletionHandler:^{
                [self setUp];
            } andOnFailedHandler:^{
                [self getServerData];
            }];
        }
    } else {
        LOG(@"No scheduled time found, begin fetching server data");
        [self getServerData];
    }
}

/// Get server data with 3 instance retry and scheduled retry each 10 minutes
- (void)getServerData {
    [self getServerDataWithRetryTime:3 eachSecond:3 completionHandler:^{
        LOG(@"GET DATA SUCCESS");
        [self setUp];
    } andOnFailedHandler:^{
        // Retry in the next 10 minutes and retry when user restart app
        LOG(@"GET DATA FAILED");
        self.checkDate = [[NSDate now] dateByAddingTimeInterval:-86400];
        [self savedCheckDate:self.checkDate];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0ul), ^{
            [self getServerData];
        });
    }];
}

/// Retry in the next {sec} seconds till retry time is 0
- (void)getServerDataWithRetryTime:(int)retryTime eachSecond:(int)sec completionHandler:(ActionBlock)onCompleteBlock andOnFailedHandler:(ActionBlock)onFailedBlock{
    [self fetchServerDataWithCompletionHandler:onCompleteBlock andOnFailedHandler:^{
        if (retryTime > 0) {
            LOG(@"Get data failed, retrying!");
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, sec * NSEC_PER_SEC), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0ul), ^{
                [self getServerDataWithRetryTime:(retryTime - 1) eachSecond:sec completionHandler:onCompleteBlock andOnFailedHandler:onFailedBlock];
            });
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
    
    [self saveLatestChanges];
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

//YES is success
- (void)loadSavedDataWithCompletionHandler:(ActionBlock)onCompleteBlock andOnFailedHandler:(ActionBlock)onFailedBlock {
    dispatch_async(self.contactServiceQueue, ^{
        ContactMutableDictionary *loadContact = [self loadContactDictionary];
        AccountMutableDictionary *loadAccount = [self loadAccountDictionary];
        
        // can not load local data -> fetch server data
        if (!loadContact || !loadAccount) {
            if (onFailedBlock) onFailedBlock();
            return;
        }
        
        dispatch_async(self.apiServiceQueue, ^{
            [self applyDataFrom:loadContact andAccountDict:loadAccount];
            [self cacheChanges];
            for (id<ZaloContactEventListener> listener in self.listeners) {
                if ([listener respondsToSelector:@selector(onChangeWithFullNewList:andAccount:)]) {
                    [listener onChangeWithFullNewList:loadContact.mutableCopy andAccount:loadAccount.mutableCopy];
                }
            }
        });
        
        if (onCompleteBlock) onCompleteBlock();
    });
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

