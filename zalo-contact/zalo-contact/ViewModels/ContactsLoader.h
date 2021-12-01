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

typedef void (^FetchBlock)(NSArray<ContactGroupEntity *>*);

@interface ContactsLoader : NSObject
- (void)fetchData:(FetchBlock)block;

@end

NS_ASSUME_NONNULL_END
