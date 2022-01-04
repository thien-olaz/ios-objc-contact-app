//
//  TabObjectManager.h
//  zalo-contact
//
//  Created by Thiện on 03/01/2022.
//

#import <Foundation/Foundation.h>
#import "ContactTableViewDataSource.h"
#import "ContactViewModel.h"
#import "ZaloContactService.h"
#import "ZaloContactService+Observer.h"
#import "TabStateProtocol.h"
#import "TabCellObject.h"
NS_ASSUME_NONNULL_BEGIN


@interface TabObjectManager : NSObject<ZaloContactEventListener, TabStateProtocol>

@property ContactViewModel *context;

@property ContactTableViewDataSource *tableViewDataSource;
@property BOOL updateUI;
@property dispatch_queue_t managerQueue;

- (instancetype)initWithContext:(ContactViewModel *)context;

- (int)getTabCount;
- (TabItem*)getTabItem;
- (NSString*)getTabTitle;
- (NSArray*)compileSection;
- (NSIndexSet*)getSectionUpdate:(int)selectedIndex;

- (void)startUI;
- (void)stopUI;
- (void)reloadUI;
@end

NS_ASSUME_NONNULL_END
 
