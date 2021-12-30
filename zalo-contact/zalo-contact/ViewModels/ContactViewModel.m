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
#import "Contact+CoreDataClass.h"
#import "ContactDataManager.h"
#import "TabCellObject.h"

@interface ContactViewModel () <ZaloContactEventListener>

@property int selectedTabIndex;
//@property NSMutableDictionary<NSString *, NSMutableArray<>> *selectedTabItem;
@property NSMutableOrderedSet<TabItem * > *tabItems;
@property AccountMutableDictionary *accountDictionary;
@property dispatch_queue_t datasourceQueue;
@property id<TableViewDiffDelegate> diffDelegate;
@property id<TableViewActionDelegate> actionDelegate;
@property NSMutableArray<ContactGroupEntity *> *contactGroups;
@property OnlineContactEntityMutableArray *onlineContacts;
@end

@implementation ContactViewModel

- (instancetype)initWithActionDelegate:(id<TableViewActionDelegate>)action
                       andDiffDelegate:(id<TableViewDiffDelegate>)diff{
    self = super.init;
    self.actionDelegate = action;
    self.diffDelegate = diff;
    dispatch_queue_attr_t qos = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_USER_INITIATED, -1);
    _datasourceQueue = dispatch_queue_create("_datasourceQueue", qos);
    SET_SPECIFIC_FOR_QUEUE(_datasourceQueue);
    self.tabItems = [self getTabItems];
    self.selectedTabIndex = 0;
    return self;
}

- (NSMutableOrderedSet<TabItem*>*)getTabItems {
    NSMutableOrderedSet<TabItem*> *array = [NSMutableOrderedSet new];
    [array addObject:[[TabItem alloc] initWithName:@"Tất cả" andNumber:0]];
    [array addObject:[[TabItem alloc] initWithName:@"Mới truy cập" andNumber:0]];
    return array;
}

- (void)setup {
    [self onChangeWithFullNewList:[[ZaloContactService sharedInstance] getContactDictCopy] andAccount:[[ZaloContactService sharedInstance] getAccountDictCopy]];
    [ZaloContactService.sharedInstance subcribe:self];
}

- (void)onChangeWithFullNewList:(ContactMutableDictionary *)loadContact andAccount:(AccountMutableDictionary *)loadAccount {
    DISPATCH_ASYNC_IF_NOT_IN_QUEUE(_datasourceQueue, ^{
        self.accountDictionary = loadAccount;
        [self compileDataFromContactGroup:[ContactGroupEntity groupFromContacts:loadContact]];
        if (self.dataWithAnimationBlock) self.dataWithAnimationBlock();
    });
}

// find indexpath with contact entity
- (NSArray<NSIndexPath*>*)indexesFromChangesArray:(NSArray<ChangeFootprint *>*)array exceptInSecion:(NSArray<NSString *>*)exception {
    NSMutableArray<NSIndexPath *> *indexes = [NSMutableArray new];
    for (ChangeFootprint *changeFootprint in array) {
        ContactEntity *contact = [self.accountDictionary objectForKey:changeFootprint.accountId];
        if (!contact) {
            NSLog(@"Not found contact with account id %@", changeFootprint.accountId);
            continue;
        }
        if ([exception containsObject:contact.header]) continue;
        NSIndexPath *indexPath = [self.tableViewDataSource indexPathForContactEntity:contact];
        if (indexPath && ![indexes containsObject:indexPath]) {
            [indexes addObject:indexPath];
        } else {
            NSLog(@"Not found contact name %@", contact.fullName);
        }
    }
    return indexes.copy;
}

- (NSIndexSet*)sectionIndexesFromHeaderArray:(NSArray<NSString*>*)array {
    NSArray *headerList = [self.contactGroups valueForKey:@"header"];
    NSMutableIndexSet *indexes = [NSMutableIndexSet new];
    for (NSString *header in array) {
        NSUInteger foundIndex = [headerList indexOfObject:header];
        if (foundIndex != NSNotFound) [indexes addIndex:foundIndex + [UIConstants getContactIndex]];
    }
    return indexes.copy;
}

