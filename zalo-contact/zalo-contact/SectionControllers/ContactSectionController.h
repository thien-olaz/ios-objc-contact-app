//
//  ContactSectionController.h
//  zalo-contact
//
//  Created by LAp14886 on 16/11/2021.
//

#import <IGListKit/IGListKit.h>
#import "../Models/Contact.h"
#import "../Models/ContactGroup.h"
#import "../Views/ContactView/ContactCell.h"
#import "../Views/ContactView/ContactHeaderCell.h"
#import "../Views/ContactView/ContactFooterCell.h"
#import "../Ultilities/UIConstants.h"

NS_ASSUME_NONNULL_BEGIN

@interface ContactSectionController : IGListSectionController<IGListSupplementaryViewSource>

@end

NS_ASSUME_NONNULL_END
