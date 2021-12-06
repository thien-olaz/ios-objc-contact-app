//
//  ContactViewModel.m
//  zalo-contact
//
//  Created by Thiện on 01/12/2021.
//

#import "ContactViewModel.h"
#import "CommonCell.h"
#import "BlankFooterView.h"
#import "CommonHeaderAndFooterViews.h"
#import "ActionHeaderView.h"
#import "ContactObject.h"
#import "NSStringExt.h"

@implementation ContactViewModel {
    ContactsLoader *loader;
    NSMutableArray<ContactGroupEntity *> *contactGroups;
    id<TableViewActionDelegate> actionDelegate;
    id<TableViewDiffDelegate> diffDelegate;
    id<APIServiceProtocol> apiService;
}

- (instancetype)initWithActionDelegate:(id<TableViewActionDelegate>)action
                       andDiffDelegate:(id<TableViewDiffDelegate>)diff
                            apiService:(id<APIServiceProtocol>)api{
    self = super.init;
    
    loader = ContactsLoader.new;
    
    actionDelegate = action;
    diffDelegate = diff;
    apiService = api;
    [apiService setOnContactAdded:^(ContactEntity * newContact) {
        LOG(newContact.description);
        NSMutableDictionary<NSString*, NSArray<ContactEntity*>*> *contactDict = NSMutableDictionary.new;
        [contactDict setObject:@[newContact] forKey: newContact.header];
        [loader addContact:contactDict returnBlock:^(NSArray<ContactGroupEntity *> *  groups) {
            IGListIndexPathResult *sectionDiff = [self getSectionDiff:groups];
            NSMutableArray<IGListIndexPathResult *> *contactsDiff = [self getCellDiff:groups];
            
            [self setContactGroups:groups] ;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self updateDataWithSectionDiff:sectionDiff cellDiff:contactsDiff];
            });
        }];
    }];
    
    [apiService setOnContactDeleted:^(ContactEntity * deleteContact) {
        
    }];
    
    [apiService setOnContactUpdated:^(ContactEntity * oldContact, ContactEntity * updatedContact) {
        
    }];
    [apiService fakeServerUpdate];
    [self setup];
    return self;
}

- (void)addContact:(ContactEntity *)contact {
    
}

- (void)deleteContact:(ContactEntity *)contact {
    
}

- (void)updaContact:(ContactEntity *)contact toContact:(ContactEntity *)updatedContact {
    
}

- (void)setup {
    [self performSelectorInBackground:@selector(loadSavedData) withObject:nil];
    [self checkPermissionAndFetchData];
}

- (void)loadSavedData {
    [loader loadSavedData:^(NSArray<ContactGroupEntity *> * groups) {
        [self setContactGroups:groups] ;
        [self performSelectorOnMainThread:@selector(completeFetchingData) withObject:nil waitUntilDone:NO];
    }];
}

- (void)fetchData {
    [loader fetchData:^(NSArray<ContactGroupEntity *> *  groups) {
        IGListIndexPathResult *sectionDiff = [self getSectionDiff:groups];
        NSMutableArray<IGListIndexPathResult *> *contactsDiff = [self getCellDiff:groups];
        
        [self setContactGroups:groups] ;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateDataWithSectionDiff:sectionDiff cellDiff:contactsDiff];
        });
    }];
}

- (void)setContactGroups:(NSArray<ContactGroupEntity *>*)groups {
    contactGroups = [NSMutableArray.alloc initWithArray: groups];
    _data = [self compileGroupToTableData:contactGroups];
}

- (void)completeFetchingData {
    if (_dataBlock) _dataBlock();
}

- (void)updateDataWithSectionDiff:(IGListIndexPathResult *)sectionDiff cellDiff:(NSArray<IGListIndexPathResult *> *)cellDiff {
    if (_updateBlock) _updateBlock();
    [diffDelegate onDiff:sectionDiff cells:cellDiff];
}

- (IGListIndexPathResult *)getSectionDiff:(NSArray<ContactGroupEntity *> *)newGroups {
    IGListIndexPathResult * sectionDiff = [IGListDiffPaths(0, 0, contactGroups, newGroups, IGListDiffEquality) resultForBatchUpdates];
    return sectionDiff;
}

