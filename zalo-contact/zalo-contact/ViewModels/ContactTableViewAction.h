//
//  ContactTableViewAction.h
//  zalo-contact
//
//  Created by Thiện on 29/11/2021.
//

#import <Foundation/Foundation.h>
@import UIKit;
#import "CellObject.h"
#import "ContactViewModel.h"
NS_ASSUME_NONNULL_BEGIN
typedef void (^TapBlock)(void);

@interface ContactTableViewAction : NSObject<UITableViewDelegate>

- (CellObject *)attachToObject:(CellObject *)object action:(TapBlock)tapped;

@end

NS_ASSUME_NONNULL_END
