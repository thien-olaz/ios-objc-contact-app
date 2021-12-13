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
#import "ZaloContactService+Observer.h"
#import "ContactGroupEntity.h"

@interface ContactViewModel () <ZaloContactEventListener>

@property IGListIndexPathResult *sectionDiff;
@property NSArray<IGListIndexPathResult *> *contactsDiff;
@property NSArray<NSIndexPath *> *reloadIndexes;
@property NSMutableArray<NSIndexPath *> *deleteIndexes;

@end

@implementation ContactViewModel {
    NSMutableArray<ContactGroupEntity *> *contactGroups;
    id<TableViewActionDelegate> actionDelegate;
    id<TableViewDiffDelegate> diffDelegate;
    id currentState;
    NSLock *updateUILock;
}

- (instancetype)initWithActionDelegate:(id<TableViewActionDelegate>)action
                       andDiffDelegate:(id<TableViewDiffDelegate>)diff{
    self = super.init;
    
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

- (void)onDeleteContact:(nonnull ContactEntity *)contact {

}

// Tìm indexpath dựa trên contact entity trong tableview
- (NSArray<NSIndexPath*>*)getIndexesInTablviewFromContactArray:(ContactEntityArray*)array exceptInSecion:(NSArray<NSString *>*)exception {
    NSMutableArray<NSIndexPath *> *indexes = [NSMutableArray new];
    for (ContactEntity *contact in array) {
        if ([exception containsObject:contact.header]) continue;
        NSIndexPath *indexPath = [self.tableViewDataSource indexPathForContactEntity:contact];
        if (indexPath && ![indexes containsObject:indexPath]) {
            [indexes addObject:indexPath];
        }
    }
    return indexes.copy;
}


- (NSArray<NSIndexPath*>*)getInsertIndexesInTablviewFromContactArray:(ContactEntityArray*)array exceptInSecion:(NSArray<NSString *>*)exception{
    NSMutableArray<NSIndexPath *> *indexes = [NSMutableArray new];
    for (ContactEntity *contact in array) {
        if ([exception containsObject:contact.header]) continue;
        NSIndexPath *indexPath = [self.tableViewDataSource insertIndexPathForContactEntity:contact];
        if (indexPath) [indexes addObject:indexPath];
        
    }
    return indexes.copy;
}

- (NSIndexSet*)getSectionInsertIndexesInTablviewFromSectionArray:(NSArray<NSString*>*)array {
    NSMutableArray *headerList = ((NSArray*)[contactGroups valueForKey:@"header"]).mutableCopy;
    NSMutableIndexSet *indexes = [NSMutableIndexSet new];
    for (NSString *header in array) {
        NSUInteger foundIndex = [headerList indexOfObject:header inSortedRange:NSMakeRange(0, [headerList count]) options:NSBinarySearchingInsertionIndex usingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
            return [obj1 compare:obj2];
        }];
        [headerList insertObject:header atIndex:foundIndex];
    }
    for (NSString *header in array) {
        NSUInteger foundIndex = [headerList indexOfObject:header inSortedRange:NSMakeRange(0, [headerList count]) options:NSBinarySearchingInsertionIndex usingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
            return [obj1 compare:obj2];
        }];
        [indexes addIndex:foundIndex + 3];
    }
    return indexes.copy;
}

- (NSIndexSet*)getSectionIndexesInTablviewFromSectionArray:(NSArray<NSString*>*)array {
    NSArray *headerList = [contactGroups valueForKey:@"header"];
    NSMutableIndexSet *indexes = [NSMutableIndexSet new];
    for (NSString *header in array) {
        NSUInteger foundIndex = [headerList indexOfObject:header];
        if (foundIndex != NSNotFound) [indexes addIndex:foundIndex + 3];
    }
    return indexes.copy;
}

- (void)onServerChangeWithAddSectionList:(NSMutableArray<NSString *>*)addSectionList
                                        removeSectionList:(NSMutableArray<NSString *>*)removeSectionList
                              addContact:(ContactEntityArray*)addContacts
                              removeContact:(ContactEntityArray*)removeContacts
                           updateContact:(ContactEntityArray*)updateContacts {
    
    NSArray<NSIndexPath *> *removeIndexes = [self getIndexesInTablviewFromContactArray:removeContacts exceptInSecion:removeSectionList];

    NSIndexSet *sectionRemove = [self getSectionIndexesInTablviewFromSectionArray:removeSectionList];
    
    //cập nhập bản data mới nhất vào data của view model
    [self setContactGroups:[ContactGroupEntity groupFromContacts:ZaloContactService.sharedInstance.getFullContactDict]];
    //cập nhập datasource của tableview
    if (_updateBlock) _updateBlock();
    
    NSArray<NSIndexPath *> *addIndexes = [self getIndexesInTablviewFromContactArray:addContacts exceptInSecion:addSectionList];
    NSIndexSet *sectionInsert = [self getSectionIndexesInTablviewFromSectionArray:addSectionList];
    
    NSArray<NSIndexPath *> *updateIndexes = [self getIndexesInTablviewFromContactArray:updateContacts exceptInSecion:@[]];
    
    [diffDelegate onDiffWithSectionInsert:sectionInsert sectionRemove:sectionRemove addCell:addIndexes removeCell:removeIndexes andUpdateCell:updateIndexes];    
}

