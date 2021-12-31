//
//  ContactStateProtocol.h
//  zalo-contact
//
//  Created by Thiện on 31/12/2021.
//

#import <Foundation/Foundation.h>
#import "CellObject.h"
#import "SwipeActionObject.h"
#import "ContactTableViewAction.h"

NS_ASSUME_NONNULL_BEGIN

@protocol StateProtocol <SwipeActionDelegate>

- (void)switchToContactTab;
- (void)switchToOnlineTab;

@end

@protocol ContextProtocol

- (void)changeToState:(Class)state;

@end

typedef void (^TapBlock)(void);


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
