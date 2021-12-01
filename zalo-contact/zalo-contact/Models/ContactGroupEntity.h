//
//  ContactGroup.h
//  zalo-contact
//
//  Created by Thiện on 18/11/2021.
//

#import <Foundation/Foundation.h>
#import "ContactEntity.h"
NS_ASSUME_NONNULL_BEGIN

@interface ContactGroupEntity : NSObject

@property NSString *header;
@property BOOL *isOnlineGroup;
@property NSMutableArray<ContactEntity *> *contacts;

- (id)initWithContactArray:(NSArray<ContactEntity *> *)contacts;
- (ContactEntity * _Nullable)getContactForIndex:(long)index;
@end

NS_ASSUME_NONNULL_END
