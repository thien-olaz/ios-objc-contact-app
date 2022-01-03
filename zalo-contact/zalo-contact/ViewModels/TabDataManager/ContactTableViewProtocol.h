//
//  ContactTableViewProtocol.h
//  zalo-contact
//
//  Created by Thiện on 03/01/2022.
//

#import <Foundation/Foundation.h>
#import "CellObject.h"

NS_ASSUME_NONNULL_BEGIN

@protocol TableViewActionDelegate

- (CellObject *)attachToObject:(CellObject *)object action:(TapBlock)tapped;
- (CellObject *)attachToObject:(CellObject *)object swipeAction:(NSArray<SwipeActionObject *> *)actionList;
- (void) scrollTo:(NSIndexPath *)indexPath;

@end

@protocol TableViewDiffDelegate

- (void)onDiffWithSectionInsert:(NSIndexSet *)sectionInsert
                  sectionRemove:(NSIndexSet *)sectionRemove
                  sectionUpdate:(NSIndexSet *)sectionUpdate
                        addCell:(NSArray<NSIndexPath *>*)addIndexes
                     removeCell:(NSArray<NSIndexPath *>*)removeIndexes
                  andUpdateCell:(NSArray<NSIndexPath *>*)updateIndexes;

- (void)onDiffWithSectionInsert:(NSIndexSet *)sectionInsert
                  sectionRemove:(NSIndexSet *)sectionRemove
                  sectionUpdate:(NSIndexSet *)sectionUpdate;

@end
NS_ASSUME_NONNULL_END
