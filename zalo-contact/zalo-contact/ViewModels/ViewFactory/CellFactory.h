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

- (CGFloat)tableView:(UITableView *)tableView heightForRowWithObject:(CellObject *)object;

@end

NS_ASSUME_NONNULL_END
