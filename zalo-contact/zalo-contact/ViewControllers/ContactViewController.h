//
//  ContactViewController.h
//  zalo-contact
//
//  Created by LAp14886 on 15/11/2021.
//

@import UIKit;
@import CoreGraphics;
#import "ContactViewController.h"
#import "ContactEntity.h"
#import "ContactTableViewDataSource.h"
#import "ContactStateProtocol.h"
#import "ContactTabViewModel.h"
#import "OnlineTabViewModel.h"


NS_ASSUME_NONNULL_BEGIN

@interface ContactViewController : UIViewController<ContextProtocol>

- (id)initWithViewModel:(ContactTableViewDataSource *)vm;

@end

NS_ASSUME_NONNULL_END
