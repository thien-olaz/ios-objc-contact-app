//
//  NSObject_ListDiffable.m
//  zalo-contact
//
//  Created by LAp14886 on 16/11/2021.
//

#import "NSObject_ListDiffable.h"

@implementation NSObject (IGListDiffable)

- (id<NSObject>)diffIdentifier {
    return self;
}

- (BOOL)isEqualToDiffableObject:(id<IGListDiffable>)object {
    return [self isEqual:object];
}

@end
