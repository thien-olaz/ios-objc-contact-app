//
//  ContactViewController.m
//  zalo-contact
//
//  Created by LAp14886 on 15/11/2021.
//

#import "ContactViewController.h"
#import "../Models/Contact.h"
#import "../ViewModels/ContactsLoader.h"
#import "../SectionControllers/ContactSectionController.h"
@import IGListKit;
@import FBLFunctional;


@interface ContactViewController () <IGListAdapterDataSource> {
    UICollectionView *collection;
    IGListAdapter *_adapter;
    ContactsLoader *loader;
}

@end



@implementation ContactViewController

- (id) init {
    self = [super init];
    
    loader = [[ContactsLoader alloc] init];
    collection = [[UICollectionView alloc] initWithFrame: CGRectZero collectionViewLayout: [UICollectionViewFlowLayout new]];
    return self;
}

// MARK: - Lazy var
- (IGListAdapter *) adapter {
    if (!_adapter) {
        _adapter = [[IGListAdapter alloc]
                    initWithUpdater: [IGListAdapterUpdater new]
                    viewController: self
                    workingRangeSize: 0];
    }
    return _adapter;
}

- (void) fetchData {
    [loader fetchContacts];
}

- (void) addView {
    [self.view addSubview:collection];
}

- (void) viewDidLoad {
    [super viewDidLoad];
        
    [self fetchData];
    
    [self addView];
    
    [self.adapter setCollectionView: collection];
    [self.adapter setDataSource: self];
    
  
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [collection setFrame:self.view.bounds];
}

- (NSArray<id<IGListDiffable>> *)objectsForListAdapter:(IGListAdapter *)listAdapter {
    NSMutableArray<id<IGListDiffable>> *items = loader.contactsArray;
    
    NSMutableDictionary *result = [NSMutableDictionary new];

    NSArray *distinctNames;

    distinctNames = [items valueForKeyPath:@"@distinctUnionOfObjects.header"];
    
    for (NSString *charactor in distinctNames) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"header = %@", charactor];
        NSArray *persons = [items filteredArrayUsingPredicate:predicate];
        [result setObject:persons forKey:charactor];
    }

    NSLog(@"%lu", (unsigned long)items.count);
    return items;
}

- (nullable UIView *)emptyViewForListAdapter:(IGListAdapter *)listAdapter {
    return nil;
}

- (IGListSectionController *)listAdapter:(IGListAdapter *)listAdapter sectionControllerForObject:(id)object {
    if ([object isKindOfClass:Contact.class]) {
        return [ContactSectionController new];
    } else {
        return [ContactSectionController new];
    }
    
}

@end
