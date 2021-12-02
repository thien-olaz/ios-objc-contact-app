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
}

- (void)loadSavedData:(FetchBlock)block {
    block(self.loadSavedData);
}

#warning @"Make sure this function call after the permission checking in vm"
/// Get local and remote data than merge
- (void)fetchData:(FetchBlock)block {
    [UserContacts.sharedInstance fetchLocalContacts];
    
    NSMutableDictionary *apiContacts = [self fetchApiContacts];
    NSMutableDictionary *localContacts = (NSMutableDictionary *)UserContacts.sharedInstance.getContactDictionary;
        
    _contactGroups = [self groupFromContacts: [self mergeContactDict:apiContacts toDict:localContacts]];
    
    [self saveData:_contactGroups];

    block(_contactGroups);
}

- (void)mockFetchDataWithReapeatTime:(int)time andBlock:(FetchBlock)block {
    repeatTime += time;
    
    [self fetchData:^(NSArray<ContactGroupEntity *> * result) {
        block(result);
    }];
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
    NSArray<ContactGroupEntity *> * groups = (NSArray<ContactGroupEntity *> *)[NSKeyedUnarchiver unarchivedObjectOfClasses:classes fromData:decoded error:&err];
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
            [dict1 setObject: [self mergeArray:value withArray:dict2Arr] forKey:key];
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
        if ([arr1[i].header compare:arr2[j].header])
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


#pragma mark - Fake a api request
- (NSMutableDictionary<NSString*, NSArray<ContactEntity*>*> *)fetchApiContacts {
    NSString *image2 = @"https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS6yFzIYiRlIzc_Nb_KD3lmSmvtmJxr4eboXw&usqp=CAU";
    NSMutableDictionary<NSString*, NSArray<ContactEntity*>*> *dicionary = NSMutableDictionary.new;

    //    A list
    if (repeatTime == 0) return NSMutableDictionary.new;
    NSMutableArray * aArray = NSMutableArray.array;
    for (int i = 0; i < repeatTime; i++)
        [aArray addObject:[[ContactEntity alloc] initWithFirstName:@"Công"
                                                          lastName:@"A"
                                                       phoneNumber:@"0123456789"
                                                          imageUrl:image2]];
    for (int i = 0; i < repeatTime; i++)
        [aArray addObject:[[ContactEntity alloc] initWithFirstName:@"Thiện"
                                                          lastName:@"A"
                                                       phoneNumber:@"0123456789"
                                                          imageUrl:image2]];
    [dicionary setObject:aArray forKey:@"A"];
    
    NSLog(@"Add a %d", aArray.count);
    
    //    B list
    NSMutableArray * bArray = [NSMutableArray array];
    
    for (int i = 0; i < repeatTime; i++)
        [bArray addObject:[[ContactEntity alloc] initWithFirstName:@"T"
                                                          lastName:@"Bảnh"
                                                       phoneNumber:@"0123456789"
                                                          imageUrl:image2]];
    for (int i = 0; i < repeatTime; i++)
        [bArray addObject: [[ContactEntity alloc] initWithFirstName:@"Z"
                                                           lastName:@"Bảo"
                                                        phoneNumber:@"0123456789"
                                                           imageUrl:image2]];
    
    [dicionary setObject:bArray forKey:@"B"];
    NSLog(@"Add b %d", bArray.count);
    //    T list
    NSMutableArray * tArray = [NSMutableArray array];
    
    for (int i = 0; i < repeatTime; i++)
        [tArray addObject: [[ContactEntity alloc] initWithFirstName:@"A"
                                                           lastName:@"Trần"
                                                        phoneNumber:@"0123456789"
                                                           imageUrl:image2]];
    for (int i = 0; i < repeatTime; i++)
        [tArray addObject: [[ContactEntity alloc] initWithFirstName:@"B"
                                                           lastName:@"Trần"
                                                        phoneNumber:@"0123456789"
                                                           imageUrl:image2]];
    
    [dicionary setObject:tArray forKey:@"T"];
    
    NSMutableArray * oArray = [NSMutableArray array];
    
    for (int i = 0; i < repeatTime; i++)
        [oArray addObject: [[ContactEntity alloc] initWithFirstName:@"A"
                                                           lastName:@"Cao"
                                                        phoneNumber:@"0123456789"
                                                           imageUrl:image2]];
    for (int i = 0; i < repeatTime; i++)
        [oArray addObject: [[ContactEntity alloc] initWithFirstName:@"B"
                                                           lastName:@"Cao"
                                                        phoneNumber:@"0123456789"
                                                           imageUrl:image2]];
    
    [dicionary setObject:oArray forKey:@"C"];
    
    NSLog(@"Add t %d", oArray.count);
    return dicionary;
}

@end



