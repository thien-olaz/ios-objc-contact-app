//
//  ContactTableViewAction.m
//  zalo-contact
//
//  Created by Thiện on 29/11/2021.
//

#import "ContactTableViewAction.h"

@interface ContactTableViewAction ()

@property NSMutableDictionary* objectToAction;

@end

@implementation ContactTableViewAction {
    HeaderFooterFactory *viewFactory;
}

- (instancetype)init {
    self = super.init;
    _objectToAction = [NSMutableDictionary dictionary];
    viewFactory = HeaderFooterFactory.new;
    return self;
}

- (id)keyForObject:(id<NSObject>)object {
    return @(object.hash);
}

- (CellObject *)attachToObject:(CellObject *)object action:(TapBlock)tapped {
    if (![self.objectToAction objectForKey:[self keyForObject:object]]) {
        [self.objectToAction setObject:tapped forKey:[self keyForObject:object]];
    }
    return object;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    id object = [(id<ZaloDataSource>)tableView.dataSource objectAtIndexPath:indexPath];
    TapBlock tap = [self.objectToAction objectForKey:[self keyForObject:object]];
    if (tap) tap();
}

#pragma mark - header footer view
//if the height for header is 0, this method will never called
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    HeaderObject *headerObj = [(id<ZaloDataSource>)tableView.dataSource headerObjectInSection:section];
    
    if (headerObj) {
        return [viewFactory headerForTableViewWithObject:headerObj];
    }
    return UIView.new;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    FooterObject *footerObj = [(id<ZaloDataSource>)tableView.dataSource footerObjectInSection:section];
    if (footerObj) {
        return [viewFactory footerForTableViewWithObject:footerObj];
    }
    return UIView.new;
}


#pragma mark - height provider

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    HeaderObject *headerObject = [(id<ZaloDataSource>)tableView.dataSource headerObjectInSection:section];
    if (headerObject) {
        return [viewFactory heightForHeaderWithObject:headerObject];
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    FooterObject *footerObject = [(id<ZaloDataSource>)tableView.dataSource footerObjectInSection:section];
    if (footerObject) {
        return [viewFactory heightForFooterWithObject:footerObject];
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView.dataSource respondsToSelector:@selector(tableView:heightForRowAtIndexPath:)]) {
        return [(id<ZaloDataSource>)tableView.dataSource tableView:tableView heightForRowAtIndexPath:indexPath];
    }
    return tableView.rowHeight;
}



@end
