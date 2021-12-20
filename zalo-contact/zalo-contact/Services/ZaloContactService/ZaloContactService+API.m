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
        
        if (numberOfDays > 0.005) {
            NSLog(@"Scheduled fetch server data");
            [self loadSavedDataWithCompletionHandler:nil andOnFailedHandler:nil];
            [self fetchServerDataWithCompletionHandler:^{
                [self setUp];
            } andOnFailedHandler:nil];
        } else {
            NSLog(@"Load saved data");
            [self loadSavedDataWithCompletionHandler:^{
                [self setUp];
            } andOnFailedHandler:^{
                [self fetchServerDataWithCompletionHandler:^{
                    [self setUp];
                } andOnFailedHandler:nil];
            }];
        }
    } else {
        NSLog(@"No scheduled time found, begin fetching server data");
        [self fetchServerDataWithCompletionHandler:^{
            [self setUp];
        } andOnFailedHandler:nil];
    }
}

- (void)applyDataFrom:(ContactMutableDictionary *)contactDict andAccountDict:(AccountMutableDictionary *)accountDict {
    self.oldContactDictionary = contactDict.mutableCopy;
    self.oldAccountDictionary = accountDict.mutableCopy;
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
        // bind fetching data
        dispatch_async(self.apiServiceQueue, ^{
            [self applyDataFrom:tempContact andAccountDict:tempAccount];
            for (id<ZaloContactEventListener> listener in self.listeners) {
                if ([listener respondsToSelector:@selector(onServerChangeWithFullNewList:andAccount:)]) {
                    [listener onServerChangeWithFullNewList:self.contactDictionary.mutableCopy andAccount:self.accountDictionary.mutableCopy];
                }
            }
        });
        if (onCompleteBlock) onCompleteBlock();
    }];
    
}

//YES is success
- (void)loadSavedDataWithCompletionHandler:(ActionBlock)onCompleteBlock andOnFailedHandler:(ActionBlock)onFailedBlock {
    dispatch_async(self.contactServiceQueue, ^{
        ContactMutableDictionary *loadContact = [self loadContactDictionary];
        AccountMutableDictionary *loadAccount = [self loadAccountDictionary];
        
        // can not load local data -> fetch server data
        if (!loadContact || !loadAccount || ![loadContact count] || ![loadAccount count]) {
            if (onFailedBlock) onFailedBlock();
            return;
        }
        
        dispatch_async(self.apiServiceQueue, ^{
            [self applyDataFrom:loadContact andAccountDict:loadAccount];
            for (id<ZaloContactEventListener> listener in self.listeners) {
                if ([listener respondsToSelector:@selector(onLoadSavedDataCompleteWithContact:andAccount:)]) {
                    [listener onLoadSavedDataCompleteWithContact:self.contactDictionary.mutableCopy andAccount:self.accountDictionary.mutableCopy];
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
        NSLog(@"load Checked date error %@", err.description);
    }
    return date;
}

- (void)savedCheckDate:(NSDate *)date {
    NSError *err = nil;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:date requiringSecureCoding:NO error:&err];
    if (err) {
        NSLog(@"SaveData error %@", err.description);
        return;
    }
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"checkedDate"];
}

@end

