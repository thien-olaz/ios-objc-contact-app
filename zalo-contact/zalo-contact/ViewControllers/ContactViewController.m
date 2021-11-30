//
//  ContactViewController.m
//  zalo-contact
//
//  Created by LAp14886 on 15/11/2021.
//

#import "ContactViewController.h"
#import "UpdateContactHeaderCell.h"
#import "UIAlertControllerExt.h"
#import "ContactTableViewAction.h"

@interface ContactViewController () {
    UITableView *tableView;
    ContactTableViewAction *tableViewAction;
    ContactViewModel *viewModel;
    ContactsLoader *loader;
    BOOL didSetupConstraints;
}

@end

@implementation ContactViewController

- (id)initWithViewModel:(ContactViewModel *)vm {
    self = [super init];
    viewModel = vm;
    return self;
}

- (void)addView {
    [self.view addSubview:tableView];
}
//MARK: Move to ViewModel
- (void)checkPermissionAndFetchData {
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

- (void)configTableView {
    tableView = [UITableView.alloc initWithFrame:CGRectZero
                                           style:UITableViewStylePlain];
    
    
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    if (@available(iOS 15, *)) {
        [tableView setSectionHeaderTopPadding:0];
    }
    
    tableViewAction = ContactTableViewAction.new;
    
//    [tableView setDataSource:tableViewAction];
    
    
    NSMutableArray *data = NSMutableArray.alloc.init;
    
    // Mock data - replace later
    //    [data addObject:[CellItem initWithType:@"friendRequest" data:@[]]];
    //    [data addObject:[CellItem initWithType:@"addFriendFromDevice" data:@[]]];
    //    [data addObject:[CellItem initWithType:@"closeFriends" data:@[]]];
    //
    //    [data addObject:[CellItem initWithType:@"onlineFriends" data: loader.mockOnlineFriends]];
    //    [data addObject:[CellItem initWithType:@"updateContactHeaderCell" data:@[]]];
    //    for (ContactGroupEntity *group in loader.contactGroup) {
    //        [data addObject:[CellItem initWithType:@"contacts" data:group]];
    //    }
    [data addObject:HeaderObject.new];
    for (ContactEntity *contact in ((ContactGroupEntity *)loader.contactGroup[0]).contacts) {
        [data addObject:[ContactObject.alloc initWithContactEntity:contact]];
    }
    [data addObject:HeaderObject.new];
    for (ContactEntity *contact in ((ContactGroupEntity *)loader.contactGroup[0]).contacts) {
        [data addObject:[ContactObject.alloc initWithContactEntity:contact]];
    }
    [viewModel compileDatasource:data];
    
    [tableView setDataSource:viewModel];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //MARK: Hardcoded - add check permission
    loader =  [[ContactsLoader alloc] init];
    [loader update];
    
    [self configTableView];
    [self addView];
}



- (void)updateViewConstraints {
    if (!didSetupConstraints) {
        [tableView autoPinEdgesToSuperviewEdges];
        didSetupConstraints = YES;
    }
    [super updateViewConstraints];
}

@end
