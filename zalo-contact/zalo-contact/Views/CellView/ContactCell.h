//
//  ContactCell.h
//  zalo-contact
//
//  Created by Thiện on 16/11/2021.
//
#import "UIConstants.h"
#import "UIColorExt.h"
#import "CellObject.h"
#import "ContactObject.h"
@import Foundation;
@import UIKit;
@import PureLayout;
@import SDWebImage;


NS_ASSUME_NONNULL_BEGIN

typedef void (^PhoneCallBlock)(void);
typedef void (^VideoCallBlock)(void);

@interface ContactCell : UITableViewCell<ZaloCell>
@property (copy) PhoneCallBlock phoneBlock;
@property (copy) VideoCallBlock videoBlock;

- (void)setNameWith:(NSString *)name;
- (void)setSubtitleWith:(NSString *)subtitle;
- (void)setAvatarImage:(nonnull UIImage*)image;
- (void)setAvatarImageUrl:(NSString * __nullable)url;
- (void)setOnline;
@end

NS_ASSUME_NONNULL_END
