//
//  ContactEntity.m
//  zalo-contact
//
//  Created by LAp14886 on 15/11/2021.
//

#import "ContactEntity.h"
@interface ContactEntity () {
    NSString *accountId;
    NSString *fullName;
    NSString *firstName;
    NSString *lastName;
}

@end

@implementation ContactEntity
@synthesize accountId;
@synthesize fullName;
@synthesize firstName;
@synthesize lastName;

- (id)initWithAccountId:(NSString *)Id
              firstName:(NSString *)fname
               lastName:(NSString *)lname
            phoneNumber:(NSString *)phoneNumber
               subtitle:(nullable NSString *)subtitle
                  email:(NSString *)email {
    self = super.init;
    accountId = [Id stringByReplacingOccurrencesOfString:@" " withString:@""];
    firstName = fname;
    lastName = lname;
    _phoneNumber = phoneNumber;
    _subtitle = subtitle;
    _email = email;
    [self update];
    return self;
}

- (void)setFirstName:(NSString *)name {
    firstName = name;
    [self update];
}

- (void)setLastName:(NSString *)name {
    lastName = name;
    [self update];
}

- (void)update {
    self.header = [ContactEntity headerFromFirstName:firstName andLastName:lastName];
    fullName = [NSString stringWithFormat:@"%@ %@", lastName, firstName];
}
#pragma mark - NSSecureEncoding

- (instancetype)initWithCoder:(NSCoder *)coder {
    NSString *accountId = [coder decodeObjectForKey:@"accountId"];
    NSString *firstName = [coder decodeObjectForKey:@"fname"];
    NSString *lastName = [coder decodeObjectForKey:@"lname"];
    NSString *phoneNumber = [coder decodeObjectForKey:@"pnumber"];
    NSString *imageUrl = [coder decodeObjectForKey:@"imageUrl"];
    NSString *subtitle = [coder decodeObjectForKey:@"subtitle"];
    NSString *email = [coder decodeObjectForKey:@"email"];
    
    self = [self initWithAccountId:accountId firstName:firstName lastName:lastName phoneNumber:phoneNumber subtitle:subtitle email:email];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:accountId forKey:@"accountId"];
    [coder encodeObject:firstName forKey:@"fname"];
    [coder encodeObject:lastName forKey:@"lname"];
    [coder encodeObject:_phoneNumber forKey:@"pnumber"];
    [coder encodeObject:_imageUrl forKey:@"imageUrl"];
    [coder encodeObject:self.subtitle forKey:@"subtitle"];
    [coder encodeObject:self.email forKey:@"email"];
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

#pragma mark - IGListDiffable

- (id<NSObject>)diffIdentifier {
    return @(self.phoneNumber.hash);
}

- (BOOL)isEqualToDiffableObject:(id<IGListDiffable>)object {
    ContactEntity *entity = (ContactEntity *)object;
    if (!entity) return NO;
    if (![self.firstName isEqualToString:entity.firstName]) return NO;
    if (![self.lastName isEqualToString:entity.lastName]) return NO;
    if (![self.phoneNumber isEqualToString:entity.phoneNumber]) return NO;
    
    // Both null or 1 of 2 is null -> NO
    if (self.subtitle && entity.subtitle && [self.subtitle isEqualToString:entity.subtitle]) {
            return YES;
    } else if (!self.subtitle && !entity.subtitle) {
        return YES;;
    }
    
    // Both null or 1 of 2 is null -> NO
    
    return NO;
}

#pragma mark - Equal

//compare to get order
- (NSComparisonResult)compare:(ContactEntity *)entity {
    NSComparisonResult res;

    res = [self.lastName compare:entity.lastName];
    if ( res != NSOrderedSame) {
        return res;
    }
    
    res = [self.firstName compare:entity.firstName];
    if ( res != NSOrderedSame) {
        return res;
    }

    res = [self.phoneNumber compare:entity.phoneNumber];
    if ( res != NSOrderedSame) {
        return res;
    }

    return [self.accountId compare:entity.accountId];
}

- (BOOL)isEqual:(id)object {
    ContactEntity *entity = (ContactEntity *)object;
    if (!entity) return false;
    return [self compare:entity] == NSOrderedSame;
}

#pragma mark - sort 2 array

/// Use insertionSort because it has O(n) complexity with sorted array, fast for almost sorted array
+ (NSArray<ContactEntity*>*) insertionSort:(NSArray<ContactEntity*> *)array {
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

#pragma mark - class method
+ (NSString *)headerFromFirstName:(nullable NSString *)firstName andLastName:(nullable NSString *)lastName {
    return lastName && lastName.length > 0 ? [lastName substringToIndex:1] : firstName && firstName.length > 0 ? [firstName substringToIndex:1] : @"#";
}

// Merge 2 contact dictionary - use for merging local contacts and remote contacts
+ (NSMutableDictionary<NSString*, NSArray<ContactEntity*>*> *)mergeContactDict:(NSMutableDictionary<NSString*, NSArray<ContactEntity*>*> *)incommingDict
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
+ (NSArray<ContactEntity *> *)mergeArray:(NSArray<ContactEntity *> *)arr1 withArray:(NSArray<ContactEntity *> *)arr2 {
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

@end
