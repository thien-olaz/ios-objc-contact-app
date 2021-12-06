//
//  ZaloContactService.m
//  zalo-contact
//
//  Created by Thiện on 06/12/2021.
//

#import "ZaloContactService.h"
#import "UserContacts.h"
#import "NSArrayExt.h"
//MARK: - Usage
/*
 User for external and internal use
 */
@implementation ZaloContactService {
    NSMutableArray<id<ZaloContactEventListener>> *listeners;
    
//    id<APIServiceProtocol> apiService;
}

static ZaloContactService *sharedInstance = nil;

+ (ZaloContactService *)sharedInstance {
    @synchronized([ZaloContactService class]) {
        if (!sharedInstance)
            sharedInstance = [self new];
        return sharedInstance;
    }
    return nil;
}

- (instancetype)init {
    self = super.init;
    _apiService = MockAPIService.new;
    
    [UserContacts.sharedInstance fetchLocalContacts];
    
//    _contactDictionary = UserContacts.sharedInstance.getContactDictionary;
    _contactDictionary = [ContactDictionary new];
    
    [self setUp];
    return self;
}

- (void)setUp {
    __weak typeof(self) weakSelf = self;
    [_apiService setOnContactAdded:^(ContactEntity * newContact) {
        [weakSelf didAddContact:newContact];
    }];
    
    [_apiService setOnContactDeleted:^(ContactEntity * deleteContact) {
        [weakSelf didDeleteContact:deleteContact];
    }];
    
    [_apiService fakeServerUpdate];
}

///Merge 2 contact dictionary - use for merging local contacts and remote contacts
- (NSDictionary<NSString*, NSArray<ContactEntity*>*> *)mergeContactDict:(NSMutableDictionary<NSString*, NSArray<ContactEntity*>*> *)incommingDict
                                                                 toDict:(NSMutableDictionary<NSString*, NSArray<ContactEntity*>*> *)dict2 {
    [incommingDict enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL* stop) {
        NSArray<ContactEntity *> *dict2Arr = [dict2 objectForKey:key];
        // append contact to existing list
        
        if (dict2Arr) {
            [incommingDict setObject: [self mergeArray:[ContactEntity insertionSort:value] withArray:dict2Arr] forKey:key];
            [dict2 removeObjectForKey:key];
        }
    }];
    
    [incommingDict addEntriesFromDictionary:dict2];
    return incommingDict;
}

///Merge 2 sorted array - use for contacts in section
- (NSArray<ContactEntity *> *)mergeArray:(NSArray<ContactEntity *> *)arr1 withArray:(NSArray<ContactEntity *> *)arr2 {
    int i = 0, j = 0;
    NSUInteger arr1Length = arr1.count, arr2Length = arr2.count;
    NSMutableArray *returnArr = NSMutableArray.new;
    
    while (i < arr1Length && j < arr2Length) {
        if ([arr1[i] compare:arr2[j]] == NSOrderedAscending)
            [returnArr addObject:arr1[i++]];
        else
            [returnArr addObject:arr2[j++]];
    }
    
    while (i < arr1Length)
        [returnArr addObject:arr1[i++]];
    
    while (j < arr2Length)
        [returnArr addObject:arr2[j++]];
    
    return returnArr;
}

- (ContactDictionary *)getFullContactDict {
    return _contactDictionary;
}

- (NSArray<ContactEntity *>*)getFullContactList {
    
    return [_contactDictionary.allValues flatMap:^id(id obj) { return obj; }];
}


#pragma mark - Observer

- (void)subcribe:(id<ZaloContactEventListener>)listener {
    if (!listeners) {
        listeners = NSMutableArray.new;
    }
    [listeners addObject:listener];
}

- (void)unsubcribe:(id<ZaloContactEventListener>)listener {
    if (!listeners) {
        return;
    }
    [listeners removeObject:listener];
}

- (void)didAddContact:(ContactEntity *)contact {
    
    if (![_contactDictionary objectForKey:contact.header]) {
        [_contactDictionary setObject:@[contact] forKey:contact.header];
    } else {
//        insert to array
        NSMutableArray *arr = [_contactDictionary objectForKey:contact.header].mutableCopy;
        for (int i = 0; i < arr.count; i++) {
            if ([contact compare:arr[i]] == NSOrderedDescending) {
                [arr insertObject:contact atIndex:i];
                break;
            }
        }
        [_contactDictionary setObject:arr forKey:contact.header];
    }
    
    // Notify subscriber
    for (id<ZaloContactEventListener> listener in listeners) {
        if ([listener respondsToSelector:@selector(onAddContact:)]) {
            [listener onAddContact:contact];
        }
    }
}

- (void)didDeleteContact:(ContactEntity *)contact {
    for (id<ZaloContactEventListener> listener in listeners) {
        if ([listener respondsToSelector:@selector(onDeleteContact:)]) {
            [listener onDeleteContact:contact];
        }
    }
}

- (void)save {
    
}

@end
