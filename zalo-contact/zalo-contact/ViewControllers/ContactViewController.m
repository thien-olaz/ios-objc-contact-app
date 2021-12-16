//
//  ContactViewController.m
//  zalo-contact
//
//  Created by LAp14886 on 15/11/2021.
//

#import "ContactViewController.h"

#import "UIAlertControllerExt.h"
#import "ContactTableViewAction.h"
#import "ContactViewModel.h"
#import "MockAPIService.h"

@interface ContactViewController () <TableViewActionDelegate, TableViewDiffDelegate>

@property UITableView *tableView;
@property ContactTableViewAction *tableViewAction;
@property ContactTableViewDataSource *tableViewDataSource;
@property ContactViewModel *viewModel;

@end

@implementation ContactViewController

- (id)initWithViewModel:(ContactTableViewDataSource *)vm {
    self = [super init];
    _tableViewDataSource = vm;
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
    __unsafe_unretained typeof(self) weakSelf = self;
    
    [_tableView setDataSource:_tableViewDataSource];
    [_tableView setDelegate:_tableViewAction];
    
    [_tableViewAction setSwipeActionDelegate:self.viewModel];
    
    [_viewModel setTableViewDataSource:self.tableViewDataSource];
    [_viewModel setDataBlock:^{
        [weakSelf.tableViewDataSource compileDatasource:weakSelf.viewModel.data];
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.tableView reloadData];
        });
    }];
    [_viewModel setPresentBlock:^{
        [weakSelf presentViewController:[UIAlertController contactPermisisonAlert]  animated:YES completion:nil];
    }];
    [_viewModel setUpdateBlock:^{
        [weakSelf.tableViewDataSource compileDatasource:weakSelf.viewModel.data];
    }];
    _viewModel.dataBlock();
    
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

#pragma mark - TableViewDiffDelegate
- (void)onDiff:(IGListIndexPathResult *)sectionDiff cells:(NSArray<IGListIndexPathResult *> *)cellsDiff reload:(NSArray<NSIndexPath *> *)reloadIndexes{
    
    __unsafe_unretained typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSMutableIndexSet *sectionInsert = [NSMutableIndexSet indexSet];
        for (NSIndexPath *indexPath in [sectionDiff inserts]) {
            [sectionInsert addIndex:indexPath.row + [UIConstants getContactIndex]];
        }
        
        NSMutableIndexSet *sectionDelete = [NSMutableIndexSet indexSet];
        for (NSIndexPath *indexPath in [sectionDiff deletes]) {
            [sectionDelete addIndex:indexPath.row + [UIConstants getContactIndex]];
        }
        
        [weakSelf.tableView beginUpdates];
        
        [weakSelf.tableView deleteSections:sectionDelete withRowAnimation:(UITableViewRowAnimationLeft)];
        [weakSelf.tableView insertSections:sectionInsert withRowAnimation:(UITableViewRowAnimationLeft)];
        
        
        for (IGListIndexPathResult *result in cellsDiff) {
            [weakSelf.tableView deleteRowsAtIndexPaths:result.deletes withRowAnimation:(UITableViewRowAnimationLeft)];
            [weakSelf.tableView insertRowsAtIndexPaths:result.inserts withRowAnimation:(UITableViewRowAnimationLeft)];
        }
        
        [weakSelf.tableView reloadRowsAtIndexPaths:reloadIndexes withRowAnimation:UITableViewRowAnimationNone];
        
        [weakSelf.tableView endUpdates];
        
    });
    
}

#pragma mark - trying my own diff

- (void)onDiffWithSectionInsert:(NSIndexSet *)sectionInsert
                  sectionRemove:(NSIndexSet *)sectionRemove
                        addCell:(NSArray<NSIndexPath *> *)addIndexes
                     removeCell:(NSArray<NSIndexPath *> *)removeIndexes
                  andUpdateCell:(NSArray<NSIndexPath *> *)updateIndexes {
    __unsafe_unretained typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [weakSelf.tableView beginUpdates];
        
        [weakSelf.tableView reloadRowsAtIndexPaths:updateIndexes withRowAnimation:UITableViewRowAnimationNone];
        [weakSelf.tableView deleteRowsAtIndexPaths:removeIndexes withRowAnimation:(UITableViewRowAnimationLeft)];
        
        [weakSelf.tableView deleteSections:sectionRemove withRowAnimation:(UITableViewRowAnimationLeft)];                
        [weakSelf.tableView insertSections:sectionInsert withRowAnimation:(UITableViewRowAnimationLeft)];
        
        [weakSelf.tableView insertRowsAtIndexPaths:addIndexes withRowAnimation:(UITableViewRowAnimationLeft)];        
        
        
        [weakSelf.tableView endUpdates];
        [weakSelf.viewModel.updateUILock unlock];
    });
    
}

@end

