//
//  HeaderFooterFactory.h
//  zalo-contact
//
//  Created by Thiện on 30/11/2021.
//

@import Foundation;
@import UIKit;
#import "HeaderObject.h"
#import "FooterObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface HeaderFooterFactory : NSObject
- (UIView *)headerForTableView:(UITableView *)tableView withObject:(HeaderObject *)object;

- (UIView *)footerForTableViewWithObject:(FooterObject *)object;

- (CGFloat)heightForHeaderWithObject:(HeaderObject *)object;

- (CGFloat)heightForFooterWithObject:(FooterObject *)object;

@end

NS_ASSUME_NONNULL_END
