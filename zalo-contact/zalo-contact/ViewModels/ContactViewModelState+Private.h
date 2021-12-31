//
//  ContactViewModelState+Private.h
//  zalo-contact
//
//  Created by Thiện on 31/12/2021.
//
#import "ContactViewModelState.h"

#ifndef ContactViewModelState_Private_h
#define ContactViewModelState_Private_h

@interface ContactViewModelState ()

@property int selectedTabIndex;
//@property NSMutableDictionary<NSString *, NSMutableArray<>> *selectedTabItem;
@property NSMutableOrderedSet<TabItem * > *tabItems;
@property AccountMutableDictionary *accountDictionary;
@property dispatch_queue_t datasourceQueue;
@property id<TableViewDiffDelegate> diffDelegate;
@property id<TableViewActionDelegate> actionDelegate;
@property NSMutableArray<ContactGroupEntity *> *contactGroups;
@property OnlineContactEntityMutableArray *onlineContacts;
@property BOOL updateUI;

- (void)compileDataFromContactGroup:(NSArray<ContactGroupEntity *>*)groups;
- (NSIndexSet*)getSectionUpdate:(int)selectedIndex;
- (NSMutableArray *)compileData;
- (nullable NSArray *)compileCustomSection;

@end

#endif /* ContactViewModelState_Private_h */
