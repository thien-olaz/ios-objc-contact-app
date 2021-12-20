//
//  ContactViewModel.h
//  zalo-contact
//
//  Created by Thiện on 01/12/2021.
//

@import Foundation;
#import "CellObject.h"
#import "ContactTableViewAction.h"
#import "MockAPIService.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^BindDataBlock)(void);
typedef void (^CompleteBlock)(void);
@protocol TableViewActionDelegate

- (CellObject *)attachToObject:(CellObject *)object action:(TapBlock)tapped;
- (CellObject *)attachToObject:(CellObject *)object swipeAction:(NSArray<SwipeActionObject *> *)actionList;
- (void) scrollTo:(NSIndexPath *)indexPath;

@end

@protocol TableViewDiffDelegate

- (void)onDiffWithSectionInsert:(NSIndexSet *)sectionInsert
                  sectionRemove:(NSIndexSet *)sectionRemove
                        addCell:(NSArray<NSIndexPath *>*)addIndexes
                     removeCell:(NSArray<NSIndexPath *>*)removeIndexes
                  andUpdateCell:(NSArray<NSIndexPath *>*)updateIndexes;
@end

@interface ContactViewModel : NSObject<SwipeActionDelegate>

@property (nonatomic, copy) BindDataBlock dataBlock;
@property (nonatomic, copy) BindDataBlock dataWithAnimationBlock;
@property (nonatomic, copy) BindDataBlock updateBlock;
@property (nonatomic, copy) CompleteBlock presentBlock;

@property ContactTableViewDataSource *tableViewDataSource;
@property NSMutableArray *data;
@property NSLock *updateUILock;

- (instancetype)initWithActionDelegate:(id<TableViewActionDelegate>)action
                       andDiffDelegate:(id<TableViewDiffDelegate>)diff;

- (void)setup;
- (NSArray<SwipeActionObject *>*)getActionListForContact;

@end

NS_ASSUME_NONNULL_END
