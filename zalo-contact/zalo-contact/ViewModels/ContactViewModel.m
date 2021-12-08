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
#import "GCDThrottle.h"
#import "ZaloContactService.h"

@interface ContactViewModel () <ZaloContactEventListener>

@property IGListIndexPathResult *sectionDiff;
@property NSArray<IGListIndexPathResult *> *contactsDiff;

@end

@implementation ContactViewModel {
    ContactsLoader *loader;
    NSMutableArray<ContactGroupEntity *> *contactGroups;
    
    
    id<TableViewActionDelegate> actionDelegate;
    id<TableViewDiffDelegate> diffDelegate;
    
}

- (instancetype)initWithActionDelegate:(id<TableViewActionDelegate>)action
                       andDiffDelegate:(id<TableViewDiffDelegate>)diff{
    self = super.init;
    
    loader = ContactsLoader.new;
    
    actionDelegate = action;
    diffDelegate = diff;
    
    [ZaloContactService.sharedInstance subcribe:self];
    
    //        contactGroups = NSMutableArray.new;
    
    
    [self setup];
    return self;
}

// MARK: Zalo contact service observer
- (void)onReceiveNewList {
    [self updateDiff:[ContactGroupEntity groupFromContacts:ZaloContactService.sharedInstance.getFullContactDict]];
}

- (void)onAddContact:(nonnull ContactEntity *)contact {
    [self setNeedsUpdate];
}

- (void)onDeleteContact:(nonnull ContactEntity *)contact {
//    [self setNeedsUpdate];
}

- (void)onUpdateContact:(ContactEntity *)contact toContact:(ContactEntity *)newContact {
    [self setNeedsUpdate];
}

- (void)setNeedsUpdate {
    __weak typeof(self) weakSelf = self;
    dispatch_throttle_by_type(10, GCDThrottleTypeInvokeAndIgnore, ^{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0ul), ^{
            [weakSelf updateDiff:[ContactGroupEntity groupFromContacts:ZaloContactService.sharedInstance.getFullContactDict]];
        });
    });
}

- (void)updateIfNeeded {
    [self updateDiff:[ContactGroupEntity groupFromContacts:ZaloContactService.sharedInstance.getFullContactDict]];
}

- (void)updateDiff:(NSArray<ContactGroupEntity *> *)groups {
    if (contactGroups) {
        _sectionDiff = [self getSectionDiff:groups];
        _contactsDiff = [self getCellDiff:groups];
        [self setContactGroups:groups];
        [self updateDataWithSectionDiff:_sectionDiff cellDiff:_contactsDiff];
    } else {
        [self setContactGroups:groups];
        [self completeFetchingData];
    }
}

- (void)setup {
    [self updateDiff:[ContactGroupEntity groupFromContacts:ZaloContactService.sharedInstance.getFullContactDict]];
    //    [self checkPermissionAndFetchData];
}

- (void)setContactGroups:(NSArray<ContactGroupEntity *>*)groups {
    contactGroups = [NSMutableArray.alloc initWithArray: groups];
    _data = [self compileGroupToTableData:contactGroups];
}


- (void)completeFetchingData {
    _data = [self compileGroupToTableData:contactGroups];
    if (_dataBlock) _dataBlock();
}

- (void)updateDataWithSectionDiff:(IGListIndexPathResult *)sectionDiff cellDiff:(NSArray<IGListIndexPathResult *> *)cellDiff {
    if (_updateBlock) _updateBlock();
    [self updateUI];
    LOG(@"Updated UI");
}

- (void)updateUI {
    [diffDelegate onDiff:self.sectionDiff cells:self.contactsDiff];
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
            IGListIndexPathResult * res = IGListDiffPaths(oldIndex + 3, foundIndex + 3, oldGroup.contacts, newGroups[foundIndex].contacts, IGListDiffEquality).resultForBatchUpdates;
            if (res.inserts.count >0 || res.deletes.count > 0 || res.updates.count > 0)
                [contactsDiff addObject:res];
        }
    }
    return contactsDiff;
}

- (void)checkPermissionAndFetchData {
    [UserContacts checkAccessContactPermission:^(BOOL complete) {
        if (complete) {
            [self setNeedsUpdate];
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
         [actionDelegate attachToObject:[CommonCellObject.alloc initWithTitle:@"Clear saved data"
                                                                        image:[UIImage imageNamed:@"ct_people"] tintColor:UIColor.blackColor]
                                 action:^{
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"contactDict"];
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"accountDict"];
    }]
    ];
    
    [data addObject:
         [actionDelegate attachToObject:
          [CommonCellObject.alloc initWithTitle:@"Xoá bớt"
                                          image:[UIImage imageNamed:@"ct_people"] tintColor:UIColor.blackColor]
                                 action:^{} ]
    ];
    
    [data addObject:
         [actionDelegate attachToObject:
          [CommonCellObject.alloc initWithTitle:@"Tìm kiếm"
                                          image:[UIImage imageNamed:@"ct_people"] tintColor:UIColor.blackColor]
                                 action:^{
        
        NSIndexPath *idp = [weakSelf.tableViewDataSource indexPathForObject:[ContactObject.alloc initWithContactEntity:[ContactEntity.alloc initWithFirstName:@"Thien"
                                                                                                                                                     lastName:@"Abbott"
                                                                                                                                                  phoneNumber:@"0123456789"
                                                                                                                                                     subtitle:nil]]];
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
    ActionHeaderObject *contactHeaderObject = [ActionHeaderObject.alloc
                                               initWithTitle:@"Danh bạ"
                                               andButtonTitle:@"CẬP NHẬP"];
    
    [contactHeaderObject setBlock:^{
        [self fetchLocalContactIntoList];
    }];
    
    [data addObject:contactHeaderObject];
    for (ContactGroupEntity *group in groups) {
        
        // Header
        [data addObject:[ShortHeaderObject.alloc initWithTitle:group.header andTitleLetter:group.header]];
        
        // Contact
        for (ContactEntity *contact in group.contacts) {
            [data addObject:
                 [actionDelegate attachToObject:[ContactObject.alloc initWithContactEntity:contact]
                                    swipeAction:[self getActionListForContact:contact]]
            ];
        }
        
        // Footer
        [data addObject:ContactFooterObject.new];
    }
        
    
    return data;
}

- (NSArray<SwipeActionObject *>*)getActionListForContact:(ContactEntity *)contact {
    NSMutableArray *arr = NSMutableArray.new;
    [arr addObject:[SwipeActionObject.alloc initWithTile:@"Xoá" color:UIColor.redColor action:^{
        [ZaloContactService.sharedInstance deleteContactWithPhoneNumber:contact.phoneNumber];
        [self updateIfNeeded];
    }]];
    [arr addObject:[SwipeActionObject.alloc initWithTile:@"Bạn thân" color:UIColor.blueColor action:^{
        
    }]];
    [arr addObject:[SwipeActionObject.alloc initWithTile:@"Thêm" color:UIColor.lightGrayColor action:^{
        
    }]];
    return arr.copy;
}

//MARK: - replace with a view controller to select which contact will be adModed into list later
/*
 after added new contacts, this contact must be sync
 */
- (void)fetchLocalContactIntoList{
    [ZaloContactService.sharedInstance fetchLocalContact];
    [self setNeedsUpdate];
}


@end
