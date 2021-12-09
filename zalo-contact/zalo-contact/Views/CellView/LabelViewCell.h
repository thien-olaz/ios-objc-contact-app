//
//  CenterLabelHeaderView.h
//  zalo-contact
//
//  Created by Thiện on 08/12/2021.
//

@import Foundation;
@import UIKit;
#import "UIConstants.h"
#import "UIColorExt.h"
#import "CommonHeaderAndFooterViews.h"
#import "CommonCellObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface LabelViewCell : UITableViewCell<ZaloCell>
- (instancetype)initWithTitle:(NSString *)title;
- (void)setTextAlignment:(NSTextAlignment)alignment;
- (void)setSectionTitle:(NSString *)title;
@end

NS_ASSUME_NONNULL_END
