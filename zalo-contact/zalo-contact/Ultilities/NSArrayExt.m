//
//  NSArrayExt.m
//  zalo-contact
//
//  Created by Thiện on 07/12/2021.
//

#import "NSArrayExt.h"

@implementation NSArray (Common)

- (NSArray *)flatMap:(id (^)(id obj))block {
    NSMutableArray *mutableArray = [NSMutableArray new];
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        id _obj = block(obj);
        if ([_obj isKindOfClass:[NSArray class]]) {
            NSArray *_array = [_obj flatMap:block];
            [mutableArray addObjectsFromArray:_array];
            return;
        }
        [mutableArray addObject:_obj];
    }];
    return [mutableArray copy];
}

@end
