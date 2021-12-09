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
#import "LabelCellObject.h"
#import "UpdateContactObject.h"

@interface ContactViewModel () <ZaloContactEventListener>

@property IGListIndexPathResult *sectionDiff;
@property NSArray<IGListIndexPathResult *> *contactsDiff;
@property NSArray<NSIndexPath *> *reloadIndexes;

@property NSMutableArray<NSIndexPath *> *deleteIndexes;

@end

@implementation ContactViewModel {
    ContactsLoader *loader;
    NSMutableArray<ContactGroupEntity *> *contactGroups;
    
    
    id<TableViewActionDelegate> actionDelegate;
    id<TableViewDiffDelegate> diffDelegate;
    id currentState;
}

- (instancetype)initWithActionDelegate:(id<TableViewActionDelegate>)action
                       andDiffDelegate:(id<TableViewDiffDelegate>)diff{
    self = super.init;
    
    loader = ContactsLoader.new;
    
    actionDelegate = action;
    diffDelegate = diff;
    _deleteIndexes = NSMutableArray.new;
    [ZaloContactService.sharedInstance subcribe:self];
    
    
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
    id newState = @(ZaloContactService.sharedInstance.getFullContactDict.description.hash);
    if (currentState) {
        if (currentState == newState) return;
    }
    currentState = newState;
    
//    NSIndexPath *deleteIdp = [self.tableViewDataSource indexPathForPhoneNumber: contact.phoneNumber];
    NSIndexPath *deleteIdp = [self.tableViewDataSource indexPathForContactEntity:contact];
    
    if (!deleteIdp) return;
    if (![_deleteIndexes containsObject:deleteIdp]) {
        [_deleteIndexes addObject:deleteIdp];
    }
    
    [self applyDeleteIndexes:[ContactGroupEntity groupFromContacts:ZaloContactService.sharedInstance.getFullContactDict]];
    
}

- (void)onUpdateContact:(ContactEntity *)contact toContact:(ContactEntity *)newContact {
    [self setNeedsUpdate];
}

- (void)setNeedsUpdate {
    __weak typeof(self) weakSelf = self;
    dispatch_throttle_by_type(2, GCDThrottleTypeInvokeAndIgnore, ^{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0ul), ^{
            [weakSelf updateDiff:[ContactGroupEntity groupFromContacts:ZaloContactService.sharedInstance.getFullContactDict]];
        });
    });
}

- (void)updateIfNeeded {
    [self updateDiff:[ContactGroupEntity groupFromContacts:ZaloContactService.sharedInstance.getFullContactDict]];
}

- (void)applyDeleteIndexes:(NSArray<ContactGroupEntity *> *)groups {
    _sectionDiff = [self getSectionDiff:groups];
    _reloadIndexes = [self getReloadIndexes: contactGroups];
    [self setContactGroups:groups];
    if (_updateBlock) _updateBlock();
    [diffDelegate onDiff:_sectionDiff delete:_deleteIndexes.copy reload:_reloadIndexes];
    [self.deleteIndexes removeAllObjects];
}

- (void)updateDiff:(NSArray<ContactGroupEntity *> *)groups {
    if (contactGroups) {
        _sectionDiff = [self getSectionDiff:groups];
        _contactsDiff = [self getCellDiff:groups];
        _reloadIndexes = [self getReloadIndexes: contactGroups];
        [self setContactGroups:groups];
        [self updateDataWithSectionDiff:_sectionDiff cellDiff:_contactsDiff];
    } else {
        [self setContactGroups:groups];
        [self completeFetchingData];
    }
}

- (void)setup {
    [self updateDiff:[ContactGroupEntity groupFromContacts:ZaloContactService.sharedInstance.getFullContactDict]];
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
    
}

