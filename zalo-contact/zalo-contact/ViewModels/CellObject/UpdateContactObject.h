//
//  UpdateContactObject.h
//  zalo-contact
//
//  Created by Thiện on 08/12/2021.
//

#import "CellObject.h"
@import UIKit;

NS_ASSUME_NONNULL_BEGIN
typedef void(^ActionBlock) (void);

@interface UpdateContactObject : CellObject

@property NSString *title;
@property (copy) ActionBlock actionBlock;

- (instancetype)initWithTitle:(NSString *)title;
- (instancetype)initWithTitle:(NSString *)title andAction:(ActionBlock)action;

@end

NS_ASSUME_NONNULL_END
