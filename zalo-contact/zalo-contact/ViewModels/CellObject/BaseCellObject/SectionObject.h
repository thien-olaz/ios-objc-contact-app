//
//  SectionObject.h
//  zalo-contact
//
//  Created by Thiện on 30/11/2021.
//

#import <Foundation/Foundation.h>
#import "HeaderObject.h"
#import "FooterObject.h"
#import "CellObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface SectionObject : NSObject

@property (nullable) HeaderObject *header;
@property (nullable) FooterObject *footer;
@property (nullable) NSMutableArray<CellObject *> *rows;

- (void)addRowObject:(CellObject *)object;
- (CellObject *)getObjectForRow:(NSInteger)index;
- (NSInteger)numberOfRowsInSection;

@end

NS_ASSUME_NONNULL_END
