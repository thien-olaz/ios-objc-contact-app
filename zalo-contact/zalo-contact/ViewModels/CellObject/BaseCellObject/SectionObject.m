//
//  SectionObject.m
//  zalo-contact
//
//  Created by Thiện on 30/11/2021.
//

#import "SectionObject.h"


@implementation SectionObject

    
- (void)addRowObject:(CellObject *)object {
    if (!self.rows) self.rows = [NSMutableArray array];
    [self.rows addObject:object];
}


- (CellObject *)getObjectForRow:(NSInteger)index {
    return self.rows[index];
}

- (NSInteger)numberOfRowsInSection {
    if (self.rows) return self.rows.count;
    return 0;
}

@end
