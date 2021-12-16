//
//  OnlineContactEntity.m
//  zalo-contact
//
//  Created by Thiện on 15/12/2021.
//

#import "OnlineContactEntity.h"

@implementation OnlineContactEntity

- (NSComparisonResult)compareTime:(OnlineContactEntity *)entity {
    NSComparisonResult res = [self.onlineTime compare:entity.onlineTime];
    if (res != NSOrderedSame) return res;
    return [self compare:entity];
}

@end
