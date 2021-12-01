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

@end
