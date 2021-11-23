//
//  ContactGroup.m
//  zalo-contact
//
//  Created by Thiện on 18/11/2021.
//

#import "ContactGroup.h"

@implementation ContactGroup

- (id) initWithContactArray:(NSArray<Contact *> *)contacts {
    self = [super init];
    _contacts = [NSMutableArray.alloc initWithArray: contacts];
    if (contacts[0]) {
        _header = contacts[0].header ;
    }
    return self;
}

- (Contact * _Nullable) getContactForIndex:(long)index {
    if (_contacts.count > index) {
        return _contacts[index];
    }
    return nil;
    
}

@end
