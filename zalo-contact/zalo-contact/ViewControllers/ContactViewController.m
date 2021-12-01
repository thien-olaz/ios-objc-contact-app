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

@interface ContactViewController () <TableViewActionDelegate> {
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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configTableView];
    [self addView];
    
    [self bindViewModel];
}

- (void)bindViewModel {

    _viewModel = [ContactViewModel.alloc initWithDelegate: self];
    
    // capture weak self for binding block
    __unsafe_unretained typeof(self) weakSelf = self;
    
    [_viewModel setDataBlock:^{
        [weakSelf.tableViewDataSource compileDatasource:weakSelf.viewModel.data];
        
        [weakSelf.tableView setDataSource:weakSelf.tableViewDataSource];
        [weakSelf.tableView setDelegate:weakSelf.tableViewAction];
        [weakSelf.tableView reloadData];
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

@end

