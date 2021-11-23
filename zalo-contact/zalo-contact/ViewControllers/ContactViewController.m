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
    
    [UserContacts checkAccessContactPermission:^(BOOL complete) {
        if (complete) {
            [UserContacts.sharedInstance fetchLocalContacts];
            [loader update];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self->_adapter performUpdatesAnimated:YES completion:nil];
            });
        } else {
            UIAlertController *alertController = [UIAlertController
                                                  alertControllerWithTitle:@"No permission"
                                                  message:@"Please go to setting and turn on contact access permission"
                                                  preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction
                                     actionWithTitle:@"Open setting"
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * _Nonnull action)
                                     {
                // Open setting
                [UIApplication.sharedApplication
                 openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]
                 options:@{}
                 completionHandler:^(BOOL Success){}];
            }];
            
            [alertController addAction:action];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self presentViewController:alertController animated:true completion:nil];
            });            
        }
    }];
}

- (void) viewDidLoad {
    [super viewDidLoad];
    
    
    [self addView];
    
    [self.adapter setCollectionView: collection];
    [self.adapter setDataSource: self];
    
    //Load the cached contacts list
    [_loader update];
    [_adapter performUpdatesAnimated:YES completion:nil];
    
    //Check for contact access permission and update the list if YES
    [self checkPermissionAndFetchData];
    
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
