//
//  ContactViewModel.m
//  zalo-contact
//
//  Created by Thiện on 23/11/2021.
//
#import "ContactTableViewDataSource.h"
#import "SectionObject.h"

@implementation ContactTableViewDataSource {
    NSMutableArray<SectionObject *> *sections;
    NSMutableArray<NSString *> *sectionTitles;
    NSMutableArray<NSNumber *> *remapedSectionIndex;
    
    CellFactory *cellFactory;
}

- (instancetype)init {
    self = [super init];
    cellFactory = [CellFactory new];
    
    return self;
}

- (void)compileDatasource:(NSArray *)dataArray {
    NSMutableArray<SectionObject *>* sectionsArray = [NSMutableArray array];
    
    SectionObject *currentSection = nil;
    
    // MARK: - remap section title and index when compile
    sectionTitles = NSMutableArray.array;
    remapedSectionIndex = NSMutableArray.array;
    
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
            
            if (currentSection.header.letterTitle) {
                [sectionTitles addObject:currentSection.header.letterTitle];
                [remapedSectionIndex addObject: [NSNumber numberWithUnsignedLong:sectionsArray.count]];
            }
            
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

- (NSIndexPath *)indexPathForObject:(id)object {
    if (nil == object) {
        return nil;
    }
    
    // Find exact section
    for (NSUInteger sectionIndex = 3; sectionIndex < [sections count]; sectionIndex++) {
        if (![[object header] isEqual: sections[sectionIndex].header]) continue;
        return [self binarySearch:object inSection:sectionIndex];
    }
    
    return nil;
}

- (NSIndexPath * _Nullable)indexPathForContactEntity:(ContactEntity *)contact {    
    if (contact) {
        ContactObject *object = [ContactObject.alloc initWithContactEntity:contact];
        for (NSUInteger sectionIndex = 3; sectionIndex < [sections count]; sectionIndex++) {
            if (![[contact header] isEqualToString: sections[sectionIndex].header.letterTitle]) continue;
            return [self binarySearch:object inSection:sectionIndex];
        }
    }
    return nil;
}

- (NSIndexPath * _Nullable)indexPathForPhoneNumber:(NSString *)phoneNumber {
    ContactEntity *contact = [ZaloContactService.sharedInstance getContactsWithPhoneNumber:phoneNumber];
    
    if (contact) {
        ContactObject *object = [ContactObject.alloc initWithContactEntity:contact];
        for (NSUInteger sectionIndex = 3; sectionIndex < [sections count]; sectionIndex++) {
            if (![[contact header] isEqualToString: sections[sectionIndex].header.letterTitle]) continue;
            return [self binarySearch:object inSection:sectionIndex];
        }
    }
    return nil;
}


//MARK: - time complexity - Olog(n)
- (NSIndexPath *)binarySearch:(id)object inSection:(unsigned long)sectionIndex {
    NSArray* rows = [[sections objectAtIndex:sectionIndex] rows];
    int l = 0, r = rows.count - 1;
    while (l <= r) {
        int rowIndex = l + (r - l) / 2;
        NSComparisonResult res = [object compare:[rows objectAtIndex:rowIndex]];
        
        if (res == NSOrderedSame)
            return [NSIndexPath indexPathForRow:rowIndex inSection:sectionIndex];
        
        if (res == NSOrderedDescending)
            l = rowIndex + 1;
        else
            r = rowIndex - 1;
    }
    return nil;
}

- (nullable HeaderObject *)headerObjectInSection:(NSInteger)index {
    SectionObject *section = sections[index];
    return section.header;
}

- (nullable FooterObject *)footerObjectInSection:(NSInteger)index {
    SectionObject *section = sections[index];
    return section.footer;
}


// MARK: UITableViewDataSource

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    CellObject *object = [self objectAtIndexPath:indexPath];
    return [cellFactory cellForTableView:tableView atIndexPath:indexPath withObject:object];
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return sections[section].numberOfRowsInSection;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return sections.count;
}

// Ref qua section
- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return sectionTitles;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return remapedSectionIndex[index].intValue;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CellObject *object = [self objectAtIndexPath: indexPath];
    return [cellFactory tableView:tableView heightForRowWithObject:object];
}
    
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

@end
