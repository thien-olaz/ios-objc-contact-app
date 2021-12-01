//
//  ContactViewModel.m
//  zalo-contact
//
//  Created by Thiện on 01/12/2021.
//

#import "ContactViewModel.h"
#import "CommonCell.h"
#import "BlankFooterCell.h"
#import "CommonHeaderAndFooterViews.h"
#import "UpdateContactHeaderCell.h"
#import "ContactFooterCell.h"
#import "ContactObject.h"

@implementation ContactViewModel {
    ContactsLoader *loader;
    NSMutableArray<ContactGroupEntity *> *contactGroups;
    id<TableViewActionDelegate> actionDelegate;
}

- (instancetype)initWithDelegate:(id<TableViewActionDelegate>)delegate {
    self = super.init;
    loader = ContactsLoader.new;
    //load từ dưới đĩa lên
    //    [loader loaderSaveList];
    
    actionDelegate = delegate;
    [self checkPermissionAndFetchData];
    return self;
}

- (void)setContactGroups:(NSArray<ContactGroupEntity *>*)groups {
    contactGroups = [NSMutableArray.alloc initWithArray: groups];
    _data = [self compileGroupToDataArray:contactGroups];
}

- (void)fetchData {
    [loader fetchData:^(NSArray<ContactGroupEntity *> * _Nonnull groups) {
        [self setContactGroups:groups] ;
        [self performSelectorOnMainThread:@selector(completeFetchingData) withObject:nil waitUntilDone:NO];
    }];
}

- (void)completeFetchingData {
    if (_dataBlock) _dataBlock();
}

- (void)checkPermissionAndFetchData {
    [UserContacts checkAccessContactPermission:^(BOOL complete) {
        if (complete) {
            [self performSelectorInBackground:@selector(fetchData) withObject:nil];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                //                [self presentViewController:[UIAlertController contactPermisisonAlert]
                //                                   animated:true
                //                                 completion:nil];
            });
        }
    }];
}


- (NSMutableArray *)compileGroupToDataArray:(NSMutableArray<ContactGroupEntity *>*)groups {
    NSMutableArray *data = NSMutableArray.alloc.init;
    
    //MARK:  - mấy cell đầu danh bạ
    [data addObject:NullHeaderObject.new];
    [data addObject:
         [actionDelegate attachToObject:[CommonCellObject.alloc initWithTitle:@"Lời mời kết bạn"
                                                                        image:[UIImage imageNamed:@"ct_people"] tintColor:UIColor.blackColor]
                                 action:^{
        NSLog(@"Tapped");
    }]
    ];
    [data addObject:
         [actionDelegate attachToObject:
          [CommonCellObject.alloc initWithTitle:@"Bạn từ danh bạ máy"
                                          image:[UIImage imageNamed:@"ct_people"] tintColor:UIColor.blackColor]
                                 action:^{
        NSLog(@"Tapped");
    } ]
    ];
    
    [data addObject:BlankFooterObject.new];
    
    //MARK:  - bạn thân
    [data addObject:[ShortHeaderObject.alloc initWithTitle:@"Bạn thân"]];
    [data addObject:
         [actionDelegate attachToObject:
          [CommonCellObject.alloc initWithTitle:@"Chọn bạn thường liên lạc"
                                          image:[UIImage imageNamed:@"ct_plus"] tintColor:UIColor.blueColor]
                                 action:^{
        NSLog(@"Tapped");
    } ]
    ];
    [data addObject:BlankFooterObject.new];
    
    //MARK: - danh bạ
    [data addObject:[ShortHeaderObject.alloc initWithTitle:@"Danh bạ"]];
    for (ContactGroupEntity *group in groups) {
        
        // Header
        [data addObject:[ShortHeaderObject.alloc initWithTitle:group.header]];
        
        // Contact
        for (ContactEntity *contact in group.contacts) {
            [data addObject:[ContactObject.alloc initWithContactEntity:contact]];
        }
        // Footer
        [data addObject:BlankFooterObject.new];
    }
    
    return data;
}



@end
