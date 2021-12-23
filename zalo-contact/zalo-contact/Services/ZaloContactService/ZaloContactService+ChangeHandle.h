//
//  ZaloContactService+ChangeHandle.h
//  zalo-contact
//
//  Created by Thiện on 21/12/2021.
//

#import "ZaloContactService.h"
#import "ZaloContactService+Private.h"
NS_ASSUME_NONNULL_BEGIN

@interface ZaloContactService ()

@end

@interface ZaloContactService (ChangeHandle)

- (BOOL)deleteContact:(ContactEntity*)contact inContactDict:(ContactMutableDictionary *)contactDict andAccountDict:(AccountMutableDictionary *)accountDict;
- (void)setUp;
- (void)cleanUpIncommingData;

- (void)deleteContact:(ContactEntity *)contact;
- (void)cacheChanges;

@end

NS_ASSUME_NONNULL_END
