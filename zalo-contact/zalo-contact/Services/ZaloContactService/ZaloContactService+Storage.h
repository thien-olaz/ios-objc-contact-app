//
//  ZaloContactService+Storage.h
//  zalo-contact
//
//  Created by Thiện on 10/12/2021.
//

#import "CellObject.h"
#import "ZaloContactService.h"
#import "ZaloContactService+Private.h"
#import "Contact+CoreDataClass.h"
NS_ASSUME_NONNULL_BEGIN

@interface ZaloContactService (Storage)

- (void)saveFull;
- (void)saveAdd:(ContactEntity *)contact;
- (void)saveUpdate:(ContactEntity *)contact;
- (void)saveDelete:(NSString *)accountId;

@end

NS_ASSUME_NONNULL_END