- (void)updateDiff:(NSArray<ContactGroupEntity *> *)groups {
    [updateUILock lock];
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
    [updateUILock unlock];
}

- (void)setup {
    [self updateDiff:[ContactGroupEntity groupFromContacts:ZaloContactService.sharedInstance.getFullContactDict]];
}

- (void)setContactGroups:(NSArray<ContactGroupEntity *>*)groups {
    contactGroups = [NSMutableArray.alloc initWithArray: groups];
    _data = [self compileGroupToTableData:contactGroups];
    NSLog(@"==============================");
    NSLog(@"======New update circle=======");
    NSLog(@"==============================");
}


- (void)completeFetchingData {
    _data = [self compileGroupToTableData:contactGroups];
    if (_dataBlock) _dataBlock();
}

- (void)updateDataWithSectionDiff:(IGListIndexPathResult *)sectionDiff cellDiff:(NSArray<IGListIndexPathResult *> *)cellDiff {
    if (_updateBlock) _updateBlock();
    [diffDelegate onDiff:self.sectionDiff cells:self.contactsDiff reload:self.reloadIndexes];
}

- (IGListIndexPathResult *)getSectionDiff:(NSArray<ContactGroupEntity *> *)newGroups {
    IGListIndexPathResult * sectionDiff = [IGListDiffPaths(0, 0, contactGroups, newGroups, IGListDiffEquality) resultForBatchUpdates];
    return sectionDiff;
}

// MARK: - make it dynamic please
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

// MARK: - make it dynamic please
- (NSArray<NSIndexPath *> *)getReloadIndexes:(NSArray<ContactGroupEntity *>*)newGroups {
    NSIndexPath *totalContactsIdp0;
    totalContactsIdp0 = [NSIndexPath indexPathForRow:0 inSection:3 + newGroups.count];
    return @[totalContactsIdp0];
}

- (void)checkPermissionAndFetchData {
    typeof(self) weakSelf = self;
//    [UserContacts checkAccessContactPermission:^(BOOL complete) {
//        if (complete) {
//            [self performSelectorInBackground:@selector(fetchLocalContacts) withObject:nil];
//        } else {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                if (weakSelf.presentBlock) weakSelf.presentBlock();
//            });
//        }
//    }];
}

- (void)fetchLocalContacts {
    [ZaloContactService.sharedInstance fetchLocalContact];
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

- (NSMutableArray *)compileGroupToTableData:(NSMutableArray<ContactGroupEntity *>*)groups {
    NSMutableArray *data = NSMutableArray.alloc.init;
    __unsafe_unretained typeof(self) weakSelf = self;
    //MARK:  -
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
    
    [data addObject:[actionDelegate attachToObject:[[CommonCellObject alloc] initWithTitle:@"Tìm kiếm (866) 420-3189" image:[UIImage imageNamed:@"ct_people"] tintColor:UIColor.blackColor] action:^{
        NSIndexPath *idp = [weakSelf.tableViewDataSource indexPathForPhoneNumber:@"(922) 471-2199"];
        if (idp) [weakSelf->actionDelegate scrollTo:idp];
    }]];
    
    [data addObject:BlankFooterObject.new];
    
    //MARK:  - bạn thân
    [data addObject:[ShortHeaderObject.alloc initWithTitle:@"Bạn thân"]];
    
    [data addObject:[actionDelegate attachToObject:[[CommonCellObject alloc] initWithTitle:@"Chọn bạn thường liên lạc" image:[UIImage imageNamed:@"ct_plus"] tintColor:UIColor.zaloPrimaryColor] action:^{
        NSLog(@"Tapped");
    }]];
    
    [data addObject:BlankFooterObject.new];
    
    //MARK: - Contact
    ActionHeaderObject *contactHeaderObject = [[ActionHeaderObject alloc] initWithTitle:@"Danh bạ" andButtonTitle:@"CẬP NHẬP"];
    
    [contactHeaderObject setBlock:^{
        [self checkPermissionAndFetchData];
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
        [self checkPermissionAndFetchData];
    }]];
    
    [data addObject:BlankFooterObject.new];
    
    
    return data;
}

@end
