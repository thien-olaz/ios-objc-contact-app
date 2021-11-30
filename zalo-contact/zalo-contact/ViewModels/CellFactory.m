//
//  CellFactory.m
//  zalo-contact
//
//  Created by Thiện on 29/11/2021.
//

#import "CellFactory.h"
#import "CellObject.h"
@import UIKit;

@implementation CellFactory

// Config cell
- (UITableViewCell *)cellForTableView:(UITableView *)tableView
                          atIndexPath:(NSIndexPath *)indexPath
                           withObject:(CellObject *)cellObject {
    UITableViewCell *cell = nil;
    
    NSString* identifier = NSStringFromClass(cellObject.cellClass);
    
    cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [cellObject.cellClass.alloc
                initWithStyle:(UITableViewCellStyleDefault)
                reuseIdentifier:identifier];
    }
    
    // Allow the cell to configure itself with the object's information.
    if ([cell respondsToSelector:@selector(setNeedsObject:)]) {
        [(id<ZaloCell>)cell setNeedsObject:cellObject];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowWithObject:(CellObject *)object {
    Class cellClass = object.cellClass;
    if ([cellClass respondsToSelector:@selector(heightForRowWithObject:)]) {
        return [cellClass heightForRowWithObject:object];
    }
    return tableView.rowHeight;
}

@end
