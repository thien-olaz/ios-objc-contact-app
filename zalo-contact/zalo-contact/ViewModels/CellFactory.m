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
- (UITableViewCell *) cellForTableView:(UITableView *)tableView
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
    return cell;
}

// Config header
- (UIView *) headerForTableView:(UITableView *)tableView
                      inSection:(NSInteger)section
                     withObject:(HeaderObject *)object {
    UIView *header = object.headerClass.new;
    
    if ([header respondsToSelector:@selector(setNeedsObject:)]) {
        [(id<ZaloHeader>)header setNeedsObject:object];
    }
    
    return UIView.new;
}

// Config footer
- (UIView *) footerForTableView:(UITableView *)tableView
                      inSection:(NSInteger)section
                     withObject:(FooterObject *)object {
    UIView *footer = object.footerClass.new;
    
    if ([footer respondsToSelector:@selector(setNeedsObject:)]) {
        [(id<ZaloHeader>)footer setNeedsObject:object];
    }
    
    return UIView.new;
}

@end
