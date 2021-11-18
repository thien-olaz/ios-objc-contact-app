//
//  UserContacts.m
//  zalo-contact
//
//  Created by Thiện on 18/11/2021.
//

#import "UserContacts.h"
@interface UserContacts ()
@property NSMutableArray<CNContact *> *contactList;
@end

@implementation UserContacts
static UserContacts *sharedInstance = nil;

+(UserContacts *)sharedInstance {
    @synchronized([UserContacts class]) {
        if (!sharedInstance)
            sharedInstance = [self new];
        return sharedInstance;
    }
    return nil;
}

-(instancetype)init {
    self = [super init];
    return self;
}

+(void) checkAccessContactPermission {
    [[[CNContactStore alloc] init] requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
        NSLog(@"%s Granted contacts permission [%d]", __PRETTY_FUNCTION__, granted);
    }];
}

-(void) fetchContacts {
    CNContactStore *store = [CNContactStore new];
    NSArray *keysToFetch = @[CNContactFamilyNameKey, CNContactGivenNameKey, CNContactPhoneNumbersKey];
    NSError *error = nil;

    NSError *containerError = nil;
    NSArray<CNContainer *> *allContainer = [store containersMatchingPredicate:nil error: &containerError];
    if (containerError) {
        NSLog(@"%s %@", __PRETTY_FUNCTION__, containerError.description);
        return;
    }

    NSMutableArray<CNContact *> *results = [NSMutableArray new];
    
    for (CNContainer *container in allContainer) {
        NSPredicate *fetchPredicate = [CNContact predicateForContactsInContainerWithIdentifier:container.identifier];
        NSLog(@"identi %@", container.identifier);
        NSArray<CNContact*> *containerResult = [store unifiedContactsMatchingPredicate:fetchPredicate keysToFetch:keysToFetch error:&error];
        if (error) {
            NSLog(@"%s %@", __PRETTY_FUNCTION__, error.description);
            return;
        }
        if (containerResult) [results addObjectsFromArray:containerResult];
    }
    
    self.contactList = results;
    NSLog(@"%s load complete - %lu contacts founded", __PRETTY_FUNCTION__, (unsigned long)results.count);
    NSLog(@"%@", results);
    
}

- (NSArray<CNContact *> *) getContactList {
    return self.contactList;
}


@end
