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

@interface ContactViewController () <TableViewActionDelegate, TableViewDiffDelegate> {
    BOOL didSetupConstraints;
}

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
    _tableViewAction = ContactTableViewAction.new;
}

- (void)bindViewModel {
    _viewModel = [ContactViewModel.alloc initWithActionDelegate:self andDiffDelegate:self];
    
    // capture weak self for binding block
    __unsafe_unretained typeof(self) weakSelf = self;
    [_tableView setDataSource:_tableViewDataSource];
    [_tableView setDelegate:_tableViewAction];
    
    [_viewModel setDataBlock:^{
        [weakSelf.tableViewDataSource compileDatasource:weakSelf.viewModel.data];
        [weakSelf.tableView reloadData];
    }];
    
    [_viewModel setUpdateBlock:^{
        [weakSelf.tableViewDataSource compileDatasource:weakSelf.viewModel.data];
    }];
    
}


- (void)updateViewConstraints {
    if (!didSetupConstraints) {
        [_tableView autoPinEdgesToSuperviewEdges];
        didSetupConstraints = YES;
    }
    [super updateViewConstraints];
}

#pragma mark - TableViewActionDelegate
- (CellObject *)attachToObject:(CellObject *)object action:(TapBlock)tapped {
    if (!_tableViewAction) {
        _tableViewAction = ContactTableViewAction.new;
    }
    return [_tableViewAction attachToObject:object action:tapped];
}

#pragma mark - TableViewDiffDelegate
- (void)onDiff:(IGListIndexPathResult *)sectionDiff cells:(NSArray<IGListIndexPathResult *> *)cellsDiff {

    __unsafe_unretained typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.tableView beginUpdates];

        NSMutableIndexSet *sectionInsert = [NSMutableIndexSet indexSet];
        for (NSIndexPath *indexPath in [sectionDiff inserts]) {
            [sectionInsert addIndex:indexPath.row + 3];
        }

        NSMutableIndexSet *sectionDelete = [NSMutableIndexSet indexSet];
        for (NSIndexPath *indexPath in [sectionDiff deletes]) {
            [sectionDelete addIndex:indexPath.row + 3];
        }

        [weakSelf.tableView insertSections:sectionInsert withRowAnimation:(UITableViewRowAnimationLeft)];
        [weakSelf.tableView deleteSections:sectionDelete withRowAnimation:(UITableViewRowAnimationLeft)];

        for (IGListIndexPathResult *result in cellsDiff) {
            [weakSelf.tableView insertRowsAtIndexPaths:result.inserts withRowAnimation:(UITableViewRowAnimationLeft)];
            [weakSelf.tableView deleteRowsAtIndexPaths:result.deletes withRowAnimation:(UITableViewRowAnimationLeft)];
        }

        [weakSelf.tableView endUpdates];
    });
    
    
}
@end

