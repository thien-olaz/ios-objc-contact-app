//
//  ContactSectionController.m
//  zalo-contact
//
//  Created by LAp14886 on 16/11/2021.
//

#import "ContactSectionController.h"

@implementation ContactSectionController {
    ContactGroupEntity *entry;
}

- (instancetype)init {
    self = [super init];
    [self setSupplementaryViewSource:self];
    return self;
}

// Header Cell + Contacts Cell + Footer Cell
- (NSInteger)numberOfItems {
    return entry.contacts.count;
}

-(CGFloat) width {
    if (self.collectionContext.containerSize.width) {
        return self.collectionContext.containerSize.width;
    }
    return 0;
    
}

- (CGSize)sizeForItemAtIndex:(NSInteger)index {
    if (![self collectionContext] || !entry) {
        return CGSizeZero;
    }

    return CGSizeMake(self.width, UIConstants.contactCellHeight);
    
    
}

- (__kindof UICollectionViewCell *)cellForItemAtIndex:(NSInteger)index {
    Class cellClass = ContactCell.class;
    
    UICollectionViewCell *cell = [self.collectionContext
                                  dequeueReusableCellOfClass:cellClass
                                  forSectionController:self
                                  atIndex:index];
    
    [(ContactCell *)cell setNameWith: entry.contacts[index].fullName];
    [(ContactCell *)cell setSubtitleWith: entry.contacts[index].fullName];
    [(ContactCell *)cell setAvatarImageUrl: entry.contacts[index].imageUrl];
    
    return cell;
}

- (void)didUpdateToObject:(id)object {
    entry = (ContactGroupEntity *)object;
}

- (CGSize)sizeForSupplementaryViewOfKind:(nonnull NSString *)elementKind
                                 atIndex:(NSInteger)index {
    if ([elementKind isEqualToString:UICollectionElementKindSectionHeader])
        return CGSizeMake(self.width, UIConstants.contactHeaderHeight);
    else if ([elementKind isEqualToString:UICollectionElementKindSectionFooter])
        return CGSizeMake(self.width, UIConstants.contactFooterHeight);
    return CGSizeZero;
}

- (nonnull NSArray<NSString *> *)supportedElementKinds {
    return @[UICollectionElementKindSectionHeader, UICollectionElementKindSectionFooter];
}

- (nonnull __kindof UICollectionReusableView *)viewForSupplementaryElementOfKind:(nonnull NSString *)elementKind
                                                                         atIndex:(NSInteger)index {
    if ([elementKind isEqualToString:UICollectionElementKindSectionHeader])
        return [self headerViewFor:(int)index];
    else if ([elementKind isEqualToString:UICollectionElementKindSectionFooter])
        return [self footerViewFor:(int)index];
    
    return UICollectionReusableView.new;
}

- (UICollectionReusableView *)headerViewFor:(int)index {
    HeaderCell *view = [self.collectionContext
                               dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                               forSectionController:self
                               class:HeaderCell.class
                               atIndex:index];
    [view setSectionTitle:entry.header];
    return view;
}

- (UICollectionReusableView *)footerViewFor:(int)index {
    ContactFooterCell *view = [self.collectionContext
                               dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                               forSectionController:self
                               class:ContactFooterCell.class
                               atIndex:index];
    return view;
}
@end
