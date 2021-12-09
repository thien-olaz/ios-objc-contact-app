//
//  UpdateContactCell.h
//  zalo-contact
//
//  Created by Thiện on 24/11/2021.
//

@import UIKit;
@import PureLayout;
#import "UIConstants.h"
#import "UIColorExt.h"
#import "CommonHeaderAndFooterViews.h"
NS_ASSUME_NONNULL_BEGIN

typedef void (^ActionBlock)(void);

@interface ActionHeaderView : UITableViewHeaderFooterView<ZaloHeader>

@property (copy) ActionBlock block;

- (void)setSectionTitle:(NSString *)title;
- (void)setButtonTitle:(NSString *)title;

@end

NS_ASSUME_NONNULL_END
