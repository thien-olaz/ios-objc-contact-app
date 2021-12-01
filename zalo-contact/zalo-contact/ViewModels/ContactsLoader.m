//
//  ContactsLoader.m
//  zalo-contact
//
//  Created by LAp14886 on 15/11/2021.
//

#import "ContactsLoader.h"
#import "ContactEntity.h"

@implementation ContactsLoader {
    NSArray<ContactGroupEntity *> *_contactGroups;
}


#warning @"Make sure this function call after the permission checking in vm"
- (void)fetchData:(FetchBlock)block {
    [UserContacts.sharedInstance fetchLocalContacts];
    
    NSMutableDictionary *apiContacts = [self fetchApiContacts];
    NSMutableDictionary *localContacts = (NSMutableDictionary *)UserContacts.sharedInstance.getContactDictionary;
        
    _contactGroups = [self groupFromContacts: [self mergeContactDict:apiContacts toDict:localContacts]];
    block(_contactGroups);
}

// kiểm tra ok -> bảo thằng loader nó fetch về đi -> fetch xong rồi chuyển nó thành contact group
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


// MARK: - Fake a api request
- (NSMutableDictionary<NSString*, NSArray<ContactEntity*>*> *)fetchApiContacts {
    NSString *image2 = @"https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS6yFzIYiRlIzc_Nb_KD3lmSmvtmJxr4eboXw&usqp=CAU";
    NSMutableDictionary<NSString*, NSArray<ContactEntity*>*> *dicionary = NSMutableDictionary.new;
    
    int repeatTime = 20;
    //    A list
    NSMutableArray * aArray = NSMutableArray.array;
    for (int i = 0; i < repeatTime; i++)
         [aArray addObject:[[ContactEntity alloc] initWithFirstName:@"A"
                                                           lastName:@"Công"
                                                        phoneNumber:@"0123456789"
                                                           imageUrl:image2]];
    for (int i = 0; i < repeatTime; i++)
         [aArray addObject:[[ContactEntity alloc] initWithFirstName:@"A"
                                                           lastName:@"Thiện"
                                                        phoneNumber:@"0123456789"
                                                           imageUrl:image2]];
    [dicionary setObject:aArray forKey:@"A"];
    
    
    //    B list
    NSMutableArray * bArray = [NSMutableArray array];
    
    for (int i = 0; i < repeatTime; i++)
         [bArray addObject:[[ContactEntity alloc] initWithFirstName:@"Bành"
                                                           lastName:@"T"
                                                        phoneNumber:@"0123456789"
                                                           imageUrl:image2]];
    for (int i = 0; i < repeatTime; i++)
         [bArray addObject: [[ContactEntity alloc] initWithFirstName:@"Bảo"
                                                            lastName:@"Z"
                                                         phoneNumber:@"0123456789"
                                                            imageUrl:image2]];
    
    [dicionary setObject:bArray forKey:@"B"];
    
    //    T list
    NSMutableArray * tArray = [NSMutableArray array];
    
    for (int i = 0; i < repeatTime; i++)
         [tArray addObject: [[ContactEntity alloc] initWithFirstName:@"Trần"
                                                            lastName:@"A"
                                                         phoneNumber:@"0123456789"
                                                            imageUrl:image2]];
    for (int i = 0; i < repeatTime; i++)
         [tArray addObject: [[ContactEntity alloc] initWithFirstName:@"Trần"
                                                             lastName:@"B"
                                                          phoneNumber:@"0123456789"
                                                             imageUrl:image2]];
    
    [dicionary setObject:tArray forKey:@"T"];
    
    return dicionary;
}

@end



