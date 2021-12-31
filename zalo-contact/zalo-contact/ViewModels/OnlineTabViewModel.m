//
//  OnlineTabViewModel.m
//  zalo-contact
//
//  Created by Thiện on 31/12/2021.
//

#import "OnlineTabViewModel.h"
#import "ContactTabViewModel.h"
#import "ContactViewModelState+Private.h"

@implementation OnlineTabViewModel

- (instancetype)initWithContext:(id<ContextProtocol>)context
                  actionDelegate:(id<TableViewActionDelegate>)action
                andDiffDelegate:(id<TableViewDiffDelegate>)diff {
    self = [super initWithContext:context actionDelegate:action andDiffDelegate:diff];
    self.selectedTabIndex = 1;
    return self;
}

- (void)switchToContactTab {
    [contextDelegate changeToState:ContactTabViewModel.class];
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
                                    updateContact:(OnlineContactEntityMutableArray*)updateContacts
                                       onlineList:(OnlineContactEntityMutableArray *)onlineList{
    DISPATCH_ASYNC_IF_NOT_IN_QUEUE(self.datasourceQueue, ^{
        if (self.updateUI) {
            NSArray<NSIndexPath *> *removeIndexes = [self getIndexesInTableViewFromOnlineContactArray:removeContacts];
            [self setOnlineContact:onlineList];
            if (self.updateBlock) self.updateBlock();
            NSArray<NSIndexPath *> *addIndexes = [self getIndexesInTableViewFromOnlineContactArray:addContacts];
            [self.diffDelegate onDiffWithSectionInsert:[NSIndexSet new]
                                         sectionRemove:[NSIndexSet new]
                                         sectionUpdate:[self getSectionUpdate:1]
                                               addCell:addIndexes
                                            removeCell:removeIndexes
                                         andUpdateCell:@[]];
            
        } else {
            NSLog(@"Cache online");
            self.onlineContacts = onlineList;
        }
    });
}

- (void)setOnlineContact:(OnlineContactEntityMutableArray*)contacts {
    self.onlineContacts = contacts;
    self.data = [self compileData];
}

- (NSArray *)compileOnlineSection:(OnlineContactEntityMutableArray*)onlineContacts {
    NSMutableArray *data = [NSMutableArray new];
    [data addObject:[ShortHeaderObject.alloc initWithTitle:@"Bạn bè mới truy cập" andTitleLetter:@"@"]];
    if (!onlineContacts || ![onlineContacts count]) {
        
    } else {
        for (OnlineContactEntity *entity in [onlineContacts reverseObjectEnumerator]) {
            [data addObject:[OnlineContactObject.alloc initWithContactEntity:entity]];
        }
    }
    return [data copy];
}

- (NSArray *)compileCustomSection {
    return  [self compileOnlineSection:self.onlineContacts];
}

@end
