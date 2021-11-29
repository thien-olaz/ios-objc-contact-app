//
//  CellFactory.h
//  zalo-contact
//
//  Created by Thiện on 29/11/2021.
//


@import Foundation;
@import UIKit;
#import "CellObject.h"
#import "HeaderObject.h"
#import "FooterObject.h"


NS_ASSUME_NONNULL_BEGIN

@interface CellFactory : NSObject
- (UITableViewCell *) cellForTableView:(UITableView *)tableView
                           atIndexPath:(NSIndexPath *)indexPath
                            withObject:(CellObject *)cellObject;

- (UIView *) headerForTableView:(UITableView *)tableView
                      inSection:(NSInteger)section
                     withObject:(HeaderObject *)object;

- (UIView *) footerForTableView:(UITableView *)tableView
                      inSection:(NSInteger)section
                     withObject:(FooterObject *)object;

@end

NS_ASSUME_NONNULL_END
