//
//  ContactGroup.m
//  zalo-contact
//
//  Created by Thiện on 18/11/2021.
//

#import "ContactGroupEntity.h"

@implementation ContactGroupEntity

- (id)initWithContactArray:(NSArray<ContactEntity *> *)contacts {
    self = [super init];
    _contacts = [NSMutableArray.alloc initWithArray: contacts];
    if (contacts[0]) {
        _header = contacts[0].header ;
    }
    return self;
}

- (id)initWithHeader:(NSString *)header andContactArray:(NSArray<ContactEntity *> *)contacts {
    self = [super init];
    _contacts = [NSMutableArray.alloc initWithArray: contacts];
    _header = header;
    return self;
}
- (ContactEntity * _Nullable)getContactForIndex:(long)index {
    if (_contacts.count > index) {
        return _contacts[index];
    }
    return nil;
    
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    NSString *header = [coder decodeObjectForKey:@"header"];
    NSMutableArray<ContactEntity *> *contacts = [coder decodeObjectForKey:@"contacts"];    
    return [self initWithHeader:header andContactArray:contacts];
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:_header forKey:@"header"];
    [coder encodeObject:_contacts forKey:@"contacts"];
}

+ (BOOL)supportsSecureCoding {
   return YES;
}

- (id<NSObject>)diffIdentifier {
    NSLog(@"group entity %@", self.header);
    
    return self.header;
}

- (BOOL)isEqualToDiffableObject:(nullable id<IGListDiffable>)object {
    
    ContactGroupEntity *entity = (ContactGroupEntity *)object;
    NSLog(@"group diff %@ %@", self.header, entity.header);
    if (!entity) return NO;
    if (![self.header isEqualToString:entity.header]) return NO;
    return YES;
//    return [self.contacts isEqual:entity.contacts];
}

- (BOOL)isEqual:(id)object {
    ContactGroupEntity *entity = (ContactGroupEntity *)object;
    if (!entity) return NO;
    return [self.header isEqualToString:entity.header];
}

@end
