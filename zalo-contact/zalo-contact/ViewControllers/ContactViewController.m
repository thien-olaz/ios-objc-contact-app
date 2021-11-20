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
    BOOL didSetupConstraints;
}
@property IGListAdapter *adapter;
@property ContactsLoader *loader;

@end

@implementation ContactViewController

- (id) init {
    self = [super init];
    
    _loader = [[ContactsLoader alloc] init];
    collection = [[UICollectionView alloc] initWithFrame: CGRectZero collectionViewLayout: [UICollectionViewFlowLayout new]];
//    collection.
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)collection.collectionViewLayout;
    layout.sectionHeadersPinToVisibleBounds = YES;
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
    
}

- (void) addView {
    [self.view addSubview:collection];
}

- (void) checkPermissionAndFetchData {
    ContactsLoader *loader = _loader;
    dispatch_async(dispatch_get_main_queue(), ^{
        [UserContacts checkAccessContactPermission];
        [UserContacts.sharedInstance fetchLocalContacts];
        [loader update];
        [_adapter performUpdatesAnimated:YES completion:nil];
    });
}

- (void) viewDidLoad {
    [super viewDidLoad];
    
    [self checkPermissionAndFetchData];
    
    [self addView];
    
    [self.adapter setCollectionView: collection];
    [self.adapter setDataSource: self];
    
    [self.view setNeedsUpdateConstraints];
    
}

- (void)updateViewConstraints {
    if (!didSetupConstraints) {
        [collection autoPinEdgesToSuperviewEdges];
        didSetupConstraints = YES;
    }
    [super updateViewConstraints];
}

- (NSArray<id<IGListDiffable>> *)objectsForListAdapter:(IGListAdapter *)listAdapter {
    NSMutableArray<id<IGListDiffable>> *items = _loader.contactGroup;
    return items;
}

- (nullable UIView *)emptyViewForListAdapter:(IGListAdapter *)listAdapter {
    return nil;
}
// MARK: - đọc IGListAdapter
- (IGListSectionController *)listAdapter:(IGListAdapter *)listAdapter sectionControllerForObject:(id)object {
    if ([object isKindOfClass:ContactGroup.class]) {
        return [ContactSectionController new];
    } else {
        return [ContactSectionController new];
    }
    
}

@end
