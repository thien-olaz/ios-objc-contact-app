//
//  ContactViewModel.m
//  zalo-contact
//
//  Created by Thiện on 23/11/2021.
//
#import "ContactViewModel.h"
#import "SectionObject.h"
extern actionCellRepeatTime = 0;
@implementation ContactViewModel {
    
    NSMutableArray<SectionObject *> *sections;
    CellFactory *cellFactory;
}

- (instancetype)init {
    self = [super init];
    
    
    cellFactory = [CellFactory new];
    
    return self;
}
- (void)compileDatasource:(NSArray *)dataArray {
    NSMutableArray<SectionObject *>* sectionsArray = [NSMutableArray array];
    //    NSMutableArray* tempSectionRows = nil;
    //    BOOL inSection = NO;
    SectionObject *currentSection = nil;
    
    for (id object in dataArray) {
        if ([object isKindOfClass:CellObject.class]) {
            if (currentSection) {
                [currentSection addRowObject:(CellObject *)object];
            }
        } else if ([object isKindOfClass:HeaderObject.class]) {
            if (currentSection) {
                [sectionsArray addObject:currentSection];
            }
            currentSection = SectionObject.new;
            currentSection.header = (HeaderObject *)object;
        } else if ([object isKindOfClass:FooterObject.class]) {
            if (currentSection) {
                currentSection.footer = (FooterObject *)object;
            }
        }
        
    }
    
    if (currentSection) [sectionsArray addObject:currentSection];
    
    sections = sectionsArray;
}

- (id)objectAtIndexPath:(NSIndexPath *)indexPath {
    SectionObject *section = sections[indexPath.section];
    return [section getObjectForRow:indexPath.row];
}

// MARK: UITableViewDataSource

// MARK: Need to turn all of this to use switch or enum base to manage the cell
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    CellObject *object = [self objectAtIndexPath:indexPath];
    //    UITableViewCell *cell = [cellFactory cellForTableView:tableView
    //                                              atIndexPath:indexPath withObject:( id)
    return [cellFactory cellForTableView:tableView atIndexPath:indexPath withObject:object];
    //    if ([data[indexPath.section].cellType isEqual:@"friendRequest"]) {
    //        ActionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"actionCell"];
    //
    //        if (nil == cell) {
    //          UITableViewCellStyle style = UITableViewCellStyleDefault;
    //          cell = [[ActionCell alloc] initWithStyle:style reuseIdentifier:@"actionCell"];
    //            NSLog(@"Create new action cell 1");
    //        } else {
    //            NSLog(@"Reuse action cell 1");
    //        }
    //
    //        [cell setTitle:@"Lời mời kết bạn"];
    //        [cell setIconImage:[UIImage imageNamed:@"ct_people"]];
    //        [cell setBlock:^{
    //            NSLog(@"Perform present view controller here!");
    //        }];
    //        return cell;
    //    } else if ([data[indexPath.section].cellType isEqual:@"addFriendFromDevice"]) {
    //        ActionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"actionCell"];
    //
    //        if (nil == cell) {
    //          UITableViewCellStyle style = UITableViewCellStyleDefault;
    //          cell = [[ActionCell alloc] initWithStyle:style reuseIdentifier:@"actionCell"];
    //            NSLog(@"Create new action cell 2");
    //        } else {
    //            NSLog(@"Reuse action cell 2");
    //        }
    //
    //        [cell setTitle:@"Thêm bạn từ danh bạ máy"];
    //        [cell setIconImage:[UIImage imageNamed:@"ct_people"]];
    //        [cell setBlock:^{
    //            NSLog(@"Perform present view controller here!");
    //        }];
    //        return cell;
    //    } else if ([data[indexPath.section].cellType isEqual:@"closeFriends"]) {
    //        ActionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"actionCell"];
    //
    //        if (nil == cell) {
    //          UITableViewCellStyle style = UITableViewCellStyleDefault;
    //          cell = [[ActionCell alloc] initWithStyle:style reuseIdentifier:@"actionCell"];
    //            NSLog(@"Create new action cell 3");
    //        } else {
    //            NSLog(@"Reuse action cell 3");
    //        }
    //
    //        [cell setTitle:@"Chọn bạn thường liên lạc"];
    //        [cell setIconImage:[UIImage imageNamed:@"ct_plus"]];
    //        [cell setTitleTintColor:UIColor.systemBlueColor];
    //        [cell setBlock:^{
    //            NSLog(@"Perform present view controller here!");
    //        }];
    //        return cell;
    //    } else if ([data[indexPath.section].cellType isEqual:@"onlineFriends"]) {
    //        // contacts
    //        ContactCell *cell = [tableView dequeueReusableCellWithIdentifier:@"contactCell"];
    //        if (nil == cell) {
    //          UITableViewCellStyle style = UITableViewCellStyleDefault;
    //          cell = [[ContactCell alloc] initWithStyle:style reuseIdentifier:@"contactCell"];
    //            NSLog(@"Create new friend %d", actionCellRepeatTime);
    //            actionCellRepeatTime += 1;
    //        } else {
    //            NSLog(@"Reuse friend %d", actionCellRepeatTime);
    //        }
    //        ContactEntity *contact = ((ContactGroupEntity *)data[indexPath.section].data).contacts[indexPath.row];
    //
    //        [cell setNameWith: contact.fullName];
    //        [cell setSubtitleWith: contact.fullName];
    //        [cell setAvatarImageUrl: contact.imageUrl];
    //        [cell setOnline];
    //        [cell setPhoneBlock:^{
    //            NSLog(@"Phone call");
    //        }];
    //        [cell setVideoBlock:^{
    //            NSLog(@"Video call");
    //        }];
    //        return cell;
    //    } else if ([data[indexPath.section].cellType isEqual:@"updateContactHeaderCell"]) {
    //        UpdateContactHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"updateContactHeaderCell"];
    //        if (nil == cell) {
    //          UITableViewCellStyle style = UITableViewCellStyleDefault;
    //          cell = [[UpdateContactHeaderCell alloc] initWithStyle:style reuseIdentifier:@"updateContactHeaderCell"];
    ////            cell cellClass
    //            NSLog(@"Create new updateContactHeaderCell 1");
    //        } else {
    //            NSLog(@"Reuse updateContactHeaderCell 1");
    //        }
    //
    //        [cell setSectionTitle: @"Danh bạ"];
    //        [cell setButtonTitle: @"CẬP NHẬP"];
    //        return cell;
    //    } else {
    
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return sections[section].numberOfRowsInSection;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return sections.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"123";
}

