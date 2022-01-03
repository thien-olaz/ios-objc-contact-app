//
//  OnlineTabObjectManager.m
//  zalo-contact
//
//  Created by Thiện on 03/01/2022.
//

#import "OnlineTabObjectManager.h"
#import "CommonHeaderAndFooterViews.h"
#import "ContactTabObjectManager.h"

@interface OnlineTabObjectManager ()
@property OnlineContactEntityMutableArray *onlineContacts;
@property dispatch_queue_t onlineTabObjectManagerQueue;
@end

@implementation OnlineTabObjectManager

- (instancetype)initWithContext:(ContactViewModel *)context {
    self = [super initWithContext:context];
    dispatch_queue_attr_t qos = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_USER_INITIATED, -1);
    _onlineTabObjectManagerQueue = dispatch_queue_create("_onlineTabObjectManagerQueue", qos);
    SET_SPECIFIC_FOR_QUEUE(_onlineTabObjectManagerQueue);
    self.onlineContacts = @[].mutableCopy;
    return self;
}

- (int)getTabCount {
    return (int)self.onlineContacts.count;
}

- (NSString*)getTabTitle {
    return @"Bạn mới truy cập";
}

- (void)reloadUI {
    dispatch_async(self.onlineTabObjectManagerQueue, ^{
        [self.context bindNewData];
        if (self.context.dataWithAnimationBlock) self.context.dataWithAnimationBlock();
    });
}

- (void)switchToContactTab {
    [self.context changeToObjectManagerState:ContactTabObjectManager.class];
}

- (void)switchToTabClass:(Class)tabClass {
    if (tabClass == ContactTabObjectManager.class) [self switchToContactTab];
}

- (NSArray<NSIndexPath*>*)getIndexesInTableViewFromOnlineContactArray:(OnlineContactEntityMutableArray*)array {
    NSMutableArray<NSIndexPath *> *indexes = [NSMutableArray new];
    for (OnlineContactEntity *contact in array) {
        NSIndexPath *indexPath = [self.context.tableViewDataSource indexPathForOnlineContactEntity:contact];
        if (indexPath && ![indexes containsObject:indexPath]) {
            [indexes addObject:indexPath];
        }
    }
    return indexes.copy;
}

- (void)onServerChangeOnlineFriendsWithAddContact:(OnlineContactEntityMutableArray*)addContacts
                                    removeContact:(OnlineContactEntityMutableArray*)removeContacts
                                    updateContact:(OnlineContactEntityMutableArray*)updateContacts
                                       onlineList:(OnlineContactEntityMutableArray *)onlineList {
    dispatch_async(self.onlineTabObjectManagerQueue, ^{
        if (self.updateUI) {
            if (labs((long)([onlineList count] - [self.onlineContacts count])) > 3) {
                [self reloadDataWithNewOnlineList:onlineList];
            } else {
                OnlineContactEntityMutableArray *oldOnlineList = self.onlineContacts.copy;
                NSArray<NSIndexPath *> *removeIndexes = [self getIndexesInTableViewFromOnlineContactArray:removeContacts];
                [self setOnlineContact:onlineList];
                if (self.context.updateBlock) self.context.updateBlock();
                NSArray<NSIndexPath *> *addIndexes = [self getIndexesInTableViewFromOnlineContactArray:addContacts.copy];
                if ([self verifyCalculatedIndexesWithOldList:oldOnlineList newList:onlineList addCount:addIndexes.count deleteCount:removeIndexes.count]) {
                    [self.context.diffDelegate onDiffWithSectionInsert:[NSIndexSet new]
                                                         sectionRemove:[NSIndexSet new]
                                                         sectionUpdate:[self getSectionUpdate:0]
                                                               addCell:addIndexes
                                                            removeCell:removeIndexes
                                                         andUpdateCell:@[]];
                } else {
                    [self reloadDataWithNewOnlineList:onlineList];
                }
            }
        } else {
            self.onlineContacts = onlineList;
        }
    });
}

- (BOOL)verifyCalculatedIndexesWithOldList:(OnlineContactEntityMutableArray *)oldOnlineList newList:(OnlineContactEntityMutableArray *)newOnlineList addCount:(long)addCount deleteCount:(long)deleteCount {
    return (oldOnlineList.count - deleteCount + addCount) - newOnlineList.count == 0;
}

- (void)reloadDataWithNewOnlineList:(OnlineContactEntityMutableArray *)onlineList {
    [self setOnlineContact:onlineList];
    if (self.context.dataWithTransitionBlock) self.context.dataWithTransitionBlock();
}

- (void)setOnlineContact:(OnlineContactEntityMutableArray*)contacts {
    self.onlineContacts = contacts;
    [self.context bindNewData];
}


- (NSArray*)compileSection {
    return  [self compileOnlineSection:self.onlineContacts];
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

@end