- (NSMutableArray<IGListIndexPathResult *> *)getCellDiff:(NSArray<ContactGroupEntity *>*)newGroups {
    
    NSMutableArray<IGListIndexPathResult *> *contactsDiff = NSMutableArray.array;
    
    for (ContactGroupEntity *oldGroup in contactGroups) {
        NSUInteger oldIndex = [contactGroups indexOfObject:oldGroup];
        NSUInteger foundIndex = [newGroups indexOfObject:oldGroup];
        if (foundIndex != NSNotFound) {
            [contactsDiff addObject:
                 [IGListDiffPaths(oldIndex + 3, foundIndex + 3, oldGroup.contacts, newGroups[foundIndex].contacts, IGListDiffEquality) resultForBatchUpdates]
            ];
        }
    }
    return contactsDiff;
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

- (NSMutableArray *)compileGroupToTableData:(NSMutableArray<ContactGroupEntity *>*)groups {
    NSMutableArray *data = NSMutableArray.alloc.init;
    __unsafe_unretained typeof(self) weakSelf = self;
    //MARK:  - mấy cell đầu danh bạ
    [data addObject:[NullHeaderObject.alloc initWithLeter:UITableViewIndexSearch]];
    [data addObject:
         [actionDelegate attachToObject:[CommonCellObject.alloc initWithTitle:@"Load thêm"
                                                                        image:[UIImage imageNamed:@"ct_people"] tintColor:UIColor.blackColor]
                                 action:^{
        [weakSelf->loader mockFetchDataWithReapeatTime:1 andBlock:^(NSArray<ContactGroupEntity *> * groups) {
            IGListIndexPathResult *sectionDiff = [self getSectionDiff:groups];
            NSMutableArray<IGListIndexPathResult *> *contactsDiff = [self getCellDiff:groups];
            
            [self setContactGroups:groups] ;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self updateDataWithSectionDiff:sectionDiff cellDiff:contactsDiff];
            });
        }];
    }]
    ];
    [data addObject:
         [actionDelegate attachToObject:
          [CommonCellObject.alloc initWithTitle:@"Xoá bớt"
                                          image:[UIImage imageNamed:@"ct_people"] tintColor:UIColor.blackColor]
                                 action:^{
        [weakSelf->loader mockFetchDataWithReapeatTime:-1 andBlock:^(NSArray<ContactGroupEntity *> * groups) {
            IGListIndexPathResult *sectionDiff = [self getSectionDiff:groups];
            NSMutableArray<IGListIndexPathResult *> *contactsDiff = [self getCellDiff:groups];
            
            [self setContactGroups:groups] ;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self updateDataWithSectionDiff:sectionDiff cellDiff:contactsDiff];
            });
        }];
    } ]
    ];
    
    [data addObject:
         [actionDelegate attachToObject:
          [CommonCellObject.alloc initWithTitle:@"Tìm kiếm"
                                          image:[UIImage imageNamed:@"ct_people"] tintColor:UIColor.blackColor]
                                 action:^{
        
        NSIndexPath *idp = [weakSelf.tableViewDataSource indexPathForObject:[ContactObject.alloc initWithContactEntity:[ContactEntity.alloc initWithFirstName:@"Thien"
                                                                                                                          lastName:@"Abbott"
                                                                                                                       phoneNumber:@"0123456789"]]];
        if (idp) [weakSelf->actionDelegate scrollTo:idp];
    } ]
    ];
    
    [data addObject:BlankFooterObject.new];
    
    //MARK:  - bạn thân
    [data addObject:[ShortHeaderObject.alloc initWithTitle:@"Bạn thân"]];
    [data addObject:
         [actionDelegate attachToObject:
          [CommonCellObject.alloc initWithTitle:@"Chọn bạn thường liên lạc"
                                          image:[UIImage imageNamed:@"ct_plus"] tintColor:UIColor.zaloPrimaryColor]
                                 action:^{
        NSLog(@"Tapped");
    } ]
    ];
    [data addObject:BlankFooterObject.new];
    
    //MARK: - danh bạ
    [data addObject:[ActionHeaderObject.alloc initWithTitle:@"Danh bạ" andButtonTitle:@"Cập nhập"]];
    for (ContactGroupEntity *group in groups) {
        
        // Header
        [data addObject:[ShortHeaderObject.alloc initWithTitle:group.header andTitleLetter:group.header]];
        
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
