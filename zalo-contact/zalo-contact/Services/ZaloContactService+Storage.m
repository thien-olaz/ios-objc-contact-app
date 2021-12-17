//
//  ZaloContactService+Storage.m
//  zalo-contact
//
//  Created by Thiện on 10/12/2021.
//

#import "ZaloContactService+Storage.h"
#import "ContactGroupEntity.h"

@implementation ZaloContactService (Storage)

- (void)didChangeWithContactDict:(ContactMutableDictionary *)contactDict
                  andAccountDict:(AccountMutableDictionary *)accountDict {
    
    [self saveContactDict:contactDict andAccountDict:accountDict];
}

- (void)saveContactDict:(ContactMutableDictionary *)contactDict
         andAccountDict:(AccountMutableDictionary *)accountDict {
    NSError *err = nil;
    NSData *contactDictData = [NSKeyedArchiver archivedDataWithRootObject: contactDict requiringSecureCoding:NO error:&err];
    if (err) {
        NSLog(@"SaveData error %@", err.description);
        return;
    }
    [[NSUserDefaults standardUserDefaults] setObject:contactDictData forKey:@"contactDict"];
    
    NSData *acountData = [NSKeyedArchiver archivedDataWithRootObject: accountDict requiringSecureCoding:NO error:&err];
    if (err) {
        NSLog(@"SaveData error %@", err.description);
        return;
    }
    [[NSUserDefaults standardUserDefaults] setObject:acountData forKey:@"accountDict"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (nullable ContactMutableDictionary *)loadContactDictionary {
    NSError *err = nil;
    NSData *contactDictDecoded = [NSUserDefaults.standardUserDefaults objectForKey:@"contactDict"];
    NSSet *classes = [NSSet setWithObjects:[NSArray class], [ContactGroupEntity class] ,[ContactEntity class], [NSString class], [NSMutableDictionary class], [NSDictionary class], [ContactMutableDictionary class], nil];
    
    ContactMutableDictionary *contactDict = (ContactMutableDictionary *)[NSKeyedUnarchiver unarchivedObjectOfClasses:classes fromData:contactDictDecoded error:&err];
    if (err) {
        NSLog(@"Load ContactMutableDictionary error %@", err.description);
        return nil;
    }
    
    return contactDict;
}

- (nullable AccountMutableDictionary *)loadAccountDictionary {
    NSError *err = nil;
    NSData *accountDictDecoded = [NSUserDefaults.standardUserDefaults objectForKey:@"accountDict"];
    NSSet *classes = [NSSet setWithObjects:[NSArray class], [ContactGroupEntity class] ,[ContactEntity class], [NSString class], [NSMutableDictionary class], [NSDictionary class], [ContactMutableDictionary class], nil];
    NSMutableDictionary<NSString *, ContactEntity *> *accountDict = (NSMutableDictionary<NSString *, ContactEntity *> *)[NSKeyedUnarchiver unarchivedObjectOfClasses:classes fromData:accountDictDecoded error:&err];
    if (err) {
        NSLog(@"load AccountMutableDictionary error %@", err.description);
    }
    return accountDict;
}

@end
