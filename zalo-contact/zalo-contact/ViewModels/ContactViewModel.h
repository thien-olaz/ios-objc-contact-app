//
//  ContactViewModel.h
//  zalo-contact
//
//  Created by Thiện on 23/11/2021.
//

#import <Foundation/Foundation.h>
#import "ContactViewModel.h"
#import "ContactsLoader.h"
#import "ContactCell.h"
#import "ContactFooterCell.h"
#import "HeaderCell.h"
#import "ActionCell.h"
#import "BlankFooterCell.h"
#import "UpdateContactHeaderCell.h"
#import "CellItem.h"
#import "CellFactory.h"
#import "ContactObject.h"
@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@interface ContactViewModel : NSObject<UITableViewDataSource, UITableViewDelegate>

@end

NS_ASSUME_NONNULL_END
