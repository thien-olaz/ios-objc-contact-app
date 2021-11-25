//
//  ContactSectionController.h
//  zalo-contact
//
//  Created by LAp14886 on 16/11/2021.
//

#import <IGListKit/IGListKit.h>
#import "ContactEntity.h"
#import "ContactGroupEntity.h"
#import "ContactCell.h"
#import "HeaderCell.h"
#import "ContactFooterCell.h"
#import "UIConstants.h"

NS_ASSUME_NONNULL_BEGIN

@interface ContactSectionController : IGListSectionController<IGListSupplementaryViewSource>

@end

NS_ASSUME_NONNULL_END