- (void)onServerChangeWithAddSectionList:(NSMutableArray<NSString *> *)addSectionList
                       removeSectionList:(NSMutableArray<NSString *> *)removeSectionList
                              addContact:(NSOrderedSet<ChangeFootprint *> *)addContacts
                           removeContact:(NSOrderedSet<ChangeFootprint *> *)removeContacts
                           updateContact:(NSOrderedSet<ChangeFootprint *> *)updateContacts
                          newContactDict:(ContactMutableDictionary *)contactDict
                          newAccountDict:(AccountMutableDictionary *)accountDict {
    if (self.selectedTabIndex == 0) {
        DISPATCH_ASYNC_IF_NOT_IN_QUEUE(_datasourceQueue, ^{
            NSArray<NSIndexPath *> *removeIndexes = [self indexesFromChangesArray:removeContacts.copy exceptInSecion:removeSectionList];
            NSIndexSet *sectionRemove = [self sectionIndexesFromHeaderArray:removeSectionList];
            
            self.accountDictionary = accountDict;
            [self compileDataFromContactGroup:[ContactGroupEntity groupFromContacts:contactDict]];
            
            NSArray<NSIndexPath *> *updateIndexes = [self indexesFromChangesArray:updateContacts.copy exceptInSecion:@[]];
            if (self.updateBlock) self.updateBlock();
            NSArray<NSIndexPath *> *addIndexes = [self indexesFromChangesArray:addContacts.copy exceptInSecion:addSectionList];
            
            NSIndexSet *sectionInsert = [self sectionIndexesFromHeaderArray:addSectionList];

            [self.diffDelegate onDiffWithSectionInsert:sectionInsert sectionRemove:sectionRemove sectionUpdate:[[NSIndexSet alloc] initWithIndex:2] addCell:addIndexes removeCell:removeIndexes andUpdateCell:updateIndexes];
        });
    } else {
        DISPATCH_ASYNC_IF_NOT_IN_QUEUE(_datasourceQueue, ^{
            self.accountDictionary = accountDict;
            self.contactGroups = [NSMutableArray.alloc initWithArray:[ContactGroupEntity groupFromContacts:contactDict]];
        });
    }
}

- (NSArray<NSIndexPath*>*)getIndexesInTableViewFromOnlineContactArray:(OnlineContactEntityMutableArray*)array {
    NSMutableArray<NSIndexPath *> *indexes = [NSMutableArray new];
    for (OnlineContactEntity *contact in array) {
        NSIndexPath *indexPath = [self.tableViewDataSource indexPathForOnlineContactEntity:contact];
        if (indexPath && ![indexes containsObject:indexPath]) {
            [indexes addObject:indexPath];
        }
    }
    return indexes.copy;
}

- (void)onServerChangeOnlineFriendsWithAddContact:(OnlineContactEntityMutableArray*)addContacts
                                    removeContact:(OnlineContactEntityMutableArray*)removeContacts
                                    updateContact:(OnlineContactEntityMutableArray*)updateContacts {
    if (self.selectedTabIndex == 1) {
        DISPATCH_ASYNC_IF_NOT_IN_QUEUE(_datasourceQueue, ^{
            NSArray<NSIndexPath *> *removeIndexes = [self getIndexesInTableViewFromOnlineContactArray:removeContacts];
            [self setOnlineContact:ZaloContactService.sharedInstance.getOnlineContactList];
            if (self.updateBlock) self.updateBlock();
            NSArray<NSIndexPath *> *addIndexes = [self getIndexesInTableViewFromOnlineContactArray:addContacts];
            [self.diffDelegate onDiffWithSectionInsert:[NSIndexSet new] sectionRemove:[NSIndexSet new] sectionUpdate:[[NSIndexSet alloc] initWithIndex:2] addCell:addIndexes removeCell:removeIndexes andUpdateCell:@[]];
        })
    } else {
        DISPATCH_ASYNC_IF_NOT_IN_QUEUE(_datasourceQueue, ^{
            self.onlineContacts = ZaloContactService.sharedInstance.getOnlineContactList;
        });
    }
    
}

