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

@implementation ContactTableViewAction

- (instancetype)init {
    self = super.init;
    _objectToAction = [NSMutableDictionary dictionary];
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
    id object = [(id<ZaloTableviewDataSource>)tableView.dataSource objectAtIndexPath:indexPath];
    TapBlock tap = [self.objectToAction objectForKey:[self keyForObject:object]];
    if (tap) tap();
}


@end
