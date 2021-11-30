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


@protocol ZaloTableviewDataSource <NSObject>

@required

- (id)objectAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface ContactViewModel : NSObject<UITableViewDataSource, ZaloTableviewDataSource>

- (void)compileDatasource:(NSArray *)dataArray;

@end

