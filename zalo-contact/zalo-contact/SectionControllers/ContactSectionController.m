//
//  ContactSectionController.m
//  zalo-contact
//
//  Created by LAp14886 on 16/11/2021.
//

#import "ContactSectionController.h"

@implementation ContactSectionController {
    ContactGroup *entry;
}

// Header Cell + Contacts Cell + Footer Cell
- (NSInteger)numberOfItems {
    return 1 + entry.contacts.count + 1;
}

- (CGSize)sizeForItemAtIndex:(NSInteger)index {
    if (![self collectionContext] || !entry) {
        return CGSizeZero;
    }
    
    CGFloat width = self.collectionContext.containerSize.width;
    
    if (index == 0)
        return CGSizeMake(width, UIConstants.contactHeaderHeight);
    else if (index == self.numberOfItems - 1)
        return CGSizeMake(width, UIConstants.contactFooterHeight);
    else
        return CGSizeMake(width, UIConstants.contactCellHeight);
    
    
}

- (__kindof UICollectionViewCell *)cellForItemAtIndex:(NSInteger)index {
    Class cellClass = index == 0 ? ContactHeaderCell.class :
    index == self.numberOfItems - 1 ? ContactFooter.class : ContactCell.class;
    
    UICollectionViewCell *cell = [self.collectionContext dequeueReusableCellOfClass:cellClass forSectionController:self atIndex:index];
    
    if ([cell isKindOfClass: ContactCell.class]) {
        [(ContactCell *)cell setNameWith: entry.contacts[index - 1].fullName];
        [(ContactCell *)cell setAvatarImageUrl: entry.contacts[index - 1].imageUrl];
    } else if ([cell isKindOfClass: ContactHeaderCell.class]) {
        [(ContactHeaderCell *)cell setSectionTitle:entry.header];
    }
    
    return cell;
}

- (void)didUpdateToObject:(id)object {
    entry = (ContactGroup *)object;
}

@end
