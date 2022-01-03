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
    SET_SPECIFIC_FOR_QUEUE(_tableViewQueue);
    
    SET_SPECIFIC_FOR_QUEUE(MAIN_QUEUE);
    SET_SPECIFIC_FOR_QUEUE(GLOBAL_QUEUE);
    
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
    _tableViewAction = [ContactTableViewAction new];
}

- (void)bindViewModel {
    self.viewModel = [[ContactViewModel alloc] initWithActionDelegate:self andDiffDelegate:self];
    [self.viewModel setTableViewDataSource:self.tableViewDataSource];
    __unsafe_unretained typeof(self) weakSelf = self;
    
    
    [self.viewModel setDataBlock:^{
        ContactViewController *strongSelf = weakSelf;
        [strongSelf reloadTableViewWithAnimationDuration:0];
    }];
    
    [self.viewModel setDataWithTransitionBlock:^{
        ContactViewController *strongSelf = weakSelf;
        [strongSelf reloadTableViewWithTransitionDuration:0.2];
    }];
    
    [self.viewModel setDataWithAnimationBlock:^{
        ContactViewController *strongSelf = weakSelf;
        [strongSelf reloadTableViewWithAnimationDuration:0.4];
    }];
    
    [self.viewModel setUpdateBlock:^{
        ContactViewController *strongSelf = weakSelf;
        [strongSelf.tableViewDataSource compileDatasource:strongSelf.viewModel.data.copy];
    }];
    
    [_tableView setDataSource:_tableViewDataSource];
    [_tableView setDelegate:_tableViewAction];
    
    [_tableViewAction setSwipeActionDelegate:self.viewModel];
    [self.viewModel setup];
}

- (void)reloadTableViewWithAnimationDuration:(float)duration {
    [self.lock lock];
    [self.tableViewDataSource compileDatasource:self.viewModel.data.copy];
    DISPATCH_SYNC_IF_NOT_IN_QUEUE(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:duration animations:^{
            [self.tableView reloadData];
            if (self.tableView.contentSize.height < self.tableView.frame.size.height) {
                NSIndexPath *firstIndex = self.tableView.indexPathsForVisibleRows.firstObject;
                [self.tableView scrollToRowAtIndexPath:firstIndex atScrollPosition:(UITableViewScrollPositionTop) animated:YES];
            }
        } completion:^(BOOL finished) {
            [self.lock unlock];
        }];
    });
}

- (void)reloadTableViewWithTransitionDuration:(float)duration {
    [self.lock lock];
    [self.tableViewDataSource compileDatasource:self.viewModel.data.copy];
    DISPATCH_SYNC_IF_NOT_IN_QUEUE(dispatch_get_main_queue(), ^{
        [UIView transitionWithView:self.tableView duration:duration options:(UIViewAnimationOptionTransitionCrossDissolve) animations:^{
            [self.tableView reloadData];
        } completion:^(BOOL finished) {
            [self.lock unlock];
        }];
    });
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

- (void)scrollTo:(NSIndexPath *)indexPath {
    [_tableView scrollToRowAtIndexPath:indexPath atScrollPosition:(UITableViewScrollPositionTop) animated:YES];
}

#pragma mark - diffing animation
- (void)onDiffWithSectionInsert:(NSIndexSet *)sectionInsert
                  sectionRemove:(NSIndexSet *)sectionRemove
                  sectionUpdate:(NSIndexSet *)sectionUpdate
                        addCell:(NSArray<NSIndexPath *> *)addIndexes
                     removeCell:(NSArray<NSIndexPath *> *)removeIndexes
                  andUpdateCell:(NSArray<NSIndexPath *> *)updateIndexes {
    __unsafe_unretained typeof(self) weakSelf = self;
    DISPATCH_SYNC_IF_NOT_IN_QUEUE(dispatch_get_main_queue(), ^{
        [weakSelf.tableView performBatchUpdates:^{
            [weakSelf.tableView reloadRowsAtIndexPaths:updateIndexes withRowAnimation:UITableViewRowAnimationFade];
            [weakSelf.tableView deleteRowsAtIndexPaths:removeIndexes withRowAnimation:(UITableViewRowAnimationLeft)];
            [weakSelf.tableView deleteSections:sectionRemove withRowAnimation:(UITableViewRowAnimationFade)];
            [weakSelf.tableView insertSections:sectionInsert withRowAnimation:(UITableViewRowAnimationFade)];
            
            [weakSelf.tableView  insertRowsAtIndexPaths:addIndexes withRowAnimation:(UITableViewRowAnimationMiddle)];
        } completion:nil];
    });
    
    DISPATCH_SYNC_IF_NOT_IN_QUEUE(dispatch_get_main_queue(), ^{
        [UIView transitionWithView:weakSelf.tableView
                          duration:0
                           options:(UIViewAnimationOptionTransitionNone)
                        animations:^{
            [weakSelf.tableView performBatchUpdates:^{
                [weakSelf.tableView reloadSections:sectionUpdate withRowAnimation:(UITableViewRowAnimationNone)];
            } completion:nil];
        } completion:nil];
    });
}

- (void)onDiffWithSectionInsert:(NSIndexSet *)sectionInsert
                  sectionRemove:(NSIndexSet *)sectionRemove
                  sectionUpdate:(NSIndexSet *)sectionUpdate {
    __unsafe_unretained typeof(self) weakSelf = self;
    DISPATCH_SYNC_IF_NOT_IN_QUEUE(dispatch_get_main_queue(), ^{
        [UIView transitionWithView:weakSelf.tableView
                          duration:0
                           options:(UIViewAnimationOptionTransitionNone)
                        animations:^{
            [weakSelf.tableView performBatchUpdates:^{
                [weakSelf.tableView deleteSections:sectionRemove withRowAnimation:(UITableViewRowAnimationFade)];
                [weakSelf.tableView insertSections:sectionInsert withRowAnimation:(UITableViewRowAnimationFade)];
            } completion:nil];
            [weakSelf.tableView reloadSections:sectionUpdate withRowAnimation:(UITableViewRowAnimationFade)];
        } completion:nil];
    });
    
}

@end


