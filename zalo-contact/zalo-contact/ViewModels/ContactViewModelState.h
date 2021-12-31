//
//  ContactViewModelState.h
//  zalo-contact
//
//  Created by Thiện on 31/12/2021.
//

#import <Foundation/Foundation.h>
#import "ContactStateProtocol.h"
#import "CellObject.h"
#import "ContactTableViewAction.h"
#import "MockAPIService.h"
#import "CommonCell.h"
#import "BlankFooterView.h"
#import "CommonHeaderAndFooterViews.h"
#import "ActionHeaderView.h"
#import "ContactObject.h"
#import "NSStringExt.h"
#import "GCDThrottle.h"
#import "ZaloContactService.h"
#import "LabelCellObject.h"
#import "UpdateContactObject.h"
#import "ZaloContactService+Observer.h"
#import "ContactGroupEntity.h"
#import "Contact+CoreDataClass.h"
#import "ContactDataManager.h"
#import "TabCellObject.h"

NS_ASSUME_NONNULL_BEGIN
typedef void (^BindDataBlock)(void);
typedef void (^CompleteBlock)(void);

@interface ContactViewModelState : NSObject<StateProtocol, SwipeActionDelegate> {
    id<ContextProtocol> contextDelegate;
}

- (instancetype)initWithContext:(id<ContextProtocol>)context;

@property (nonatomic, copy) BindDataBlock dataBlock;
@property (nonatomic, copy) BindDataBlock dataWithAnimationBlock;
@property (nonatomic, copy) BindDataBlock updateBlock;
@property (nonatomic, copy) CompleteBlock presentBlock;

@property ContactTableViewDataSource *tableViewDataSource;
@property NSMutableArray *data;
@property NSLock *updateUILock;

- (instancetype)initWithContext:(id<ContextProtocol>)context
                  actionDelegate:(id<TableViewActionDelegate>)action
                       andDiffDelegate:(id<TableViewDiffDelegate>)diff;

- (void)setup;
- (void)reload;
- (void)startUI;
- (void)stopUI;
- (NSArray<SwipeActionObject *>*)getActionListForContact;

@end


NS_ASSUME_NONNULL_END


