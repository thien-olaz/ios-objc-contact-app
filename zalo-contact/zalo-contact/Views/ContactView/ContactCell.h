//
//  ContactCell.h
//  zalo-contact
//
//  Created by Thiện on 16/11/2021.
//
#import "UIConstants.h"
#import "UIColorExt.h"
@import Foundation;
@import UIKit;
@import PureLayout;
@import SDWebImage;


NS_ASSUME_NONNULL_BEGIN

@interface ContactCell : UITableViewCell

- (void) setNameWith:(NSString *)name;
- (void) setSubtitleWith:(NSString *)subtitle;
- (void) setAvatarImage:(nonnull UIImage*)image;
- (void) setAvatarImageUrl:(NSString * __nullable)url;

@end

NS_ASSUME_NONNULL_END
