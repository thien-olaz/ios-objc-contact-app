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
#import "ContactHeaderCell.h"
#import "FriendRequestsCell.h"
#import "GrayFooterCell.h"

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@interface ContactViewModel : NSObject<UITableViewDataSource, UITableViewDelegate>

@end

NS_ASSUME_NONNULL_END
