//
//  NSObject_ListDiffable.h
//  zalo-contact
//
//  Created by LAp14886 on 16/11/2021.
//

#import <Foundation/Foundation.h>
@import IGListKit;

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (IGListDiffable) <IGListDiffable>

- (id<NSObject>)diffIdentifier;
- (BOOL)isEqualToDiffableObject:(id<IGListDiffable>)object;

@end



NS_ASSUME_NONNULL_END
