//
//  ContactsLoader.h
//  zalo-contact
//
//  Created by LAp14886 on 15/11/2021.
//

#import <Foundation/Foundation.h>
#import "NSObject_ListDiffable.h"
#import "UserContacts.h"
#import "ContactEntityAdapter.h"
#import "ContactGroupEntity.h"
NS_ASSUME_NONNULL_BEGIN

@interface ContactsLoader : NSObject

- (NSMutableArray *) contactGroup;
- (ContactGroupEntity *) mockOnlineFriends;
- (void) update;
@end

NS_ASSUME_NONNULL_END
