//
//  TabCell.m
//  zalo-contact
//
//  Created by Thiện on 28/12/2021.
//

#import "TabCell.h"
#import "TabCellObject.h"
#import "TabCollectionCell.h"


@interface TabCell () {
    int selectedIndex;
}
@property (copy) OnTabItemClick didClick;
@property NSMutableArray<TabItem *>* tabItems;
@property (nonatomic, assign) BOOL didSetupConstraints;
@property (nonatomic, strong) UICollectionView *collectionView;

@end


@implementation TabCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    [self setSelectionStyle:(UITableViewCellSelectionStyleNone)];
    [self setBackgroundColor:UIColor.zaloBackgroundColor];
    
    self.tabItems = [NSMutableArray new];
    [self.contentView addSubview:self.collectionView];
    [self.contentView setNeedsUpdateConstraints];
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.collectionView.frame = CGRectInset(self.bounds, UIConstants.contactCellMinHorizontalInset, UIConstants.contactCellMinHorizontalInset);
    
}

- (void)prepareForReuse {
    [super prepareForReuse];
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [UICollectionViewFlowLayout new];
        [flowLayout setScrollDirection: UICollectionViewScrollDirectionHorizontal];
        flowLayout.estimatedItemSize = UICollectionViewFlowLayoutAutomaticSize;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        [_collectionView setShowsHorizontalScrollIndicator:NO];
        [_collectionView setShowsVerticalScrollIndicator:NO];
        [_collectionView setDelegate:self];
        [_collectionView setDataSource:self];
        [_collectionView registerClass:TabCollectionCell.class forCellWithReuseIdentifier:@"cell"];
    }
    return _collectionView;
}

- (void)setNeedsObject:(TabCellObject *)object {
    self.tabItems = object.tabItems;
    selectedIndex = object.selectedIndex;
    self.didClick = object.didClick;
    [UIView performWithoutAnimation:^{
        [self.collectionView reloadSections:[[NSIndexSet alloc] initWithIndex:0]];
    }];
}

+ (CGFloat)heightForRowWithObject:(nonnull TabCellObject *)object {
    return 36 + UIConstants.contactCellMinHorizontalInset * 2;
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    TabCollectionCell *cell = nil;
    cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    TabItem *item = self.tabItems[indexPath.item];
    [cell setLabelText:item.name andNumber:item.number];
    if (selectedIndex == indexPath.item) {
        [collectionView selectItemAtIndexPath:indexPath animated:false scrollPosition:(UICollectionViewScrollPositionNone)];
    }
    return cell;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (selectedIndex == indexPath.item) return true;
    selectedIndex = (int)indexPath.item;
    dispatch_async(GLOBAL_QUEUE, ^{
        self.didClick((int)indexPath.item);
    });
    return true;
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.tabItems.count;
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    TabItem *item = self.tabItems[indexPath.item];
    CGSize cellSize = [TabCollectionCell calculateTextSize:item.name andNumber:item.number];
    cellSize.height = 36;
    cellSize.width += 30;
    return cellSize;
}

@end
