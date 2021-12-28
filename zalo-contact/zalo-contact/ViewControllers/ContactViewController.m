//
//  ContactViewController.m
//  zalo-contact
//
//  Created by LAp14886 on 15/11/2021.
//

#import "ContactViewController.h"
#import "ZaloContactService.h"
#import "ZaloContactService+Observer.h"
#import "UIAlertControllerExt.h"
#import "ContactTableViewAction.h"
#import "ContactViewModel.h"
#import "MockAPIService.h"

@interface ContactViewController () <TableViewActionDelegate, TableViewDiffDelegate>

@property NSLock *lock;
@property UITableView *tableView;
@property ContactTableViewAction *tableViewAction;
@property ContactTableViewDataSource *tableViewDataSource;
@property ContactViewModel *viewModel;
@property dispatch_queue_t tableViewQueue;
@end

@implementation ContactViewController

- (id)initWithViewModel:(ContactTableViewDataSource *)vm {
    self = [super init];
    _tableViewDataSource = vm;
    self.lock = [NSLock new];
    dispatch_queue_attr_t qos = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_USER_INITIATED, -1);
    _tableViewQueue = dispatch_queue_create("_tableViewQueue", qos);
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configTableView];
    [self addView];
    
    [self bindViewModel];
}

- (void)addView {
    [self.view addSubview:_tableView];
}

- (void)configTableView {
    _tableView = [UITableView.alloc initWithFrame:CGRectZero
                                            style:UITableViewStylePlain];
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    if (@available(iOS 15, *)) {
        [_tableView setSectionHeaderTopPadding:0];
    }
    _tableView.rowHeight = UITableViewAutomaticDimension;
    
    _tableView.estimatedRowHeight = 0;
    _tableView.estimatedSectionFooterHeight = 0;
    _tableView.estimatedSectionHeaderHeight = 0;
    
    [_tableView setBackgroundColor:UIColor.zaloLightGrayColor];
    
    _tableView.sectionIndexColor = UIColor.lightGrayColor;
    _tableViewAction = ContactTableViewAction.new;
}

- (void)bindViewModel {
    _viewModel = [ContactViewModel.alloc initWithActionDelegate:self andDiffDelegate:self];
    // capture weak self for binding block
    // retain circle
    __unsafe_unretained typeof(self) weakSelf = self;
    
    [_tableView setDataSource:_tableViewDataSource];
    [_tableView setDelegate:_tableViewAction];
    
    [_tableViewAction setSwipeActionDelegate:self.viewModel];
    
    [_viewModel setTableViewDataSource:self.tableViewDataSource];
    
    [_viewModel setDataBlock:^{
        [weakSelf.tableViewDataSource compileDatasource:weakSelf.viewModel.data.copy];
        DISPATCH_SYNC_IF_NOT_IN_QUEUE(dispatch_get_main_queue(), ^{
            [weakSelf.tableView reloadData];
        });
    }];
    
    [_viewModel setDataWithAnimationBlock:^{
        [weakSelf.tableViewDataSource compileDatasource:weakSelf.viewModel.data.copy];
        DISPATCH_SYNC_IF_NOT_IN_QUEUE(dispatch_get_main_queue(), ^{
            [UIView transitionWithView:weakSelf.tableView
                              duration:0.2
                               options:(UIViewAnimationOptionTransitionCrossDissolve)
                            animations:^{
                [weakSelf.tableView reloadData];
            } completion:nil];
        });
    }];
    
    [_viewModel setUpdateBlock:^{
        [weakSelf.tableViewDataSource compileDatasource:weakSelf.viewModel.data.copy];
    }];
    
    [_viewModel setPresentBlock:^{
        [weakSelf presentViewController:[UIAlertController contactPermisisonAlert]  animated:YES completion:nil];
    }];
    
    [_viewModel setup];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.tableView.frame = self.view.bounds;
}

#pragma mark - TableViewActionDelegate
- (CellObject *)attachToObject:(CellObject *)object action:(TapBlock)tapped {
    return [_tableViewAction attachToObject:object action:tapped];
}

- (CellObject *)attachToObject:(CellObject *)object swipeAction:(NSArray<SwipeActionObject *> *)actionList {
    return [_tableViewAction attachToObject:object swipeAction:actionList];
}

- (void) scrollTo:(NSIndexPath *)indexPath {
    [_tableView scrollToRowAtIndexPath:indexPath atScrollPosition:(UITableViewScrollPositionTop) animated:YES];
}

#pragma mark - diffing animation
- (void)onDiffWithSectionInsert:(NSIndexSet *)sectionInsert
                  sectionRemove:(NSIndexSet *)sectionRemove
                        addCell:(NSArray<NSIndexPath *> *)addIndexes
                     removeCell:(NSArray<NSIndexPath *> *)removeIndexes
                  andUpdateCell:(NSArray<NSIndexPath *> *)updateIndexes {
    __unsafe_unretained typeof(self) weakSelf = self;
    // nhiều update => reload
    // UX
    DISPATCH_ASYNC_IF_NOT_IN_QUEUE(dispatch_get_main_queue(), ^{
        [weakSelf.tableView performBatchUpdates:^{
            [weakSelf.tableView reloadRowsAtIndexPaths:updateIndexes withRowAnimation:UITableViewRowAnimationFade];
            [weakSelf.tableView deleteRowsAtIndexPaths:removeIndexes withRowAnimation:(UITableViewRowAnimationLeft)];
            
            [weakSelf.tableView deleteSections:sectionRemove withRowAnimation:(UITableViewRowAnimationLeft)];
            [weakSelf.tableView insertSections:sectionInsert withRowAnimation:(UITableViewRowAnimationLeft)];
            
            [weakSelf.tableView  insertRowsAtIndexPaths:addIndexes withRowAnimation:(UITableViewRowAnimationLeft)];
        } completion:nil];
    });
    
}
@end