- (void)updateUI {
    LOG(@"Updated UI");
    [diffDelegate onDiff:self.sectionDiff cells:self.contactsDiff reload:self.reloadIndexes];
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

- (NSArray<NSIndexPath *> *)getReloadIndexes:(NSArray<ContactGroupEntity *>*)newGroups {
    NSIndexPath *totalContactsIdp0;
    totalContactsIdp0 = [NSIndexPath indexPathForRow:0 inSection:3 + newGroups.count];
    return @[totalContactsIdp0];
}

- (void)checkPermissionAndFetchData {
    [UserContacts checkAccessContactPermission:^(BOOL complete) {
        if (complete) {
            [self performSelectorInBackground:@selector(fetchLocalContacts) withObject:nil];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (_presentBlock) _presentBlock();
            });
        }
    }];
}

- (void)fetchLocalContacts {
    [ZaloContactService.sharedInstance fetchLocalContact];
    [self setNeedsUpdate];
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
          [CommonCellObject.alloc initWithTitle:@"Tìm kiếm (866) 420-3189"
                                          image:[UIImage imageNamed:@"ct_people"] tintColor:UIColor.blackColor]
                                 action:^{
        
        NSIndexPath *idp = [weakSelf.tableViewDataSource indexPathForPhoneNumber:@"(922) 471-2199"];
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
    
    int totalContact = 0;
    
    for (ContactGroupEntity *group in groups) {
        
        totalContact += group.contacts.count;
        // Header
        [data addObject:[ShortHeaderObject.alloc initWithTitle:group.header andTitleLetter:group.header]];
        
        // Contact
        for (ContactEntity *contact in group.contacts) {
            [data addObject:
                 [actionDelegate attachToObject:[ContactObject.alloc initWithContactEntity:contact]
                                    swipeAction:[self getActionListForContact]]
            ];
        }
        
        // Footer
        [data addObject:ContactFooterObject.new];
    }
    if (groups.count > 0) {
        [data removeLastObject];
    }
    
    [data addObject:[NullHeaderObject.alloc init]];
    
    [data addObject:[LabelCellObject.alloc initWithTitle:[NSString stringWithFormat:@"%d bạn", totalContact] andTextAlignment:NSTextAlignmentCenter color:UIColor.zaloBackgroundColor cellType:shortCell]];
    
    [data addObject:[LabelCellObject.alloc initWithTitle:@"Nhanh chóng thêm bạn vào Zalo từ danh \nbạ điện thoại" andTextAlignment:NSTextAlignmentCenter color:UIColor.zaloLightGrayColor cellType:tallCell]];
    
    [data addObject:[UpdateContactObject.alloc initWithTitle:@"Cập nhập danh bạ" andAction:^{
        [self fetchLocalContactIntoList];
    }]];
    
    [data addObject:BlankFooterObject.new];
    
    
    return data;
}

- (void)deleteContactWithPhoneNumber:(NSString *)phoneNumber {
    [ZaloContactService.sharedInstance deleteContactWithPhoneNumber:phoneNumber];
}

- (void)performAction:(SwipeActionType)type forObject:(CellObject *)object {
    ContactObject *contactObject = (ContactObject*)object;
    if (contactObject) {
        [self performSelectorInBackground:@selector(deleteContactWithPhoneNumber:) withObject:contactObject.contact.phoneNumber];
    }
}

- (NSArray<SwipeActionObject *>*)getActionListForContact{
    NSMutableArray *arr = NSMutableArray.new;
    [arr addObject:[SwipeActionObject.alloc initWithTile:@"Xoá" color:UIColor.zaloRedColor actionType:(deleteAction)]];
    [arr addObject:[SwipeActionObject.alloc initWithTile:@"Bạn thân" color:UIColor.zaloPrimaryColor actionType:(markAsFavoriteAction)]];
    [arr addObject:[SwipeActionObject.alloc initWithTile:@"Thêm" color:UIColor.lightGrayColor actionType:(moreAction)]];
    return arr.copy;
}

//MARK: - replace with a view controller to select which contact will be adModed into list later
/*
 after added new contacts, this contact must be sync
 */
- (void)fetchLocalContactIntoList{
    [self checkPermissionAndFetchData];
}


@end
