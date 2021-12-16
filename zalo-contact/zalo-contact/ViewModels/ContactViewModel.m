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
@property AccountDictionary *accountDictionary;
//sync datasource and tableview update to avoid crash
@property NSLock *updateTableViewLock;

@end

@implementation ContactViewModel {
    NSMutableArray<ContactGroupEntity *> *contactGroups;
    OnlineContactEntityArray *onlineContacts;
    id<TableViewActionDelegate> actionDelegate;
    id<TableViewDiffDelegate> diffDelegate;
    id currentState;
    ContactDictionary *oldctd;
}

- (instancetype)initWithActionDelegate:(id<TableViewActionDelegate>)action
                       andDiffDelegate:(id<TableViewDiffDelegate>)diff{
    self = super.init;
    actionDelegate = action;
    diffDelegate = diff;
    _deleteIndexes = [NSMutableArray new];
    _updateTableViewLock = [NSLock new];
    [ZaloContactService.sharedInstance subcribe:self];
    [self setup];
    return self;
}

///double check if load data from device take time
///if data loaded from server is called before device 
- (void)onLoadSavedDataComplete:(ContactDictionary *)loadedData {
    if (contactGroups.count) return;
    if (!loadedData.count) return;
    
    [self setContactGroups:[ContactGroupEntity groupFromContacts:loadedData]];
    if (_dataBlock) _dataBlock();
}

// find indexpath with contact entity
- (NSArray<NSIndexPath*>*)indexesFromIdArray:(NSArray<NSString *>*)array exceptInSecion:(NSArray<NSString *>*)exception {
    NSMutableArray<NSIndexPath *> *indexes = [NSMutableArray new];
    for (NSString *accountId in array) {
        ContactEntity *contact = [self.accountDictionary objectForKey:accountId];
        if (!contact) {
            NSLog(@"cant found cntact %@", accountId);
            continue;
        }
//        if ([exception containsObject:contact.header]) continue;
        NSIndexPath *indexPath = [self.tableViewDataSource indexPathForContactEntity:contact];
        if (indexPath && ![indexes containsObject:indexPath]) {
            [indexes addObject:indexPath];
        } else {
            NSLog(@"cant found index %@", contact);
        }
    }
    return indexes.copy;
}

- (NSIndexSet*)sectionIndexesFromHeaderArray:(NSArray<NSString*>*)array {
    NSArray *headerList = [contactGroups valueForKey:@"header"];
    NSMutableIndexSet *indexes = [NSMutableIndexSet new];
    for (NSString *header in array) {
        NSUInteger foundIndex = [headerList indexOfObject:header];
        if (foundIndex != NSNotFound) [indexes addIndex:foundIndex + [UIConstants getContactIndex]];
    }
    return indexes.copy;
}

- (void)onServerChangeWithAddSectionList:(NSMutableArray<NSString *> *)addSectionList
                       removeSectionList:(NSMutableArray<NSString *> *)removeSectionList
                              addContact:(AccountIdSet *)addContacts
                           removeContact:(AccountIdSet *)removeContacts
                           updateContact:(AccountIdSet *)updateContacts
                          newContactDict:(ContactDictionary *)contactDict
                          newAccountDict:(AccountDictionary *)accountDict {
    [_updateUILock lock];
    
    
    NSArray<NSIndexPath *> *removeIndexes = [self indexesFromIdArray:removeContacts.copy exceptInSecion:removeSectionList];
//    NSLog(@"remove index %lu contacts %lu", removeIndexes.count, removeContacts.count);
    NSIndexSet *sectionRemove = [self sectionIndexesFromHeaderArray:removeSectionList];
    NSArray<NSIndexPath *> *updateIndexes = [self indexesFromIdArray:updateContacts.copy exceptInSecion:@[]];
    
    //compile the latest data
//    NSLog(@" old%d new%d tableview old%d new%d", _accountDictionary.count, accountDict.count);
    NSUInteger total1 = 0;
    for (NSString* key in oldctd) {
      total1 += [[oldctd objectForKey:key] count];
    }
    NSUInteger total2 = 0;
    for (NSString* key in contactDict) {
      total2 += [[contactDict objectForKey:key] count];
    }
//    NSLog(@" tableview old%d new%d",total1, total2);
    self.accountDictionary = accountDict;
    [self setContactGroups:[ContactGroupEntity groupFromContacts:contactDict]];
    oldctd = contactDict;
    //update view model data
    if (_updateBlock) _updateBlock();
    NSArray<NSIndexPath *> *addIndexes = [self indexesFromIdArray:addContacts.copy exceptInSecion:addSectionList];
//    NSLog(@"add index %lu contacts %lu", addIndexes.count, addContacts.count);
    NSIndexSet *sectionInsert = [self sectionIndexesFromHeaderArray:addSectionList];

    //tableview - copy data -> tableview
    [diffDelegate onDiffWithSectionInsert:sectionInsert sectionRemove:sectionRemove addCell:addIndexes removeCell:removeIndexes andUpdateCell:updateIndexes];
    
    NSLog(@"==============================");
    NSLog(@"======New update circle=======");
    NSLog(@"==============================");
    
}

