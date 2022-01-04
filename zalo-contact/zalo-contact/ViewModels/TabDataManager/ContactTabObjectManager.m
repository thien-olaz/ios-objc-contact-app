//
//  ContactTabObjectManager.m
//  zalo-contact
//
//  Created by Thiện on 03/01/2022.
//

#import "ContactTabObjectManager.h"
#import "CommonHeaderAndFooterViews.h"
#import "ContactGroupEntity.h"
#import "OnlineTabObjectManager.h"

@interface ContactTabObjectManager ()

@property NSMutableArray<ContactGroupEntity *> *contactGroups;
@property AccountMutableDictionary *accountDictionary;

@end

@implementation ContactTabObjectManager

- (instancetype)initWithContext:(ContactViewModel *)context {
    self = [super initWithContext:context];
    self.accountDictionary = @{}.mutableCopy;
    self.contactGroups = @[].mutableCopy;
    return self;
}

- (int)getTabCount {
    return (int)self.accountDictionary.count;
}

- (NSString*)getTabTitle {
    return @"Danh bạ";
}

- (void)reloadUI {
    dispatch_async(self.managerQueue, ^{
        [self.context bindNewData];
        if (self.context.dataWithAnimationBlock) self.context.dataWithAnimationBlock();
    });
}

- (void)switchToOnlineTab {
    [self.context changeToObjectManagerState:OnlineTabObjectManager.self];
}

- (void)switchToTabClass:(Class)tabClass {
    if (tabClass == OnlineTabObjectManager.class) [self switchToOnlineTab];
}

- (void)onChangeWithFullNewList:(ContactMutableDictionary *)loadContact andAccount:(AccountMutableDictionary *)loadAccount {
    DISPATCH_ASYNC_IF_NOT_IN_QUEUE(self.managerQueue, ^{
        self.accountDictionary = loadAccount;
        [self setContactGroup:[ContactGroupEntity groupFromContacts:loadContact]];
        if (self.context.dataWithTransitionBlock) self.context.dataWithTransitionBlock();
    });
}