// Ref qua section
- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return @[@"",@"",@"",@"",@"",@"",@"C",@"H",@"L",@"N",@"T"];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // MARK: Check by section pleaseee
    return 60;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    //    return [cellFactory headerForTableView:tableView inSection:section withObject:[HeaderObject.alloc init]];
    
    
    return [HeaderCell.alloc initWithTitle:@"title"];
    
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    //    return [cellFactory footerForTableView:tableView inSection:section withObject:[FooterObject.alloc init]];
    //        return BlankFooterCell.alloc.init;
    
    // contacts
    ContactFooterCell *footer = [ContactFooterCell.alloc
                                 initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 20)];
    return footer;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20;
    //    if ([data[section].cellType isEqual:@"friendRequest"]) {
    //        return 0;
    //    } else if ([data[section].cellType isEqual:@"addFriendFromDevice"]) {
    //        return 0;
    //    } else if ([data[section].cellType isEqual:@"closeFriends"]) {
    //        return 30;
    //    } else if ([data[section].cellType isEqual:@"onlineFriends"]) {
    //        return 30;
    //    } else if ([data[section].cellType isEqual:@"updateContactHeaderCell"]) {
    //        return 0;
    //    } else {
    //        return 20;
    //    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 20;
    //    if ([data[section].cellType isEqual:@"friendRequest"]) {
    //        return 8;
    //    } else if ([data[section].cellType isEqual:@"addFriendFromDevice"]) {
    //        return 8;
    //    } else if ([data[section].cellType isEqual:@"closeFriends"]) {
    //        return 8;
    //    } else if ([data[section].cellType isEqual:@"onlineFriends"]) {
    //        return 8;
    //    } else if ([data[section].cellType isEqual:@"updateContactHeaderCell"]) {
    //        return 0;
    //    } else {
    //        return 20;
    //    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

@end
