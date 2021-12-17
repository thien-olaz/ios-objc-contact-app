//
//  ZaloContactService+Observer.m
//  zalo-contact
//
//  Created by Thiện on 10/12/2021.
//

#import "ZaloContactService+Observer.h"
#import "ZaloContactService+Storage.h"
@interface ZaloContactService (Observer)

@property NSMutableArray<id<ZaloContactEventListener>> *listeners;

@end

@implementation ZaloContactService (Observer)

#pragma mark - Observer
// Check thread safe
- (void)subcribe:(id<ZaloContactEventListener>)listener {
    if (!self.listeners) {
        self.listeners = NSMutableArray.new;
    }
    [self.listeners addObject:listener];
}
// Check thread safe
- (void)unsubcribe:(id<ZaloContactEventListener>)listener {
    if (!self.listeners) {
        return;
    }
    [self.listeners removeObject:listener];
}

- (void)didReceiveNewFullList:(NSArray<ContactEntity *>*)sortedArray {
//    NSString *currentHeader = sortedArray[0].header;
//    ContactDictionary *temp = [ContactDictionary new];
//    NSMutableArray<ContactEntity *> *tempArray = NSMutableArray.new;
//
//    for (ContactEntity *contact in sortedArray) {
//        
//        if (![contact.header isEqualToString:currentHeader]) {
//            [temp setObject:tempArray.mutableCopy forKey:currentHeader];
//
//            currentHeader = contact.header;
//            tempArray = NSMutableArray.new;
//        }
//        [tempArray addObject:contact];
//        [accountDictionary setObject:contact forKey:contact.phoneNumber.copy];
//    }
//    [temp setObject:tempArray forKey:currentHeader];
//    NSLog(@"/contactDictionary/");
//    contactDictionary = temp;
//
//    [self save];
//
//    for (id<ZaloContactEventListener> listener in listeners) {
//        if ([listener respondsToSelector:@selector(onReceiveNewList)]) {
//            [listener onReceiveNewList];
//        }
//    }
}


@end
