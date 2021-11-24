//
//  FriendRequestsCell.h
//  zalo-contact
//
//  Created by Thiện on 24/11/2021.
//

#import <UIKit/UIKit.h>
#import "UIConstants.h"
@import PureLayout;
@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@interface FriendRequestsCell : UITableViewCell

- (void) setTitle:(NSString *)title;
- (void) setIconImage:(nonnull UIImage*)image;

@end

NS_ASSUME_NONNULL_END
