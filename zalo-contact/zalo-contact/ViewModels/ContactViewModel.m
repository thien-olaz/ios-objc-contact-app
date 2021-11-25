//
//  ContactViewModel.m
//  zalo-contact
//
//  Created by Thiện on 23/11/2021.
//
#import "ContactViewModel.h"

// MARK: - Table cells concept
/*
 -- indivisual cell
 -- start section
 -- section header
 -- cell
 -- cell
 -- cell
 -- section footer
 ========================
 -- section header
 -- cell
 -- cell
 -- cell
 -- section footer
 -- end section
 */

@implementation ContactViewModel {
    ContactsLoader *loader;
    NSMutableArray<CellItem *> *data;
}

- (instancetype)init {
    self = [super init];
    //MARK: Hardcoded - add check permission
    loader =  [[ContactsLoader alloc] init];
    [loader update];
    
    data = NSMutableArray.alloc.init;
    
    // Mock data - replace later
    [data addObject:[CellItem initWithType:@"friendRequest" data:@[]]];
    [data addObject:[CellItem initWithType:@"addFriendFromDevice" data:@[]]];
    [data addObject:[CellItem initWithType:@"closeFriends" data:@[]]];
    
    [data addObject:[CellItem initWithType:@"onlineFriends" data: loader.mockOnlineFriends]];
    [data addObject:[CellItem initWithType:@"updateContactHeaderCell" data:@[]]];
    for (ContactGroupEntity *group in loader.contactGroup) {
        [data addObject:[CellItem initWithType:@"contacts" data:group]];
    }
    return self;
}

// MARK: UITableViewDataSource

// MARK: Need to turn all of this to use switch or enum base to manage the cell
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    if ([data[indexPath.section].cellType isEqual:@"friendRequest"]) {
        ActionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"actionCell" forIndexPath: indexPath];
        [cell setTitle:@"Lời mời kết bạn"];
        [cell setIconImage:[UIImage imageNamed:@"ct_people"]];
        [cell setBlock:^{
            NSLog(@"Perform present view controller here!");
        }];
        return cell;
    } else if ([data[indexPath.section].cellType isEqual:@"addFriendFromDevice"]) {
        ActionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"actionCell" forIndexPath: indexPath];
        [cell setTitle:@"Thêm bạn từ danh bạ máy"];
        [cell setIconImage:[UIImage imageNamed:@"ct_people"]];
        [cell setBlock:^{
            NSLog(@"Perform present view controller here!");
        }];
        return cell;
    } else if ([data[indexPath.section].cellType isEqual:@"closeFriends"]) {
        ActionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"actionCell" forIndexPath: indexPath];
        [cell setTitle:@"Chọn bạn thường liên lạc"];
        [cell setIconImage:[UIImage imageNamed:@"ct_plus"]];
        [cell setTitleTintColor:UIColor.systemBlueColor];
        [cell setBlock:^{
            NSLog(@"Perform present view controller here!");
        }];
        return cell;
    } else if ([data[indexPath.section].cellType isEqual:@"onlineFriends"]) {
        // contacts
        ContactCell *cell = [tableView dequeueReusableCellWithIdentifier:@"contactCell" forIndexPath: indexPath];
        
        ContactEntity *contact = ((ContactGroupEntity *)data[indexPath.section].data).contacts[indexPath.row];
        
        [cell setNameWith: contact.fullName];
        [cell setSubtitleWith: contact.fullName];
        [cell setAvatarImageUrl: contact.imageUrl];
        [cell setOnline];
        [cell setPhoneBlock:^{
            NSLog(@"Phone call");
        }];
        [cell setVideoBlock:^{
            NSLog(@"Video call");
        }];
        return cell;
    } else if ([data[indexPath.section].cellType isEqual:@"updateContactHeaderCell"]) {
        UpdateContactHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"updateContactHeaderCell" forIndexPath: indexPath];
        [cell setSectionTitle: @"Danh bạ"];
        [cell setButtonTitle: @"CẬP NHẬP"];
        return cell;
    } else {
        // contacts
        ContactCell *cell = [tableView dequeueReusableCellWithIdentifier:@"contactCell" forIndexPath: indexPath];
        
        ContactEntity *contact = ((ContactGroupEntity *)data[indexPath.section].data).contacts[indexPath.row];
        
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
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (![data[section].cellType isEqual:@"contacts"] && ![data[section].cellType isEqual:@"onlineFriends"]) {
        return 1;
    } else {
        ContactGroupEntity *group = ((ContactGroupEntity *)data[section].data);
        return group.contacts.count;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return data.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return ((ContactGroupEntity *)loader.contactGroup[section]).header;
}

- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return @[@"",@"",@"",@"",@"",@"",@"C",@"H",@"L",@"N",@"T"];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // MARK: Check by section pleaseee
    return 60;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if ([data[section].cellType isEqual:@"friendRequest"]) {
        return [UIView alloc].init;
    } else if ([data[section].cellType isEqual:@"addFriendFromDevice"]) {
        return [UIView alloc].init;
    } else if ([data[section].cellType isEqual:@"closeFriends"]) {
        return [HeaderCell.alloc initWithTitle:@"Bạn thân"];
    } else if ([data[section].cellType isEqual:@"onlineFriends"]) {
        return [HeaderCell.alloc initWithTitle:((ContactGroupEntity *)data[section].data).header];
    } else if ([data[section].cellType isEqual:@"updateContactHeaderCell"]) {
        return [UIView alloc].init;
    } else {
        // contacts
        return [HeaderCell.alloc initWithTitle:((ContactGroupEntity *)data[section].data).header];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if ([data[section].cellType isEqual:@"friendRequest"]) {
        return BlankFooterCell.alloc.init;
    } else if ([data[section].cellType isEqual:@"addFriendFromDevice"]) {
        return BlankFooterCell.alloc.init;
    } else if ([data[section].cellType isEqual:@"closeFriends"]) {
        return BlankFooterCell.alloc.init;
    } else if ([data[section].cellType isEqual:@"onlineFriends"]) {
        return BlankFooterCell.alloc.init;
    } else if ([data[section].cellType isEqual:@"updateContactHeaderCell"]) {
        return BlankFooterCell.alloc.init;
    } else {
        // contacts
        ContactFooterCell *footer = [ContactFooterCell.alloc
                                     initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 20)];
        return footer;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([data[section].cellType isEqual:@"friendRequest"]) {
        return 0;
    } else if ([data[section].cellType isEqual:@"addFriendFromDevice"]) {
        return 0;
    } else if ([data[section].cellType isEqual:@"closeFriends"]) {
        return 30;
    } else if ([data[section].cellType isEqual:@"onlineFriends"]) {
        return 30;
    } else if ([data[section].cellType isEqual:@"updateContactHeaderCell"]) {
        return 0;
    } else {
        return 20;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if ([data[section].cellType isEqual:@"friendRequest"]) {
        return 8;
    } else if ([data[section].cellType isEqual:@"addFriendFromDevice"]) {
        return 8;
    } else if ([data[section].cellType isEqual:@"closeFriends"]) {
        return 8;
    } else if ([data[section].cellType isEqual:@"onlineFriends"]) {
        return 8;
    } else if ([data[section].cellType isEqual:@"updateContactHeaderCell"]) {
        return 0;
    } else {
        return 20;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

@end
