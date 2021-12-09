//
//  UpdateContactObject.m
//  zalo-contact
//
//  Created by Thiện on 08/12/2021.
//

#import "UpdateContactObject.h"
#import "UpdateContactCell.h"

@implementation UpdateContactObject

- (instancetype)init {
    self = [super initWithCellClass:UpdateContactCell.class];
    return self;
}

- (instancetype)initWithTitle:(NSString *)title {
    self = self.init;
    self.title = title;    
    return self;
}

- (instancetype)initWithTitle:(NSString *)title andAction:(ActionBlock)action {
    self = [self initWithTitle:title];
    self.actionBlock = action;
    return self;
}

@end
