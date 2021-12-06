//
//  ContactsLoader.m
//  zalo-contact
//
//  Created by LAp14886 on 15/11/2021.
//

#import "ContactsLoader.h"
#import "ContactEntity.h"
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
    [UserContacts.sharedInstance fetchLocalContacts];
    
    NSMutableDictionary *apiContacts = [self fetchApiContacts];
    NSMutableDictionary *localContacts = NSMutableDictionary.new;//(NSMutableDictionary *)UserContacts.sharedInstance.getContactDictionary;
    currentContacts = [NSMutableDictionary dictionaryWithDictionary:[self mergeContactDict:apiContacts toDict:localContacts]];
    _contactGroups = [self groupFromContacts:currentContacts];
    
    [self saveData:_contactGroups];
    
    block(_contactGroups);
}

- (void)addContact:(NSMutableDictionary<NSString*, NSArray<ContactEntity*>*> *)contactd returnBlock:(FetchBlock)block{

    _contactGroups = [self groupFromContacts: [self mergeContactDict:currentContacts toDict:contactd]];
    
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

///Turn contacts dictionary into contact group
- (NSArray<ContactGroupEntity *> *)groupFromContacts:(NSDictionary<NSString *,NSArray<ContactEntity *> *> *)contacts {
    NSMutableArray<ContactGroupEntity *> *arr = NSMutableArray.array;
    
    [contacts enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL* stop) {
        [arr addObject:[ContactGroupEntity.alloc initWithHeader:key andContactArray:value]];
    }];
    
    //MARK: - light weight - maximum 24 charactor
    [arr sortUsingComparator:^NSComparisonResult(ContactGroupEntity *obj1,ContactGroupEntity *obj2) {
        return [obj1.header compare:obj2.header];
    }];
    return arr;
}

///Merge 2 contact dictionary - use for merging local contacts and remote contacts
- (NSDictionary<NSString*, NSArray<ContactEntity*>*> *)mergeContactDict:(NSMutableDictionary<NSString*, NSArray<ContactEntity*>*> *)dict1
                                                                 toDict:(NSMutableDictionary<NSString*, NSArray<ContactEntity*>*> *)dict2 {
    [dict1 enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL* stop) {
        NSArray<ContactEntity *> *dict2Arr = [dict2 objectForKey:key];
        // append contact to existing list
        
        if (dict2Arr) {
            [dict1 setObject: [self mergeArray:[self insertionSort:value] withArray:dict2Arr] forKey:key];
            [dict2 removeObjectForKey:key];
        }
    }];
    
    [dict1 addEntriesFromDictionary:dict2];
    return dict1;
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


/// Use insertionSort because it has O(n) complexity with sorted array, fast for almost sorted array
- (NSArray<ContactEntity*>*) insertionSort:(NSArray<ContactEntity*> *)array {
    NSMutableArray<ContactEntity *> *sortedArray = [NSMutableArray arrayWithArray:array];
    
    int i, j;
    ContactEntity *key;
    NSInteger length = sortedArray.count;
    
    for (i = 1; i < length; i++) {
        
        key = sortedArray[i];
        j = i - 1;
        
        while (j >= 0 && [sortedArray[j] compare:key] == NSOrderedDescending ) {
            sortedArray[j + 1] = sortedArray[j];
            j = j - 1;
        }
        sortedArray[j + 1] = key;
    }
    return sortedArray;
}



#pragma mark - Fake a api request
- (NSMutableDictionary<NSString*, NSArray<ContactEntity*>*> *)fetchApiContacts {
    NSString *image2 = @"https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS6yFzIYiRlIzc_Nb_KD3lmSmvtmJxr4eboXw&usqp=CAU";
    NSMutableDictionary<NSString*, NSArray<ContactEntity*>*> *dicionary = NSMutableDictionary.new;
    
    //    A list
    if (repeatTime == 0) return NSMutableDictionary.new;
    NSMutableArray * aArray = NSMutableArray.array;
    for (int i = 0; i < repeatTime; i++) {
        [aArray addObject:[[ContactEntity alloc] initWithFirstName:@"Alfold"
                                                          lastName:@"Abbott"
                                                       phoneNumber:@"0123456789"
                                                          imageUrl:image2]];
        
        [aArray addObject:[[ContactEntity alloc] initWithFirstName:@"Belindoa"
                                                          lastName:@"Abbott"
                                                       phoneNumber:@"0123456789"
                                                          imageUrl:image2]];
        
        [aArray addObject:[[ContactEntity alloc] initWithFirstName:@"Cong"
                                                          lastName:@"Abbott"
                                                       phoneNumber:@"0123456789"
                                                          imageUrl:image2]];
        
        [aArray addObject:[[ContactEntity alloc] initWithFirstName:@"Thien"
                                                          lastName:@"Abbott"
                                                       phoneNumber:@"0123456789"
                                                          imageUrl:image2]];
    }
    [dicionary setObject:aArray forKey:@"A"];
    
    //    B list
    NSMutableArray * bArray = [NSMutableArray array];
    
    for (int i = 0; i < repeatTime; i++) {
        [bArray addObject:[[ContactEntity alloc] initWithFirstName:@"T"
                                                          lastName:@"Bảnh"
                                                       phoneNumber:@"0123456789"
                                                          imageUrl:image2]];
        [bArray addObject: [[ContactEntity alloc] initWithFirstName:@"Z"
                                                           lastName:@"Bảo"
                                                        phoneNumber:@"0123456789"
                                                           imageUrl:image2]];
    }
    [dicionary setObject:bArray forKey:@"B"];
    //    T list
    NSMutableArray * tArray = [NSMutableArray array];
    
    for (int i = 0; i < repeatTime; i++) {
        [tArray addObject: [[ContactEntity alloc] initWithFirstName:@"A"
                                                           lastName:@"Trần"
                                                        phoneNumber:@"0123456789"
                                                           imageUrl:image2]];
        [tArray addObject: [[ContactEntity alloc] initWithFirstName:@"B"
                                                           lastName:@"Trần"
                                                        phoneNumber:@"0123456789"
                                                           imageUrl:image2]];
    }
    
    [dicionary setObject:tArray forKey:@"T"];
    
    NSMutableArray * oArray = [NSMutableArray array];
    
    for (int i = 0; i < repeatTime; i++) {
        [oArray addObject: [[ContactEntity alloc] initWithFirstName:@"Anh"
                                                           lastName:@"Cao"
                                                        phoneNumber:@"0123456789"
                                                           imageUrl:image2]];
        [oArray addObject: [[ContactEntity alloc] initWithFirstName:@"B"
                                                           lastName:@"Cao"
                                                        phoneNumber:@"0123456789"
                                                           imageUrl:image2]];
    }
    
    [dicionary setObject:oArray forKey:@"C"];
    
    NSMutableArray * zArray = [NSMutableArray array];
    
    for (int i = 0; i < repeatTime; i++) {
        [zArray addObject: [[ContactEntity alloc] initWithFirstName:@"Test"
                                                           lastName:@"Zalo"
                                                        phoneNumber:@"0123456789"
                                                           imageUrl:image2]];
        [zArray addObject: [[ContactEntity alloc] initWithFirstName:@"Test2"
                                                           lastName:@"Zalo"
                                                        phoneNumber:@"0123456789"
                                                           imageUrl:image2]];
    }
    
    [dicionary setObject:zArray forKey:@"Z"];
    
//    NSLog(@"Add t %d", oArray.count);
    return dicionary;
}

@end



