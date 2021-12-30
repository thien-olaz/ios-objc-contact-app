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
    TabItem *selectedItem;
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
        
    }
    return _collectionView;
}

- (void)setNeedsObject:(TabCellObject *)object {
    self.tabItems = object.tabItems;
    selectedItem = self.tabItems[object.selectedIndex];
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
    [collectionView registerClass:TabCollectionCell.class forCellWithReuseIdentifier:@"cell"];
    cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    TabItem *item = self.tabItems[indexPath.item];
    [cell setLabelText:item.name andNumber:item.number];
    
    if ([selectedItem.name isEqualToString: item.name]) {
        [collectionView selectItemAtIndexPath:indexPath animated:false scrollPosition:(UICollectionViewScrollPositionNone)];
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (selectedItem == self.tabItems[indexPath.item]) return;;
    selectedItem = self.tabItems[indexPath.item];
    self.didClick((int)indexPath.item);
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
