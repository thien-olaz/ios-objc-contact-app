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
    NSArray<CNContact *> *contactsPool;
    int currentIndex;
}

@synthesize onContactUpdated;

@synthesize onContactAdded;

@synthesize onContactDeleted;

- (instancetype)init {
    self = super.init;
    [self mockAddContact];
    currentIndex = 0;
    return self;
}

- (void)mockAddContact {
    NSString *filepath = [[NSBundle mainBundle] pathForResource:@"contacts" ofType:@"vcf"];
    NSError *error;
    NSString *fileContents = [NSString stringWithContentsOfFile:filepath encoding:NSUTF8StringEncoding error:&error];
    
    if (error) {
        LOG(error.description);
        return;
    }
    
    NSData *data = [fileContents dataUsingEncoding:NSUTF8StringEncoding];
    contactsPool =[CNContactVCardSerialization contactsWithData:data error:&error];
    if (error) {
        LOG(error.description);
        return;
    }
    
}

- (void)fakeServerUpdate {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
    [self addNewContact];
    });
}

- (void)addNewContact {
    if (!onContactAdded) return;
    
    if (currentIndex < contactsPool.count) {
        ContactEntityAdapter *enity = [ContactEntityAdapter.alloc initWithCNContact:contactsPool[currentIndex]];
        NSLog(@"%@", enity.fullName);
        onContactAdded(enity);
        currentIndex += 1;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self addNewContact];
        });
    };
    
}

//- (void)getContactList {
//    <#code#>
//}
//
//- (void)contactAdded {
//    <#code#>
//}
//
//- (void)contactChanged {
//    <#code#>
//}
//
//- (void)contactDeleted {
//    <#code#>
//}

@end
