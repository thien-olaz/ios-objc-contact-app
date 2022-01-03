//
//  ContactVM.m
//  zalo-contact
//
//  Created by Thiện on 03/01/2022.
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
#import "TabObjectManager.h"
#import "OnlineTabObjectManager.h"
#import "ContactTabObjectManager.h"

@interface ContactViewModel ()

@property NSMutableArray<Class> *tabOrder;
@property NSMutableDictionary<Class, TabObjectManager*> *objectManagerDict;

@property TabObjectManager *tabObjectManager;

@end

@implementation ContactViewModel

- (instancetype)initWithActionDelegate:(id<TableViewActionDelegate>)action
                       andDiffDelegate:(id<TableViewDiffDelegate>)diff {
    self = super.init;
    self.actionDelegate = action;
    self.diffDelegate = diff;
    
    self.tabOrder = @[].mutableCopy;
    self.objectManagerDict = @{}.mutableCopy;
    
    return self;
}

- (void)configTabObject {
    [self addNewTab:[[ContactTabObjectManager alloc] initWithContext:self]];
    [self addNewTab:[[OnlineTabObjectManager alloc] initWithContext:self]];
    //    make contact tab default
    [[self.objectManagerDict objectForKey:ContactTabObjectManager.class] setUpdateUI:YES];
    self.tabObjectManager = [self.objectManagerDict objectForKey:ContactTabObjectManager.self];
}

- (void)addNewTab:(TabObjectManager*)objManager {
    [self.tabOrder addObject:objManager.class];
    [self.objectManagerDict setObject:objManager forKey:[objManager class].self];
}

- (void)changeToObjectManagerState:(Class)classState {
    if (![self.tabOrder containsObject:classState]) return;
    [self.tabObjectManager stopUI];
    self.tabObjectManager = [self.objectManagerDict objectForKey:classState];
    [self.tabObjectManager reloadUI];
    [self.tabObjectManager startUI];
}

- (void)setup {
    [self bindNewData];
    if (self.dataBlock) self.dataBlock();
    [self configTabObject];
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

- (void)bindNewData {
    self.data = [self compileData];
}

- (NSArray *)compileTabObject {
    NSMutableArray *data = [NSMutableArray new];
    [data addObject:[[NullHeaderObject alloc] init]];
    NSMutableArray *tabList = @[].mutableCopy;
    
    for (Class classKey in self.tabOrder) {
        TabObjectManager *objManager = [self.objectManagerDict objectForKey:classKey];
        if ([objManager getTabCount]) [tabList addObject:[objManager getTabItem]];
    }
    
    [data addObject:[[TabCellObject alloc] initWithTabItem:tabList.copy selectedIndex:(int)[self.tabOrder indexOfObject:[self.tabObjectManager class].self] withDidClickBlock:^(int selectedIndex) {
        [self.tabObjectManager switchToTabClass:[self.tabOrder objectAtIndex:selectedIndex]];
    }]];
    
    [data addObject:ContactFooterObject.new];
    return [data copy];
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
    if (!self.tabObjectManager)  return data;
    
    [data addObjectsFromArray:[self compileTabObject]];
    [data addObjectsFromArray:[self.tabObjectManager compileSection]];        
    
    //MARK: - Footer section
    [data addObject:[[NullHeaderObject alloc] initWithLeter:@"#"]];
    
    [data addObject:[LabelCellObject.alloc initWithTitle:[NSString stringWithFormat:@"%d bạn", [[self.objectManagerDict objectForKey:ContactTabObjectManager.self] getTabCount]] andTextAlignment:NSTextAlignmentCenter color:UIColor.zaloBackgroundColor cellType:shortCell]];
    
    [data addObject:[LabelCellObject.alloc initWithTitle:@"Nhanh chóng thêm bạn vào Zalo từ danh \nbạ điện thoại" andTextAlignment:NSTextAlignmentCenter color:UIColor.zaloLightGrayColor cellType:tallCell]];
    
    [data addObject:[UpdateContactObject.alloc initWithTitle:@"Cập nhập danh bạ" andAction:^{
        
    }]];
    
    [data addObject:BlankFooterObject.new];
    
    
    return data;
}

@end
