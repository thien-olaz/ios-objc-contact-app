//
//  ContactSectionCell.h
//  zalo-contact
//
//  Created by Thiện on 16/11/2021.
//

@import Foundation;
@import UIKit;
@import PureLayout;
#import "UIConstants.h"
#import "UIColorExt.h"

NS_ASSUME_NONNULL_BEGIN

@interface HeaderCell : UITableViewCell

- (instancetype)initWithTitle:(NSString *)title;
- (void) setSectionTitle:(NSString *)title;
    
@end

NS_ASSUME_NONNULL_END
