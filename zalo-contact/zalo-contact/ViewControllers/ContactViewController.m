//
//  ContactViewController.m
//  zalo-contact
//
//  Created by LAp14886 on 15/11/2021.
//

#import "ContactViewController.h"
#import "UpdateContactHeaderCell.h"
#import "UIAlertControllerExt.h"

@interface ContactViewController () {
    UITableView *tableView;
    ContactViewModel *viewModel;
    BOOL didSetupConstraints;
}

@end

@implementation ContactViewController

- (id) initWithViewModel:(ContactViewModel *)vm {
    self = [super init];
    viewModel = vm;
    return self;
}

- (void) addView {
    [self.view addSubview:tableView];
}

- (void) registerCell {
    [tableView registerClass:ContactCell.class
      forCellReuseIdentifier:@"contactCell"];
    [tableView registerClass:UpdateContactHeaderCell.class
      forCellReuseIdentifier:@"updateContactHeaderCell"];
    [tableView registerClass:ActionCell.class
      forCellReuseIdentifier:@"actionCell"];
    [tableView registerClass:BlankFooterCell.class
      forCellReuseIdentifier:@"grayFooterCell"];
    
}
//MARK: Move to ViewModel
- (void) checkPermissionAndFetchData {
    [UserContacts checkAccessContactPermission:^(BOOL complete) {
        if (complete) {
            [UserContacts.sharedInstance fetchLocalContacts];
            dispatch_async(dispatch_get_main_queue(), ^{
                // reload the table
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self presentViewController:[UIAlertController contactPermisisonAlert]
                                   animated:true
                                 completion:nil];
            });
        }
    }];
}

- (void) configTableView {
    tableView = [UITableView.alloc initWithFrame:CGRectZero
                                           style:UITableViewStylePlain];
    [tableView setDataSource:viewModel];
    [tableView setDelegate:viewModel];
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    if (@available(iOS 15, *)) {
        [tableView setSectionHeaderTopPadding:0];
    }
}

- (void) viewDidLoad {
    [super viewDidLoad];
    [self configTableView];
        
    [self addView];
    [self registerCell];
    
    
    [self.view setNeedsUpdateConstraints];
    
}

- (void)updateViewConstraints {
    if (!didSetupConstraints) {
        [tableView autoPinEdgesToSuperviewEdges];
        didSetupConstraints = YES;
    }
    [super updateViewConstraints];
}

@end
