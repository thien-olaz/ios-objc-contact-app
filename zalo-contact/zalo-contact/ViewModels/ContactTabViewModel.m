//
//  ContactTabViewModel.m
//  zalo-contact
//
//  Created by Thiện on 31/12/2021.
//

#import "ContactTabViewModel.h"
#import "OnlineTabViewModel.h"
#import "ContactViewModelState+Private.h"

@implementation ContactTabViewModel

- (void)switchToOnlineTab {
    [contextDelegate changeToState:OnlineTabViewModel.class];
}

- (NSArray<NSIndexPath*>*)indexesFromChangesArray:(NSArray<ChangeFootprint *>*)array exceptInSecion:(NSArray<NSString *>*)exception {
    NSMutableArray<NSIndexPath *> *indexes = [NSMutableArray new];
    for (ChangeFootprint *changeFootprint in array) {
        ContactEntity *contact = [self.accountDictionary objectForKey:changeFootprint.accountId];
        if (!contact) {
            continue;
        }
        if ([exception containsObject:contact.header]) continue;
        NSIndexPath *indexPath = [self.tableViewDataSource indexPathForContactEntity:contact];
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
    DISPATCH_ASYNC_IF_NOT_IN_QUEUE(self.datasourceQueue, ^{
        if (self.updateUI) {
            NSArray<NSIndexPath *> *removeIndexes = [self indexesFromChangesArray:removeContacts.copy exceptInSecion:removeSectionList];
            NSIndexSet *sectionRemove = [self sectionIndexesFromHeaderArray:removeSectionList];
            
            self.accountDictionary = accountDict;
            [self compileDataFromContactGroup:[ContactGroupEntity groupFromContacts:contactDict]];
            
            NSArray<NSIndexPath *> *updateIndexes = [self indexesFromChangesArray:updateContacts.copy exceptInSecion:@[]];
            if (self.updateBlock) self.updateBlock();
            NSArray<NSIndexPath *> *addIndexes = [self indexesFromChangesArray:addContacts.copy exceptInSecion:addSectionList];
            
            NSIndexSet *sectionInsert = [self sectionIndexesFromHeaderArray:addSectionList];
            
            [self.diffDelegate onDiffWithSectionInsert:sectionInsert
                                         sectionRemove:sectionRemove
                                         sectionUpdate:[self getSectionUpdate:0]
                                               addCell:addIndexes
                                            removeCell:removeIndexes
                                         andUpdateCell:updateIndexes];
        } else {
            NSLog(@"Cache contact");
            self.accountDictionary = accountDict;
            self.contactGroups = [NSMutableArray.alloc initWithArray:[ContactGroupEntity groupFromContacts:contactDict]];
        }
    });
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
                 [self.actionDelegate attachToObject:[ContactObject.alloc initWithContactEntity:contact]
                                         swipeAction:[self getActionListForContact]]
            ];
        }
        // Footer
        [data addObject:ContactFooterObject.new];
    }
    return [data copy];
}

- (NSArray *)compileCustomSection {
    return  [self compileContactSection:self.contactGroups];
}

@end
