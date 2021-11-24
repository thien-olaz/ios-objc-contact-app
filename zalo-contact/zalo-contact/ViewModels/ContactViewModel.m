//
//  ContactViewModel.m
//  zalo-contact
//
//  Created by Thiện on 23/11/2021.
//
#import "ContactViewModel.h"

@implementation ContactViewModel {
    ContactsLoader *loader;
    NSMutableArray<NSObject *> *data;
}

- (instancetype)init {
    self = [super init];
    //MARK: Hardcoded - add check permission
    loader =  [[ContactsLoader alloc] init];
    [loader update];
    data = NSMutableArray.alloc.init;
    
    // Mock data - replace later
    [data addObject:@"friendRequest"];
    [data addObject:@"addFriendFromDevice"];
    [data addObject:@"header"];
    [data addObjectsFromArray:loader.contactGroup];
    
    return self;
}

// MARK: UITableViewDataSource

// MARK: Need to turn all of this to use switch or enum base to manage the cell
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    if ([data[indexPath.section] isKindOfClass:NSString.class]) {
        //MARK: These two cell must be in the same section
        if ([(NSString *)data[indexPath.section] isEqual:@"friendRequest"]) {
            FriendRequestsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"actionCell" forIndexPath: indexPath];
            [cell setTitle:@"Lời mời kết bạn"];
            [cell setIconImage:[UIImage imageNamed:@"ct_people"]];
            [cell setBlock:^{
                NSLog(@"Perform present view controller here!");
            }];
            return cell;
        } else if ([(NSString *)data[indexPath.section] isEqual:@"addFriendFromDevice"]) {
            FriendRequestsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"actionCell" forIndexPath: indexPath];
            [cell setTitle:@"Thêm bạn từ danh bạ máy"];
            [cell setIconImage:[UIImage imageNamed:@"ct_people"]];
            [cell setBlock:^{
                NSLog(@"Perform present view controller here!");
            }];
            return cell;
        }
        UpdateContactCell *cell = [tableView dequeueReusableCellWithIdentifier:@"updateContactHeaderCell" forIndexPath: indexPath];
        [cell setSectionTitle: @"Danh bạ"];
        [cell setButtonTitle: @"CẬP NHẬP"];
        return cell;
    }
    
    ContactCell *cell = [tableView dequeueReusableCellWithIdentifier:@"contactCell" forIndexPath: indexPath];
    
    Contact *contact = ((ContactGroup *)data[indexPath.section]).contacts[indexPath.row];
    
    [cell setNameWith: contact.fullName];
    [cell setSubtitleWith: contact.fullName];
    [cell setAvatarImageUrl: contact.imageUrl];
    [cell setPhoneBlock:^{
        NSLog(@"Phone call");
    }];
    [cell setVideoBlock:^{
        NSLog(@"Video call");
    }];
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([data[section] isKindOfClass:NSString.class]) {
        return 1;
    } else {
        ContactGroup *group = (ContactGroup *)data[section];
        return group.contacts.count;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return data.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return ((ContactGroup *)loader.contactGroup[section]).header;
}

- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return @[@"",@"C",@"H",@"L",@"N",@"T"];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // MARK: Check by section pleaseee
    return 60;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UITableViewCell *header;
    if ([data[section] isKindOfClass:NSString.class]) {
        return [UIView alloc].init;
    } else {
        header = [ContactHeaderCell.alloc
                  initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 20)];
        [(ContactHeaderCell *)header setSectionTitle:[(ContactGroup *)data[section] header]];
    }
    
    return header;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if ([data[section] isKindOfClass:NSString.class]) {
        if ([data[section] isKindOfClass:NSString.class]) {
            if ([(NSString *)data[section] isEqual:@"friendRequest"]) {
                return [GrayFooterCell.alloc
                        initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 5)];;
            } else if ([(NSString *)data[section] isEqual:@"addFriendFromDevice"]) {
                return [GrayFooterCell.alloc
                        initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 5)];
            }
        }
    }
    ContactFooterCell *footer = [ContactFooterCell.alloc
                                 initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 20)];
    return footer;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([data[section] isKindOfClass:NSString.class]) {
        return 0;
    }
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if ([data[section] isKindOfClass:NSString.class]) {
        if ([(NSString *)data[section] isEqual:@"friendRequest"]) {
            return 8;
        } else if ([(NSString *)data[section] isEqual:@"addFriendFromDevice"]) {
            return 8;
        }
    }
    return 20;
}

@end
