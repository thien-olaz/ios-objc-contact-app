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
#import "CommonHeaderAndFooterViews.h"


@interface ContactViewController () {
    UITableView *tableView;
    ContactTableViewAction *tableViewAction;
    ContactTableViewDataSource *tableViewDataSource;
    ContactViewModel *viewModel;
    ContactsLoader *loader;
    BOOL didSetupConstraints;
}

@end

@implementation ContactViewController

- (id)initWithViewModel:(ContactTableViewDataSource *)vm {
    self = [super init];
    tableViewDataSource = vm;
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
    
    NSMutableArray *data = NSMutableArray.alloc.init;
    
    [data addObject:NullHeaderObject.new];
    [data addObject:
         [tableViewAction attachToObject:
          [CommonCellObject.alloc initWithTitle:@"Lời mời kết bạn"
                                          image:[UIImage imageNamed:@"ct_people"] tintColor:UIColor.blackColor]
                                  action:^{
        NSLog(@"Tapped");
    } ]
    ];
    [data addObject:
         [tableViewAction attachToObject:
          [CommonCellObject.alloc initWithTitle:@"Bạn từ danh bạ máy"
                                          image:[UIImage imageNamed:@"ct_people"] tintColor:UIColor.blackColor]
                                  action:^{
        NSLog(@"Tapped");
    } ]
    ];
    
    [data addObject:BlankFooterObject.new];
    
    
    [data addObject:[ShortHeaderObject.alloc initWithTitle:@"Bạn thân"]];
    [data addObject:
         [tableViewAction attachToObject:
          [CommonCellObject.alloc initWithTitle:@"Chọn bạn thường liên lạc"
                                          image:[UIImage imageNamed:@"ct_plus"] tintColor:UIColor.blueColor]
                                  action:^{
        NSLog(@"Tapped");
    } ]
    ];
    
    
    [data addObject:BlankFooterObject.new];
    [data addObject:[ShortHeaderObject.alloc initWithTitle:@"Danh bạ"]];
    [data addObject:[ShortHeaderObject.alloc initWithTitle:@"A"]];
    
    for (ContactEntity *contact in ((ContactGroupEntity *)loader.contactGroup[0]).contacts) {
        [data addObject:
             [tableViewAction attachToObject: [ContactObject.alloc initWithContactEntity:contact]
                                      action:^{
            NSLog(@"Tapped");
        } ]
        ];
    }
    
    [data addObject:BlankFooterObject.new];
    [data addObject:HeaderObject.new];
    
    for (ContactEntity *contact in ((ContactGroupEntity *)loader.contactGroup[0]).contacts) {
        [data addObject:[ContactObject.alloc initWithContactEntity:contact]];
    }
    
    [data addObject:[FooterObject.alloc initWithFooterClass:ContactFooterCell.class]];
    
    [tableViewDataSource compileDatasource:data];
    
    [tableView setDataSource:tableViewDataSource];
    [tableView setDelegate:tableViewAction];
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
