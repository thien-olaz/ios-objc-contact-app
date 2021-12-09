//
//  UpdateContactCell.h
//  zalo-contact
//
//  Created by Thiện on 08/12/2021.
//

#import "UIConstants.h"
#import "UIColorExt.h"
#import "UpdateContactObject.h"
@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@interface UpdateContactCell : UITableViewCell<ZaloCell>

@property (copy) ActionBlock action;

@end

NS_ASSUME_NONNULL_END
