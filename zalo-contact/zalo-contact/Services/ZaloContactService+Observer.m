//
//  ZaloContactService+Observer.m
//  zalo-contact
//
//  Created by Thiện on 10/12/2021.
//

#import "ZaloContactService+Observer.h"
#import "ZaloContactService+Storage.h"

@implementation ZaloContactService (Observer)

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
    [contactDictionaryLock lock];
    [accountDictionaryLock lock];
    
    [accountDictionary setObject:contact forKey:contact.phoneNumber.copy];
    if (![contactDictionary objectForKey:contact.header]) {
        [contactDictionary setObject:@[contact] forKey:contact.header];
    } else {
        //        insert to array
        NSMutableArray *arr = [contactDictionary objectForKey:contact.header].mutableCopy;
        for (int i = 0; i < arr.count; i++) {
            if ([contact compare:arr[i]] == NSOrderedDescending) {
                
                if (i + 1 < arr.count && [contact compare:arr[i + 1]] == NSOrderedSame) {
                    continue;
                } else {
                    [arr insertObject:contact atIndex:i];
                }
                
                break;
            }
        }
        [contactDictionary setObject:arr forKey:contact.header];
    }
    
    [contactDictionaryLock unlock];
    [accountDictionaryLock unlock];
    
    [self didChange];
    
    // Notify subscriber
    for (id<ZaloContactEventListener> listener in listeners) {
        if ([listener respondsToSelector:@selector(onAddContact:)]) {
            [listener onAddContact:contact];
        }
    }
}

- (void)didDeleteContact:(NSString *)phoneNumber {
    [contactDictionaryLock lock];
    [accountDictionaryLock lock];
    
    ContactEntity *contact = [accountDictionary objectForKey:phoneNumber];
    if (contact) {
        if ([contactDictionary objectForKey:contact.header]) {
            //        delete from to array
            NSMutableArray *arr = [contactDictionary objectForKey:contact.header].mutableCopy;
            for (int i = 0; i < arr.count; i++) {
                if ([contact compare:arr[i]] == NSOrderedSame) {
                    [arr removeObjectAtIndex:i];
                    break;
                }
            }
            if (arr.count > 0) [contactDictionary setObject:arr forKey:contact.header];
            else [contactDictionary removeObjectForKey:contact.header];
        }
        [accountDictionary removeObjectForKey:phoneNumber];
    } else {
        NSLog(@"sai sai");
    }
    
    
    [contactDictionaryLock unlock];
    [accountDictionaryLock unlock];
    
    [self didChange];
    
    for (id<ZaloContactEventListener> listener in listeners) {
        if ([listener respondsToSelector:@selector(onDeleteContact:)]) {
            [listener onDeleteContact:contact];
        }
    }
    
}

// MARK: - actually we just need the account id and new contact infor for this function when in use
- (void)didUpdateContact:(ContactEntity *)contact toContact:(ContactEntity *)newContact {
    [contactDictionaryLock lock];
    [accountDictionaryLock lock];
    
    [accountDictionary removeObjectForKey:contact.phoneNumber];
    [accountDictionary setObject:newContact forKey:newContact.phoneNumber];
    
    if ([contactDictionary objectForKey:contact.header]) {
        // delete from to array
        NSMutableArray *arr = [contactDictionary objectForKey:contact.header].mutableCopy;
        for (int i = 0; i < arr.count; i++) {
            if ([contact compare:arr[i]] == NSOrderedSame) {
                [arr removeObjectAtIndex:i];
                break;
            }
        }
        if (arr.count > 0) [contactDictionary setObject:arr forKey:contact.header];
        else [contactDictionary removeObjectForKey:contact.header];
    }
    
    if (![contactDictionary objectForKey:newContact.header]) {
        [contactDictionary setObject:@[contact] forKey:newContact.header];
    } else {
        //insert to array
        NSMutableArray *arr = [contactDictionary objectForKey:newContact.header].mutableCopy;
        for (int i = 0; i < arr.count; i++) {
            if ([newContact compare:arr[i]] == NSOrderedDescending) {
                
                if (i + 1 < arr.count && [newContact compare:arr[i + 1]] == NSOrderedSame) {
                    continue;
                } else {
                    [arr insertObject:newContact atIndex:i];
                }
                
                break;
            }
        }
        [contactDictionary setObject:arr forKey:newContact.header];
    }
    
    [contactDictionaryLock unlock];
    [accountDictionaryLock unlock];
    
    [self didChange];
    
    for (id<ZaloContactEventListener> listener in listeners) {
        if ([listener respondsToSelector:@selector(onUpdateContact:toContact:)]) {
            [listener onUpdateContact:contact toContact:newContact];
        }
    }
    
}

