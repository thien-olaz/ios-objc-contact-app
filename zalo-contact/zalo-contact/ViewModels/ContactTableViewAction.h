//
//  ContactTableViewAction.h
//  zalo-contact
//
//  Created by Thiện on 29/11/2021.
//

@import UIKit;
@import Foundation;
#import "CellObject.h"
#import "ContactTableViewDataSource.h"
#import "HeaderFooterFactory.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^TapBlock)(void);

@interface ContactTableViewAction : NSObject<UITableViewDelegate>

- (CellObject *)attachToObject:(CellObject *)object action:(TapBlock)tapped;

@end

NS_ASSUME_NONNULL_END