- (void)setOnlineContact:(OnlineContactEntityMutableArray*)contacts {
    self.onlineContacts = contacts;
    _data = [self compileGroupToTableData:self.contactGroups onlineContacts:self.onlineContacts];
}

- (void)compileDataFromContactGroup:(NSArray<ContactGroupEntity *>*)groups {
    self.contactGroups = [NSMutableArray.alloc initWithArray: groups];
    _data = [self compileGroupToTableData:self.contactGroups onlineContacts:self.onlineContacts];
}

- (NSArray<NSIndexPath *> *)getReloadIndexes:(NSArray<ContactGroupEntity *>*)newGroups {
    NSIndexPath *totalContactsIdp0;
    totalContactsIdp0 = [NSIndexPath indexPathForRow:0 inSection:[UIConstants getContactIndex] + newGroups.count];
    return @[totalContactsIdp0];
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

- (NSArray *)compileContactSection:(NSMutableArray<ContactGroupEntity *>*)contactGroups {
    NSMutableArray *data = [NSMutableArray new];
    ActionHeaderObject *contactHeaderObject = [[ActionHeaderObject alloc] initWithTitle:@"Danh bạ" andButtonTitle:@"CẬP NHẬP"];
    
    [contactHeaderObject setBlock:^{
        
    }];
    
    [data addObject:contactHeaderObject];
    
    for (ContactGroupEntity *group in contactGroups) {
        
        // Header
        [data addObject:[ShortHeaderObject.alloc initWithTitle:group.header andTitleLetter:group.header]];
        
        // Contact
        for (ContactEntity *contact in group.contacts) {
            [data addObject:
                 [self.actionDelegate attachToObject:[ContactObject.alloc initWithContactEntity:contact]
                                         swipeAction:[self getActionListForContact]]
            ];
        }
        // Footer
        [data addObject:ContactFooterObject.new];
    }
    
    return [data copy];
    
}

- (NSArray *)compileOnlineSection:(OnlineContactEntityMutableArray*)onlineContacts {
    NSMutableArray *data = [NSMutableArray new];
    [data addObject:[ShortHeaderObject.alloc initWithTitle:@"Bạn bè mới truy cập"]];
    if (!onlineContacts || ![onlineContacts count]) {
        
    } else {
        for (OnlineContactEntity *entity in [onlineContacts reverseObjectEnumerator]) {
            [data addObject:[OnlineContactObject.alloc initWithContactEntity:entity]];
        }
    }
    return [data copy];
}

- (NSArray *)compileTabSection {
    NSMutableArray *data = [NSMutableArray new];
    [data addObject:[[NullHeaderObject alloc] init]];
    
    self.tabItems[0].number = (int)self.accountDictionary.count;
    self.tabItems[1].number = (int)self.onlineContacts.count;
    
    NSMutableArray *tabArray = [NSMutableArray arrayWithArray:[self.tabItems array]];
    if (self.tabItems[1].number == 0) {
        [tabArray removeObjectAtIndex:1];
    }
    
    [data addObject:[[TabCellObject alloc] initWithTabItem:tabArray.copy selectedIndex:self.selectedTabIndex withDidClickBlock:^(int selectedIndex) {
        [self changeToTab:selectedIndex];
    }]];
    
    [data addObject:ContactFooterObject.new];
    return [data copy];
}

- (void)changeToTab:(int)index {
    DISPATCH_ASYNC_IF_NOT_IN_QUEUE(_datasourceQueue, ^{
        if (self.selectedTabIndex == index) return;;
        self.selectedTabIndex = index;
        NSMutableIndexSet *insertSet = [NSMutableIndexSet new];
        NSMutableIndexSet *removeSet = [NSMutableIndexSet new];
        
        if ([self.tabItems[self.selectedTabIndex].name isEqual:@"Tất cả"]) {
            [removeSet addIndexesInRange:NSMakeRange(UIConstants.getContactIndex - 1, 1)];
            [insertSet addIndexesInRange:NSMakeRange(UIConstants.getContactIndex - 1, self.contactGroups.count + 1)];
        } else {
            [removeSet addIndexesInRange:NSMakeRange(UIConstants.getContactIndex - 1, self.contactGroups.count + 1)];
            [insertSet addIndexesInRange:NSMakeRange(UIConstants.getContactIndex - 1, 1)];
        }
        
        self.data = [self compileGroupToTableData:self.contactGroups onlineContacts:self.onlineContacts];
        if (self.updateBlock) self.updateBlock();
        
        [self.diffDelegate onDiffWithSectionInsert:insertSet.copy sectionRemove:removeSet.copy sectionUpdate:[NSIndexSet new]];
    });
}


- (NSMutableArray *)compileGroupToTableData:(NSMutableArray<ContactGroupEntity *>*)groups onlineContacts:(OnlineContactEntityMutableArray*)onlineContacts{
    NSMutableArray *data = NSMutableArray.alloc.init;
    //MARK:  -
    [data addObject:[NullHeaderObject.alloc initWithLeter:UITableViewIndexSearch]];
    [data addObject:
         [self.actionDelegate attachToObject:[CommonCellObject.alloc initWithTitle:@"Xoá dữ liệu"
                                                                             image:[UIImage imageNamed:@"ct_people"] tintColor:UIColor.blackColor]
                                      action:^{
      
        NSFetchRequest *request = [Contact fetchRequest];
        NSBatchDeleteRequest *delete = [[NSBatchDeleteRequest alloc] initWithFetchRequest:request];
        
        [ContactDataManager.sharedInstance.managedObjectContext executeRequest:delete error:NULL];
    }]
    ];
    
    [data addObject:
         [self.actionDelegate attachToObject:
          [CommonCellObject.alloc initWithTitle:@"Cell trống thứ nhất"
                                          image:[UIImage imageNamed:@"ct_people"] tintColor:UIColor.blackColor]
                                      action:^{} ]
    ];

    [data addObject:BlankFooterObject.new];
    
    //MARK:  - bạn thân
    [data addObject:[ShortHeaderObject.alloc initWithTitle:@"Bạn thân"]];
    
    [data addObject:[self.actionDelegate attachToObject:[[CommonCellObject alloc] initWithTitle:@"Chọn bạn thường liên lạc" image:[UIImage imageNamed:@"ct_plus"] tintColor:UIColor.zaloPrimaryColor] action:^{
        NSLog(@"Tapped");
    }]];
    
    [data addObject:BlankFooterObject.new];
    
    //MARK:  - tab section
    [data addObjectsFromArray:[self compileTabSection]];
    
    //MARK:  - switching section base on selected item
    if (self.selectedTabIndex == 0) {
        [data addObjectsFromArray:[self compileContactSection:groups]];
    } else if (self.selectedTabIndex == 1) {
        [data addObjectsFromArray:[self compileOnlineSection:onlineContacts]];
    } else {
        [data addObjectsFromArray:[self compileContactSection:groups]];
    }
        
    //MARK: - Footer section
    [data addObject:[NullHeaderObject.alloc init]];
    
    [data addObject:[LabelCellObject.alloc initWithTitle:[NSString stringWithFormat:@"%lu bạn", self.accountDictionary.count] andTextAlignment:NSTextAlignmentCenter color:UIColor.zaloBackgroundColor cellType:shortCell]];
    
    [data addObject:[LabelCellObject.alloc initWithTitle:@"Nhanh chóng thêm bạn vào Zalo từ danh \nbạ điện thoại" andTextAlignment:NSTextAlignmentCenter color:UIColor.zaloLightGrayColor cellType:tallCell]];
    
    [data addObject:[UpdateContactObject.alloc initWithTitle:@"Cập nhập danh bạ" andAction:^{
        
    }]];
    
    [data addObject:BlankFooterObject.new];
    
    
    return data;
}

@end