- (void)didUpdateContactWihPhoneNumber:(NSString *)phoneNumber toContact:(ContactEntity *)newContact {
    
    [contactDictionaryLock lock];
    [accountDictionaryLock lock];
    
    ContactEntity *contact = [accountDictionary objectForKey:phoneNumber];
    
    [accountDictionary removeObjectForKey:phoneNumber];
    [accountDictionary setObject:newContact forKey:phoneNumber];
    
    if ([contactDictionary objectForKey:contact.header]) {
        //        delete from to array
        NSMutableArray *arr = [contactDictionary objectForKey:contact.header].mutableCopy;
        for (int i = 0; i < arr.count; i++) {
            if ([contact compare:arr[i]] == NSOrderedSame) {
                [arr removeObjectAtIndex:i];
                break;
            }
        }
        if (arr.count > 0) [contactDictionary setObject:arr forKey:contact.header];
        else [contactDictionary removeObjectForKey:contact.header];
    }
    
    if (![contactDictionary objectForKey:newContact.header]) {
        [contactDictionary setObject:@[newContact] forKey:newContact.header];
    } else {
        //        insert to array
        NSMutableArray *arr = [contactDictionary objectForKey:newContact.header].mutableCopy;
        for (int i = 0; i < arr.count; i++) {
            if ([newContact compare:arr[i]] == NSOrderedDescending) {
                
                if (i + 1 < arr.count && [newContact compare:arr[i + 1]] == NSOrderedSame) {
                    continue;
                } else {
                    [arr insertObject:newContact atIndex:i];
                }
                
                break;
            }
        }
        [contactDictionary setObject:arr forKey:newContact.header];
    }
    
    [contactDictionaryLock unlock];
    [accountDictionaryLock unlock];
    
    [self didChange];
    
    for (id<ZaloContactEventListener> listener in listeners) {
        if ([listener respondsToSelector:@selector(onUpdateContact:toContact:)]) {
            [listener onUpdateContact:contact toContact:newContact];
        }
    }
    
}


- (void)didReceiveNewFullList:(NSArray<ContactEntity *>*)sortedArray {
    NSString *currentHeader = sortedArray[0].header;
    ContactDictionary *temp = [ContactDictionary new];
    NSMutableArray<ContactEntity *> *tempArray = NSMutableArray.new;
    
    for (ContactEntity *contact in sortedArray) {
        
        if (![contact.header isEqualToString:currentHeader]) {
            [temp setObject:tempArray.copy forKey:currentHeader];
            
            currentHeader = contact.header;
            tempArray = NSMutableArray.new;
        }
        [tempArray addObject:contact];
        [accountDictionary setObject:contact forKey:contact.phoneNumber.copy];
    }
    [temp setObject:tempArray.copy forKey:currentHeader];
    
    contactDictionary = temp;
    
    [self save];
    
    for (id<ZaloContactEventListener> listener in listeners) {
        if ([listener respondsToSelector:@selector(onReceiveNewList)]) {
            [listener onReceiveNewList];
        }
    }
}

@end
