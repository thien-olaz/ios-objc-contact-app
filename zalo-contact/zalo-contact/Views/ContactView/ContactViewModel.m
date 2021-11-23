//
//  ContactViewModel.m
//  zalo-contact
//
//  Created by Thiện on 23/11/2021.
//
#import "ContactViewModel.h"

@implementation ContactViewModel {
    ContactsLoader *loader;
}

- (instancetype)init {
    self = [super init];
    loader =  [[ContactsLoader alloc] init];
    [loader update];
    return self;
}


// MARK: UITableViewDataSource
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    ContactCell *cell = [tableView dequeueReusableCellWithIdentifier:@"contactCell" forIndexPath: indexPath];
    
    Contact *contact = ((ContactGroup *)loader.contactGroup[indexPath.section]).contacts[indexPath.row];
    
    [(ContactCell *)cell setNameWith: contact.fullName];
    [(ContactCell *)cell setSubtitleWith: contact.fullName];
    [(ContactCell *)cell setAvatarImageUrl: contact.imageUrl];
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    ContactGroup *group = (ContactGroup *)loader.contactGroup[section];
    return group.contacts.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return loader.contactGroup.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return ((ContactGroup *)loader.contactGroup[section]).header;
}

- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return @[@"C",@"H",@"L",@"N",@"T"];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // MARK: Check by section pleaseee
    return 60;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    ContactFooterCell *footer = [ContactFooterCell.alloc initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 0)];
    return footer;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 20;
}
@end
