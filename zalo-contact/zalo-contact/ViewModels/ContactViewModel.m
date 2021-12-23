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

@property AccountMutableDictionary *accountDictionary;
@property dispatch_queue_t datasourceQueue;
@property id<TableViewDiffDelegate> diffDelegate;
@property id<TableViewActionDelegate> actionDelegate;
@end

@implementation ContactViewModel {
    
    NSMutableArray<ContactGroupEntity *> *contactGroups;
    OnlineContactEntityMutableArray *onlineContacts;
    
}

- (instancetype)initWithActionDelegate:(id<TableViewActionDelegate>)action
                       andDiffDelegate:(id<TableViewDiffDelegate>)diff{
    self = super.init;
    self.actionDelegate = action;
    self.diffDelegate = diff;
    dispatch_queue_attr_t qos = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_USER_INITIATED, -1);
    _datasourceQueue = dispatch_queue_create("_datasourceQueue", qos);
    [self setContactGroups:@[]];
    
    
    return self;
}

- (void)setup {
    dispatch_async(_datasourceQueue, ^{
        if (self.dataBlock) self.dataBlock();
    });
    [ZaloContactService.sharedInstance subcribe:self];
}

- (void)onChangeWithFullNewList:(ContactMutableDictionary *)loadContact andAccount:(AccountMutableDictionary *)loadAccount {
    dispatch_async(_datasourceQueue, ^{
//        long count = [self.accountDictionary count];
        self.accountDictionary = loadAccount;
        [self setContactGroups:[ContactGroupEntity groupFromContacts:loadContact]];
//        if (count) { if (self.dataWithAnimationBlock) self.dataWithAnimationBlock();}
//        else if (self.dataBlock) self.dataBlock();
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
            NSLog(@"Not found contact with -- %@", contact.fullName);
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
                              addContact:(NSOrderedSet<ChangeFootprint *> *)addContacts
                           removeContact:(NSOrderedSet<ChangeFootprint *> *)removeContacts
                           updateContact:(NSOrderedSet<ChangeFootprint *> *)updateContacts
                          newContactDict:(ContactMutableDictionary *)contactDict
                          newAccountDict:(AccountMutableDictionary *)accountDict {
    dispatch_async(_datasourceQueue, ^{
        NSArray<NSIndexPath *> *removeIndexes = [self indexesFromChangesArray:removeContacts.copy exceptInSecion:removeSectionList];
        NSIndexSet *sectionRemove = [self sectionIndexesFromHeaderArray:removeSectionList];
        
        self.accountDictionary = accountDict;
        [self setContactGroups:[ContactGroupEntity groupFromContacts:contactDict]];
        
        NSArray<NSIndexPath *> *updateIndexes = [self indexesFromChangesArray:updateContacts.copy exceptInSecion:@[]];
        //update view model data
        if (self.updateBlock) self.updateBlock();
        NSArray<NSIndexPath *> *addIndexes = [self indexesFromChangesArray:addContacts.copy exceptInSecion:addSectionList];
        
        NSIndexSet *sectionInsert = [self sectionIndexesFromHeaderArray:addSectionList];
        
        [self.diffDelegate onDiffWithSectionInsert:sectionInsert sectionRemove:sectionRemove addCell:addIndexes removeCell:removeIndexes andUpdateCell:updateIndexes];
        
        NSLog(@"======New update circle=======");
    });
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
    
    [_updateUILock lock];
    NSArray<NSIndexPath *> *removeIndexes = [self getIndexesInTableViewFromOnlineContactArray:removeContacts];
    [self setOnlineContact:ZaloContactService.sharedInstance.getOnlineContactList];
    
    //update view model data
    if (_updateBlock) _updateBlock();
    NSArray<NSIndexPath *> *addIndexes = [self getIndexesInTableViewFromOnlineContactArray:addContacts];
    
    [self.diffDelegate onDiffWithSectionInsert:[NSIndexSet new] sectionRemove:[NSIndexSet new] addCell:addIndexes removeCell:removeIndexes andUpdateCell:@[]];
}



- (void)setOnlineContact:(OnlineContactEntityMutableArray*)contacts {
    onlineContacts = contacts;
    _data = [self compileGroupToTableData:contactGroups onlineContacts:onlineContacts];
}

- (void)setContactGroups:(NSArray<ContactGroupEntity *>*)groups {
    contactGroups = [NSMutableArray.alloc initWithArray: groups];
    _data = [self compileGroupToTableData:contactGroups onlineContacts:onlineContacts];
}

// MARK: - make it dynamic please
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

- (NSMutableArray *)compileGroupToTableData:(NSMutableArray<ContactGroupEntity *>*)groups onlineContacts:(OnlineContactEntityMutableArray*)onlineContacts{
    NSMutableArray *data = NSMutableArray.alloc.init;
    //MARK:  -
    [data addObject:[NullHeaderObject.alloc initWithLeter:UITableViewIndexSearch]];
    [data addObject:
         [self.actionDelegate attachToObject:[CommonCellObject.alloc initWithTitle:@"Clear saved data"
                                                                             image:[UIImage imageNamed:@"ct_people"] tintColor:UIColor.blackColor]
                                      action:^{
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"contactDict"];
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"accountDict"];
    }]
    ];
    
    [data addObject:
         [self.actionDelegate attachToObject:
          [CommonCellObject.alloc initWithTitle:@"Xoá bớt"
                                          image:[UIImage imageNamed:@"ct_people"] tintColor:UIColor.blackColor]
                                      action:^{} ]
    ];
    
    [data addObject:[self.actionDelegate attachToObject:[[CommonCellObject alloc] initWithTitle:@"Tìm kiếm (866) 420-3189" image:[UIImage imageNamed:@"ct_people"] tintColor:UIColor.blackColor] action:^{
        
    }]];
    
    [data addObject:BlankFooterObject.new];
    
    //MARK:  - bạn thân
    [data addObject:[ShortHeaderObject.alloc initWithTitle:@"Bạn thân"]];
    
    [data addObject:[self.actionDelegate attachToObject:[[CommonCellObject alloc] initWithTitle:@"Chọn bạn thường liên lạc" image:[UIImage imageNamed:@"ct_plus"] tintColor:UIColor.zaloPrimaryColor] action:^{
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
                 [self.actionDelegate attachToObject:[ContactObject.alloc initWithContactEntity:contact]
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
        
    }]];
    
    [data addObject:BlankFooterObject.new];
    
    
    return data;
}

@end
