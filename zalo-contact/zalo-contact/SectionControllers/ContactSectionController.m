//
//  ContactSectionController.m
//  zalo-contact
//
//  Created by LAp14886 on 16/11/2021.
//

#import "ContactSectionController.h"
#import "../Models/Contact.h"
#import "../Views/ContactCell.h"

@implementation ContactSectionController {
    Contact *entry;
    
}

- (id) init {
    self = [super init];
    [self setInset: UIEdgeInsetsMake(0, 0, 15, 0)];
    return self;
}

- (NSInteger)numberOfItems {
    return 1;
}

- (CGSize)sizeForItemAtIndex:(NSInteger)index {
    if (![self collectionContext] || !entry) {
        return CGSizeZero;
    }
    CGFloat width = self.collectionContext.containerSize.width;
    
    return CGSizeMake(width, 50);
}

- (__kindof UICollectionViewCell *)cellForItemAtIndex:(NSInteger)index {
    Class cellClass = index == 0 ? ContactCell.class : UICollectionViewCell.class;
    
    UICollectionViewCell *cell = [self.collectionContext dequeueReusableCellOfClass:cellClass forSectionController:self atIndex:index];
    if ([cell isKindOfClass: ContactCell.class]) {
        [(ContactCell *)cell setNameWith: entry.name];
    }
    
    return cell;
}

- (void)didUpdateToObject:(id)object {
    entry = (Contact *)object;
}

@end
