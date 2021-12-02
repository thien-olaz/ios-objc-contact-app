//
//  ContactGroup.h
//  zalo-contact
//
//  Created by Thiện on 18/11/2021.
//

#import <Foundation/Foundation.h>
#import "ContactEntity.h"
NS_ASSUME_NONNULL_BEGIN

@interface ContactGroupEntity : NSObject<NSSecureCoding, IGListDiffable>

@property NSString *header;
@property BOOL *isOnlineGroup;
@property NSMutableArray<ContactEntity *> *contacts;

- (id)initWithContactArray:(NSArray<ContactEntity *> *)contacts;
- (id)initWithHeader:(NSString *)header andContactArray:(NSArray<ContactEntity *> *)contacts;
- (ContactEntity * _Nullable)getContactForIndex:(long)index;

- (id<NSObject>)diffIdentifier;

// Diff equal
- (BOOL)isEqualToDiffableObject:(nullable id<IGListDiffable>)object;
// Array equal
- (BOOL)isEqual:(id)object;
@end

NS_ASSUME_NONNULL_END
