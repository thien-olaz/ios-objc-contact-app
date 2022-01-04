//
//  ContactVM.h
//  zalo-contact
//
//  Created by Thiện on 03/01/2022.
//

@import Foundation;
#import "CellObject.h"
#import "ContactTableViewAction.h"
#import "MockAPIService.h"
#import "ContactTableViewProtocol.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^BindDataBlock)(void);
typedef void (^CompleteBlock)(void);

@interface ContactViewModel : NSObject<SwipeActionDelegate>

@property (nonatomic, copy) BindDataBlock dataBlock;
@property (nonatomic, copy) BindDataBlock dataWithAnimationBlock;
@property (nonatomic, copy) BindDataBlock dataWithTransitionBlock;
//@property (nonatomic, copy) BindDataBlock updateBlock;

@property ContactTableViewDataSource *tableViewDataSource;

@property NSMutableArray *data;

@property id<TableViewDiffDelegate> diffDelegate;
@property id<TableViewActionDelegate> actionDelegate;

- (instancetype)initWithActionDelegate:(id<TableViewActionDelegate>)action
                       andDiffDelegate:(id<TableViewDiffDelegate>)diff;

- (void)setup;
- (void)bindNewData;

- (void)changeToObjectManagerState:(Class)classState;

@end

NS_ASSUME_NONNULL_END
