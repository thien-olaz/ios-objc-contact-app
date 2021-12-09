//
//  ContactViewModel.h
//  zalo-contact
//
//  Created by Thiện on 01/12/2021.
//

@import Foundation;
#import "ContactsLoader.h"
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

- (void)onDiff:(IGListIndexPathResult *)sectionDiff cells:(NSArray<IGListIndexPathResult *> *)cellDiff reload:(NSArray<NSIndexPath *> *)reloadIndexes;

@end

@interface ContactViewModel : NSObject

@property (nonatomic, copy) BindDataBlock dataBlock;
@property (nonatomic, copy) BindDataBlock updateBlock;
@property (nonatomic, copy) CompleteBlock presentBlock;

@property ContactTableViewDataSource *tableViewDataSource;
@property NSMutableArray *data;

- (instancetype)initWithActionDelegate:(id<TableViewActionDelegate>)action
                       andDiffDelegate:(id<TableViewDiffDelegate>)diff;
- (void)setNeedsUpdate;
- (void)fetchLocalContacts;
- (void)setup;

@end

NS_ASSUME_NONNULL_END
