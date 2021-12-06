//
//  ContactsLoader.h
//  zalo-contact
//
//  Created by LAp14886 on 15/11/2021.
//

#import <Foundation/Foundation.h>
#import "UserContacts.h"
#import "ContactEntityAdapter.h"
#import "ContactGroupEntity.h"
NS_ASSUME_NONNULL_BEGIN

typedef void (^FetchBlock)(NSArray<ContactGroupEntity *>*);

@interface ContactsLoader : NSObject

- (void)loadSavedData:(FetchBlock)block;
- (void)fetchData:(FetchBlock)block;
- (void)addContact:(NSMutableDictionary<NSString*, NSArray<ContactEntity*>*> *)contactd returnBlock:(FetchBlock)block;
- (void)mockFetchDataWithReapeatTime:(int)time andBlock:(FetchBlock)block;

@end

NS_ASSUME_NONNULL_END
