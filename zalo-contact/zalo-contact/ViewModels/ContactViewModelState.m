//
//  ContactViewModelState.m
//  zalo-contact
//
//  Created by Thiện on 31/12/2021.
//

#import "ContactViewModelState.h"
#import "ContactViewModelState+Private.h"


@interface ContactViewModelState () <ZaloContactEventListener>

@end

@implementation ContactViewModelState

- (instancetype)initWithContext:(id<ContextProtocol>)context {
    self = [super init];
    contextDelegate = context;
    return self;
}

- (void)switchToContactTab {
    
}

- (void)switchToOnlineTab {
    
}

- (void)startUI {
    self.updateUI = YES;
}

- (void)stopUI {
    self.updateUI = NO;
}

- (instancetype)initWithContext:(id<ContextProtocol>)context
                 actionDelegate:(id<TableViewActionDelegate>)action
                andDiffDelegate:(id<TableViewDiffDelegate>)diff {
    self = super.init;
    contextDelegate = context;
    self.actionDelegate = action;
    self.diffDelegate = diff;
    dispatch_queue_attr_t qos = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_USER_INITIATED, -1);
    self.datasourceQueue = dispatch_queue_create("datasourceQueue", qos);
    SET_SPECIFIC_FOR_QUEUE(self.datasourceQueue);
    self.tabItems = [self getTabItems];
    self.selectedTabIndex = 0;
    self.updateUI = NO;
    return self;
}

- (NSMutableOrderedSet<TabItem*>*)getTabItems {
    NSMutableOrderedSet<TabItem*> *array = [NSMutableOrderedSet new];
    [array addObject:[[TabItem alloc] initWithName:@"Tất cả" andNumber:0]];
    [array addObject:[[TabItem alloc] initWithName:@"Mới truy cập" andNumber:0]];
    return array;
}

- (void)setup {
    [self onChangeWithFullNewList:[[ZaloContactService sharedInstance] getContactDictCopy]
                       andAccount:[[ZaloContactService sharedInstance] getAccountDictCopy]];
    [ZaloContactService.sharedInstance subcribe:self];
}

- (void)reload {
    DISPATCH_ASYNC_IF_NOT_IN_QUEUE(self.datasourceQueue, ^{
        self.data = [self compileData];
        if (self.dataWithAnimationBlock) self.dataWithAnimationBlock();
    });
}

- (void)onChangeWithFullNewList:(ContactMutableDictionary *)loadContact andAccount:(AccountMutableDictionary *)loadAccount {
    DISPATCH_ASYNC_IF_NOT_IN_QUEUE(self.datasourceQueue, ^{
        self.accountDictionary = loadAccount;
        if (!self.updateUI) return;
        [self compileDataFromContactGroup:[ContactGroupEntity groupFromContacts:loadContact]];
        if (self.dataWithAnimationBlock) self.dataWithAnimationBlock();
    });
}

- (void)compileDataFromContactGroup:(NSArray<ContactGroupEntity *>*)groups {
    self.contactGroups = [NSMutableArray.alloc initWithArray: groups];
    self.data = [self compileData];
}

- (NSArray<NSIndexPath *> *)getReloadIndexes:(NSArray<ContactGroupEntity *>*)newGroups {
    NSIndexPath *totalContactsIdp0;
    totalContactsIdp0 = [NSIndexPath indexPathForRow:0 inSection:[UIConstants getContactIndex] + newGroups.count];
    return @[totalContactsIdp0];
}

- (NSIndexSet*)getSectionUpdate:(int)selectedIndex {
    NSMutableIndexSet *updateSet = [NSMutableIndexSet new];
    [updateSet addIndex:2];
    return updateSet;
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

- (void)changeToTab:(int)index {
    DISPATCH_ASYNC_IF_NOT_IN_QUEUE(self.datasourceQueue, ^{
        if (self.selectedTabIndex == index) return;;
        
        NSMutableIndexSet *insertSet = [NSMutableIndexSet new];
        NSMutableIndexSet *removeSet = [NSMutableIndexSet new];
        
        if ([self.tabItems[index].name isEqual:@"Tất cả"]) {
            [removeSet addIndexesInRange:NSMakeRange(UIConstants.getContactIndex - 1, 1)];
            [insertSet addIndexesInRange:NSMakeRange(UIConstants.getContactIndex - 1, self.contactGroups.count + 1)];
        } else {
            [removeSet addIndexesInRange:NSMakeRange(UIConstants.getContactIndex - 1, self.contactGroups.count + 1)];
            [insertSet addIndexesInRange:NSMakeRange(UIConstants.getContactIndex - 1, 1)];
        }
        
        self.data = [self compileData];
        if (self.updateBlock) self.updateBlock();
        [self.diffDelegate onDiffWithSectionInsert:insertSet.copy sectionRemove:removeSet.copy sectionUpdate:[self getSectionUpdate:index]];
        self.selectedTabIndex = index;
    });
}

- (NSArray *)compileTabSection {
    NSMutableArray *data = [NSMutableArray new];
    [data addObject:[[NullHeaderObject alloc] init]];
    
    self.tabItems[0].number = (int)self.accountDictionary.count;
    self.tabItems[1].number = (int)self.onlineContacts.count;
    
    NSMutableArray *tabArray = [NSMutableArray arrayWithArray:[self.tabItems array]];
    //    if (self.tabItems[1].number == 0) {
    //        [tabArray removeObjectAtIndex:1];
    //    }
    
    [data addObject:[[TabCellObject alloc] initWithTabItem:tabArray.copy selectedIndex:self.selectedTabIndex withDidClickBlock:^(int selectedIndex) {
        if (selectedIndex == 0) [self switchToContactTab];
        if (selectedIndex == 1) [self switchToOnlineTab];
    }]];
    
    [data addObject:ContactFooterObject.new];
    return [data copy];
}

- (nullable NSArray *)compileCustomSection {
    return nil;
}

- (NSMutableArray *)compileData {
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
        
    }]];
    
    [data addObject:BlankFooterObject.new];
    
    //MARK:  - tab section
    [data addObjectsFromArray:[self compileTabSection]];
    
    //MARK:  - switching section base on selected item
    NSArray *customSection = [self compileCustomSection];
    if (customSection)  [data addObjectsFromArray:customSection];
    
    //MARK: - Footer section
    [data addObject:[[NullHeaderObject alloc] initWithLeter:@"#"]];
    
    [data addObject:[LabelCellObject.alloc initWithTitle:[NSString stringWithFormat:@"%lu bạn", self.accountDictionary.count] andTextAlignment:NSTextAlignmentCenter color:UIColor.zaloBackgroundColor cellType:shortCell]];
    
    [data addObject:[LabelCellObject.alloc initWithTitle:@"Nhanh chóng thêm bạn vào Zalo từ danh \nbạ điện thoại" andTextAlignment:NSTextAlignmentCenter color:UIColor.zaloLightGrayColor cellType:tallCell]];
    
    [data addObject:[UpdateContactObject.alloc initWithTitle:@"Cập nhập danh bạ" andAction:^{
        
    }]];
    
    [data addObject:BlankFooterObject.new];
    
    
    return data;
}

@end
