//
//  ZaloContactService+Storage.m
//  zalo-contact
//
//  Created by Thiện on 10/12/2021.
//

#import "ZaloContactService+Storage.h"
#import "ContactGroupEntity.h"

@implementation ZaloContactService (Storage)

// MARK: Perform some extra operation when data changed
- (void)didChange {
    [self save];
}

- (void)save {
    NSError *err = nil;
    NSData *contactDictData = [NSKeyedArchiver archivedDataWithRootObject: self.getFullContactDict.mutableCopy requiringSecureCoding:NO error:&err];
    if (err) {
        NSLog(@"saveData error %@", err.description);
        return;
    }
    [[NSUserDefaults standardUserDefaults] setObject:contactDictData forKey:@"contactDict"];
    
    NSData *acountData = [NSKeyedArchiver archivedDataWithRootObject: accountDictionary.mutableCopy requiringSecureCoding:NO error:&err];
    if (err) {
        NSLog(@"saveData error %@", err.description);
        return;
    }
    [[NSUserDefaults standardUserDefaults] setObject:acountData forKey:@"accountDict"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

// background
// tạo 1 queue riêng - chạy tuần tự
// add vào - không replace
- (void)load {
    NSError *err = nil;
    NSData *contactDictDecoded = [NSUserDefaults.standardUserDefaults objectForKey:@"contactDict"];
    NSSet *classes = [NSSet setWithObjects:[NSArray class], [ContactGroupEntity class] ,[ContactEntity class], [NSString class], [NSMutableDictionary class], [NSDictionary class], [ContactDictionary class], nil];
    
    ContactDictionary *contactDict = (ContactDictionary *)[NSKeyedUnarchiver unarchivedObjectOfClasses:classes fromData:contactDictDecoded error:&err];
    if (err) {
        NSLog(@"loadSavedData error %@", err.description);
    }
    NSLog(@"/contactDictionary/");
    if (contactDict) contactDictionary = contactDict.mutableCopy;
    
    NSData *accountDictDecoded = [NSUserDefaults.standardUserDefaults objectForKey:@"accountDict"];
    NSMutableDictionary<NSString *, ContactEntity *> *accountDict = (NSMutableDictionary<NSString *, ContactEntity *> *)[NSKeyedUnarchiver unarchivedObjectOfClasses:classes fromData:accountDictDecoded error:&err];
    if (err) {
        NSLog(@"loadSavedData error %@", err.description);
    }
    if (accountDict) accountDictionary = accountDict.mutableCopy;
    
    
    for (id<ZaloContactEventListener> listener in listeners) {
        if ([listener respondsToSelector:@selector(onLoadSavedDataComplete:)]) {
            [listener onLoadSavedDataComplete:contactDict.mutableCopy];
        }
    }
}

@end