- (NSArray<NSIndexPath*>*)indexesFromChangesArray:(NSArray<ChangeFootprint *>*)array exceptInSecion:(NSArray<NSString *>*)exception {
    NSMutableArray<NSIndexPath *> *indexes = [NSMutableArray new];
    for (ChangeFootprint *changeFootprint in array) {
        ContactEntity *contact = [self.accountDictionary objectForKey:changeFootprint.accountId];
        if (!contact) {
            continue;
        }
        if ([exception containsObject:contact.header]) continue;
        NSIndexPath *indexPath = [self.context.tableViewDataSource indexPathForContactEntity:contact];
        if (indexPath && ![indexes containsObject:indexPath]) {
            [indexes addObject:indexPath];
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
    dispatch_async(self.managerQueue, ^{
        if (self.updateUI) {
            BOOL isLargeCellChange = (addContacts.count + removeContacts.count + updateContacts.count) > 3;
            BOOL isLargeSectionChange = (addSectionList.count + removeSectionList.count) > 3;
            if (isLargeCellChange || isLargeSectionChange) {
                [self reloadDataWithNewContactDict:contactDict newAccountDict:accountDict];
            } else {
                AccountMutableDictionary *oldAccountDict = self.accountDictionary.copy;
                NSArray<NSIndexPath *> *removeIndexes = [self indexesFromChangesArray:removeContacts.copy exceptInSecion:removeSectionList];
                NSIndexSet *sectionRemove = [self sectionIndexesFromHeaderArray:removeSectionList];
                
                self.accountDictionary = accountDict;
                [self setContactGroup:[ContactGroupEntity groupFromContacts:contactDict]];
                
                NSArray<NSIndexPath *> *updateIndexes = [self indexesFromChangesArray:updateContacts.copy exceptInSecion:@[]];
                
                if (self.context.updateBlock) self.context.updateBlock();
                
                NSArray<NSIndexPath *> *addIndexes = [self indexesFromChangesArray:addContacts.copy exceptInSecion:addSectionList];
                NSIndexSet *sectionInsert = [self sectionIndexesFromHeaderArray:addSectionList];
                
                if (sectionInsert.count > 0 || sectionRemove > 0 || [self verifyCalculatedIndexesWithOldDict:oldAccountDict newDict:accountDict addCount:addIndexes.count deleteCount:removeIndexes.count]) {
                    [self.context.diffDelegate onDiffWithSectionInsert:sectionInsert
                                                         sectionRemove:sectionRemove
                                                         sectionUpdate:[self getSectionUpdate:0]
                                                               addCell:addIndexes
                                                            removeCell:removeIndexes
                                                         andUpdateCell:updateIndexes];
                } else {
                    [self reloadDataWithNewContactDict:contactDict newAccountDict:accountDict];
                }
            }
        } else {
            self.accountDictionary = accountDict;
            self.contactGroups = [NSMutableArray.alloc initWithArray:[ContactGroupEntity groupFromContacts:contactDict]];
        }
    });
}

- (BOOL)verifyCalculatedIndexesWithOldDict:(AccountMutableDictionary *)oldAccountDict newDict:(AccountMutableDictionary *)newAccountDict addCount:(long)addCount deleteCount:(long)deleteCount{
    NSMutableSet *oldKeySet = [NSMutableSet setWithArray: oldAccountDict.allKeys.copy];
    NSMutableSet *newKeySet = [NSMutableSet setWithArray: newAccountDict.allKeys.copy];
    
    NSMutableSet *deleteSet = oldKeySet.mutableCopy;
    [deleteSet.mutableCopy minusSet:newKeySet];
    NSMutableSet *addSet = newKeySet.mutableCopy;
    [addSet.mutableCopy minusSet:oldKeySet];
    
    if ([deleteSet count] != deleteCount) return NO;
    if ([addSet count] != addCount) return NO;
    return YES;
}

- (void)reloadDataWithNewContactDict:(ContactMutableDictionary *)contactDict
                      newAccountDict:(AccountMutableDictionary *)accountDict {
    self.accountDictionary = accountDict;
    [self setContactGroup:[ContactGroupEntity groupFromContacts:contactDict]];
    if (self.context.dataWithTransitionBlock) self.context.dataWithTransitionBlock();
}

- (NSArray<SwipeActionObject *>*)getActionListForContact{
    NSMutableArray *arr = NSMutableArray.new;
    [arr addObject:[SwipeActionObject.alloc initWithTile:@"Xoá" color:UIColor.zaloRedColor actionType:(deleteAction)]];
    [arr addObject:[SwipeActionObject.alloc initWithTile:@"Bạn thân" color:UIColor.zaloPrimaryColor actionType:(markAsFavoriteAction)]];
    [arr addObject:[SwipeActionObject.alloc initWithTile:@"Thêm" color:UIColor.lightGrayColor actionType:(moreAction)]];
    return arr.copy;
}

- (void)setContactGroup:(NSArray<ContactGroupEntity *>*)groups {
    self.contactGroups = groups.mutableCopy;
    [self.context bindNewData];
}

- (NSArray*)compileSection {
    return  [self compileContactSection:self.contactGroups];
}

- (NSArray *)compileContactSection:(NSMutableArray<ContactGroupEntity *>*)contactGroups {
    NSMutableArray *data = [NSMutableArray new];
    ActionHeaderObject *contactHeaderObject = [[ActionHeaderObject alloc] initWithTitle:@"Danh bạ" andButtonTitle:@"CẬP NHẬP"];
    
    [contactHeaderObject setBlock:^{}];
    [data addObject:contactHeaderObject];
    for (ContactGroupEntity *group in contactGroups) {
        // Header
        [data addObject:[ShortHeaderObject.alloc initWithTitle:group.header andTitleLetter:group.header]];
        // Contact
        for (ContactEntity *contact in group.contacts) {
            [data addObject:
                 [self.context.actionDelegate attachToObject:[ContactObject.alloc initWithContactEntity:contact]
                                                 swipeAction:[self getActionListForContact]]
            ];
        }
        // Footer
        [data addObject:ContactFooterObject.new];
    }
    return [data copy];
}
@end

