//
//  ContactViewController.h
//  zalo-contact
//
//  Created by LAp14886 on 15/11/2021.
//

@import UIKit;
@import CoreGraphics;
@import IGListKit;
@import FBLFunctional;
#import "ContactViewController.h"
#import "ContactEntity.h"
#import "ContactsLoader.h"
#import "ContactSectionController.h"
#import "OnlineFriendsSectionController.h"
#import "ContactViewModel.h"
#import "ActionCell.h"
#import "BlankFooterCell.h"


NS_ASSUME_NONNULL_BEGIN

@interface ContactViewController : UIViewController
- (id) initWithViewModel:(ContactViewModel *)vm;
@end

NS_ASSUME_NONNULL_END