- (NSArray<NSIndexPath*>*)getIndexesInTableViewFromOnlineContactArray:(OnlineContactEntityArray*)array {
    NSMutableArray<NSIndexPath *> *indexes = [NSMutableArray new];
    for (OnlineContactEntity *contact in array) {
        NSIndexPath *indexPath = [self.tableViewDataSource indexPathForOnlineContactEntity:contact];
        if (indexPath && ![indexes containsObject:indexPath]) {
            [indexes addObject:indexPath];
        }
    }
    return indexes.copy;
}

- (void)onServerChangeOnlineFriendsWithAddContact:(OnlineContactEntityArray*)addContacts
                                    removeContact:(OnlineContactEntityArray*)removeContacts
                                    updateContact:(OnlineContactEntityArray*)updateContacts {
    
    [_updateUILock lock];
    NSArray<NSIndexPath *> *removeIndexes = [self getIndexesInTableViewFromOnlineContactArray:removeContacts];
    [self setOnlineContact:ZaloContactService.sharedInstance.getOnlineContactList];
    
    //update view model data
    if (_updateBlock) _updateBlock();
    NSArray<NSIndexPath *> *addIndexes = [self getIndexesInTableViewFromOnlineContactArray:addContacts];
    
    [diffDelegate onDiffWithSectionInsert:[NSIndexSet new] sectionRemove:[NSIndexSet new] addCell:addIndexes removeCell:removeIndexes andUpdateCell:@[]];
}

- (void)setup {
    [self setContactGroups:[ContactGroupEntity groupFromContacts:ZaloContactService.sharedInstance.getFullContactDict]];
    if (_dataBlock) _dataBlock();
}

- (void)setOnlineContact:(OnlineContactEntityArray*)contacts {
    onlineContacts = contacts;
    _data = [self compileGroupToTableData:contactGroups onlineContacts:onlineContacts];
}

- (void)setContactGroups:(NSArray<ContactGroupEntity *>*)groups {
    contactGroups = [NSMutableArray.alloc initWithArray: groups];
    _data = [self compileGroupToTableData:contactGroups onlineContacts:onlineContacts];

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
            IGListIndexPathResult * res = IGListDiffPaths(oldIndex + [UIConstants getContactIndex], foundIndex + [UIConstants getContactIndex], oldGroup.contacts, newGroups[foundIndex].contacts, IGListDiffEquality).resultForBatchUpdates;
            if (res.inserts.count >0 || res.deletes.count > 0 || res.updates.count > 0)
                [contactsDiff addObject:res];
        }
    }
    
    return contactsDiff;
}

// MARK: - make it dynamic please
- (NSArray<NSIndexPath *> *)getReloadIndexes:(NSArray<ContactGroupEntity *>*)newGroups {
    NSIndexPath *totalContactsIdp0;
    totalContactsIdp0 = [NSIndexPath indexPathForRow:0 inSection:[UIConstants getContactIndex] + newGroups.count];
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

- (void)deleteContactWithId:(NSString *)accountId {
    [ZaloContactService.sharedInstance deleteContactWithId:accountId];
}

- (void)performAction:(SwipeActionType)type forObject:(CellObject *)object {
    ContactObject *contactObject = (ContactObject*)object;
    if (contactObject) {
        [self performSelectorInBackground:@selector(deleteContactWithId:) withObject:contactObject.contact.accountId];
    }
}

- (NSArray<SwipeActionObject *>*)getActionListForContact{
    NSMutableArray *arr = NSMutableArray.new;
    [arr addObject:[SwipeActionObject.alloc initWithTile:@"Xoá" color:UIColor.zaloRedColor actionType:(deleteAction)]];
    [arr addObject:[SwipeActionObject.alloc initWithTile:@"Bạn thân" color:UIColor.zaloPrimaryColor actionType:(markAsFavoriteAction)]];
    [arr addObject:[SwipeActionObject.alloc initWithTile:@"Thêm" color:UIColor.lightGrayColor actionType:(moreAction)]];
    return arr.copy;
}

- (NSMutableArray *)compileGroupToTableData:(NSMutableArray<ContactGroupEntity *>*)groups onlineContacts:(OnlineContactEntityArray*)onlineContacts{
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
        
    }]];
    
    [data addObject:BlankFooterObject.new];
    
    //MARK:  - bạn thân
    [data addObject:[ShortHeaderObject.alloc initWithTitle:@"Bạn thân"]];
    
    [data addObject:[actionDelegate attachToObject:[[CommonCellObject alloc] initWithTitle:@"Chọn bạn thường liên lạc" image:[UIImage imageNamed:@"ct_plus"] tintColor:UIColor.zaloPrimaryColor] action:^{
        NSLog(@"Tapped");
    }]];
    
    [data addObject:BlankFooterObject.new];
    
    //MARK:  - bạn mới online
    [data addObject:[ShortHeaderObject.alloc initWithTitle:@"Bạn bè mới truy cập"]];
    if (!onlineContacts || ![onlineContacts count]) {
        
    } else {
        for (OnlineContactEntity *entity in [onlineContacts reverseObjectEnumerator]) {
            [data addObject:[OnlineContactObject.alloc initWithContactEntity:entity]];
        }
        
    }
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
