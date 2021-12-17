//
//  ZaloContactService+Storage.h
//  zalo-contact
//
//  Created by Thiện on 10/12/2021.
//

#import "CellObject.h"
#import "ZaloContactService.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZaloContactService (Storage)

- (void)didChangeWithContactDict:(ContactMutableDictionary *)contactDict andAccountDict:(AccountMutableDictionary *)accountDict;

- (nullable ContactMutableDictionary *)loadContactDictionary;
- (nullable AccountMutableDictionary *)loadAccountDictionary;


@end

NS_ASSUME_NONNULL_END
