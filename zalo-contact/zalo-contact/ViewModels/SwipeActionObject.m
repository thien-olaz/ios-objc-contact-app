//
//  SwipeActionObject.m
//  zalo-contact
//
//  Created by Thiện on 08/12/2021.
//

#import "SwipeActionObject.h"

@implementation SwipeActionObject

- (instancetype)initWithTile:(NSString *)title color:(UIColor *)color actionType:(SwipeActionType)type {
    self = super.init;
    _title = title;
    _color = color;
    _actionType = type;
    return self;
}

@end
