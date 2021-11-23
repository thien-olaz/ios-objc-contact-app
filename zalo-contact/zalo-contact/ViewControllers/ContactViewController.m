//
//  ContactViewController.m
//  zalo-contact
//
//  Created by LAp14886 on 15/11/2021.
//

#import "ContactViewController.h"

@interface ContactViewController () {
    UITableView *tableView;
    ContactViewModel *viewModel;
    BOOL didSetupConstraints;
}

@end

@implementation ContactViewController

- (id) init {
    self = [super init];
    // MARK: change to inject
    viewModel = ContactViewModel.alloc.init;
    
    return self;
}

// MARK: - Lazy var

- (void) addView {
    [self.view addSubview:tableView];
}

- (void) registerCell {
    [tableView registerClass:ContactCell.class forCellReuseIdentifier:@"contactCell"];
}
//MARK: Move to ViewModel
- (void) checkPermissionAndFetchData {
    [UserContacts checkAccessContactPermission:^(BOOL complete) {
        if (complete) {
            [UserContacts.sharedInstance fetchLocalContacts];
            dispatch_async(dispatch_get_main_queue(), ^{
                
            });
        } else {
            UIAlertController *alertController = [UIAlertController
                                                  alertControllerWithTitle:@"No permission"
                                                  message:@"Please go to setting and turn on contact access permission"
                                                  preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction
                                     actionWithTitle:@"Open setting"
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * _Nonnull action)
                                     {
                // Open setting
                [UIApplication.sharedApplication
                 openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]
                 options:@{}
                 completionHandler:^(BOOL Success){}];
            }];
            
            [alertController addAction:action];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self presentViewController:alertController animated:true completion:nil];
            });
        }
    }];
}

- (void) viewDidLoad {
    [super viewDidLoad];

    tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    [tableView setDataSource:viewModel];
    [tableView setDelegate:viewModel];
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    if (@available(iOS 15, *)) {
        [tableView setSectionHeaderTopPadding:0];
    }
            
    [self addView];
    [self registerCell];
    
//        [self checkPermissionAndFetchData];
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
