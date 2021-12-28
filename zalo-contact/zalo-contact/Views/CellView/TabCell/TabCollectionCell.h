//
//  TabCollectionCell.h
//  zalo-contact
//
//  Created by Thiện on 28/12/2021.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TabCollectionCell : UICollectionViewCell
- (void)setLabelText:(NSString *)text andNumber:(int)number;
+ (CGSize)calculateTextSize:(NSString *)text andNumber:(int)number;

@end

NS_ASSUME_NONNULL_END
