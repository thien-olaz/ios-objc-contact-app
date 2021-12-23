//
//  ZaloContactService+Storage.m
//  zalo-contact
//
//  Created by Thiện on 10/12/2021.
//

#import "ZaloContactService+Storage.h"

//coredata
@interface ZaloContactService (Storage)

@end

@implementation ZaloContactService (Storage)

- (void)saveLatestChanges {    
    NSMutableDictionary* saveContact = [NSMutableDictionary new];
    for (NSString *key in self.contactDictionary.keyEnumerator) {
        [saveContact setObject:self.contactDictionary[key].mutableCopy forKey:key];
    }
    NSMutableDictionary *saveAccount = self.accountDictionary.mutableCopy;
    dispatch_async(self.contactServiceQueue, ^{
        [self didChangeWithContactDict:saveContact.mutableCopy andAccountDict:saveAccount];
    });
}

- (void)didChangeWithContactDict:(ContactMutableDictionary *)contactDict
                  andAccountDict:(AccountMutableDictionary *)accountDict {
    
    [self saveContactDict:contactDict andAccountDict:accountDict];
}

- (void)saveContactDict:(ContactMutableDictionary *)contactDict
         andAccountDict:(AccountMutableDictionary *)accountDict {
    NSError *err = nil;
    NSData *contactDictData = [NSKeyedArchiver archivedDataWithRootObject: contactDict requiringSecureCoding:NO error:&err];
    if (err) {
        NSLog(@"Error - SaveData: %@", err.description);
        return;
    }
    [[NSUserDefaults standardUserDefaults] setObject:contactDictData forKey:@"contactDict"];
    
    NSData *acountData = [NSKeyedArchiver archivedDataWithRootObject: accountDict requiringSecureCoding:NO error:&err];
    if (err) {
        NSLog(@"SaveData error %@", err.description);
        return;
    }
    [[NSUserDefaults standardUserDefaults] setObject:acountData forKey:@"accountDict"];
}

- (nullable ContactMutableDictionary *)loadContactDictionary {
    NSError *err = nil;
    NSData *contactDictDecoded = [NSUserDefaults.standardUserDefaults objectForKey:@"contactDict"];
    NSSet *classes = [NSSet setWithObjects:[NSMutableArray class],[ContactEntity class], [NSString class], [NSMutableDictionary class], nil];
    
    ContactMutableDictionary *contactDict = (ContactMutableDictionary *)[NSKeyedUnarchiver unarchivedObjectOfClasses:classes fromData:contactDictDecoded error:&err];
    if (err) {
        NSLog(@"Error - ContactMutableDictionary: %@", err.description);
        return nil;
    }
    
    return contactDict;
}

- (nullable AccountMutableDictionary *)loadAccountDictionary {
    NSError *err = nil;
    NSData *accountDictDecoded = [NSUserDefaults.standardUserDefaults objectForKey:@"accountDict"];
    NSSet *classes = [NSSet setWithObjects:[NSMutableArray class],[ContactEntity class], [NSString class], [NSMutableDictionary class], nil];
    NSMutableDictionary<NSString *, ContactEntity *> *accountDict = (NSMutableDictionary<NSString *, ContactEntity *> *)[NSKeyedUnarchiver unarchivedObjectOfClasses:classes fromData:accountDictDecoded error:&err];
    if (err) {
        NSLog(@"Error - AccountMutableDictionary: %@", err.description);
    }
    return accountDict;
}

@end
