//
//  ContactsLoader.m
//  zalo-contact
//
//  Created by LAp14886 on 15/11/2021.
//

#import "ContactsLoader.h"
#import "ContactEntity.h"
#import "ZaloContactService.h"
@import IGListKit;

extern int repeatTime = 0;

@implementation ContactsLoader {
    NSArray<ContactGroupEntity *> *_contactGroups;
    NSMutableDictionary<NSString*, NSArray<ContactEntity*>*> *currentContacts;
}

- (void)loadSavedData:(FetchBlock)block {
    block(self.loadSavedData);
}

#warning @"Make sure this function call after the permission checking in vm"
/// Get local and remote data than merge
- (void)fetchData:(FetchBlock)block {
    
    NSMutableDictionary *apiContacts = NSMutableDictionary.new;
    NSMutableDictionary *localContacts = ZaloContactService.sharedInstance.getFullContactDict;
    currentContacts = localContacts;
    _contactGroups = [ContactGroupEntity groupFromContacts:currentContacts];
    
    [self saveData:_contactGroups];
    
    block(_contactGroups);
}

- (void)addContact:(ContactEntity *)contact returnBlock:(FetchBlock)block{
//    ZaloContactService.sharedInstance.
//    _contactGroups = [self groupFromContacts: [self mergeContactDict:currentContacts toDict:contactd]];
    
    [self saveData:_contactGroups];
    
    block(_contactGroups);
}

- (void)mockFetchDataWithReapeatTime:(int)time andBlock:(FetchBlock)block {
    repeatTime += time;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul), ^{
        [self fetchData:^(NSArray<ContactGroupEntity *> * result) {
            block(result);
        }];
    });
    
}

- (void)saveData:(NSArray<ContactGroupEntity *> *)groups {
    NSError *err = nil;
    NSData *dataToSave = [NSKeyedArchiver archivedDataWithRootObject:groups requiringSecureCoding:NO error:&err];
    if (err) {
        NSLog(@"saveData error %@", err.description);
    }
    [[NSUserDefaults standardUserDefaults] setObject:dataToSave forKey:@"data"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSArray<ContactGroupEntity *> *)loadSavedData {
    NSError *err = nil;
    NSData *decoded = [NSUserDefaults.standardUserDefaults objectForKey:@"data"];
    NSSet *classes = [NSSet setWithObjects:[NSArray class], [ContactGroupEntity class] ,[ContactEntity class], [NSString class], nil];
    NSArray<ContactGroupEntity *> *groups = (NSArray<ContactGroupEntity *> *)[NSKeyedUnarchiver unarchivedObjectOfClasses:classes fromData:decoded error:&err];
    if (err) {
        NSLog(@"loadSavedData error %@", err.description);
        return NSArray.array;
    }
    return groups;
}


@end



