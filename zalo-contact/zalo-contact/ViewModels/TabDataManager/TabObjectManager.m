//
//  TabObjectManager.m
//  zalo-contact
//
//  Created by Thiện on 03/01/2022.
//

#import "TabObjectManager.h"

@implementation TabObjectManager

- (instancetype)initWithContext:(ContactViewModel *)context {
    self = [super init];
    
    self.context = context;
    self.tableViewDataSource = context.tableViewDataSource;
    self.updateUI = NO;
    
    NSString *queueName = NSStringFromClass([self class]);
    self.managerQueue = dispatch_queue_create([queueName cStringUsingEncoding:NSASCIIStringEncoding], SERIAL_QOS);
    SET_SPECIFIC_FOR_QUEUE(self.managerQueue);
    
    [[ZaloContactService sharedInstance] subcribe:self];
    
    return self;
}


- (NSIndexSet*)getSectionUpdate:(int)selectedIndex {
    NSMutableIndexSet *updateSet = [NSMutableIndexSet new];
    [updateSet addIndex:2];
    return updateSet;
}

- (TabItem*)getTabItem {
    return [[TabItem alloc] initWithName:[self getTabTitle] andNumber:[self getTabCount]];
}

- (NSString *)getTabTitle {
    return @"";
}

- (int)getTabCount{
    return 0;
}

- (NSArray *)compileSection {
    return @[];
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

- (void)reloadUI {
    
}

@end
