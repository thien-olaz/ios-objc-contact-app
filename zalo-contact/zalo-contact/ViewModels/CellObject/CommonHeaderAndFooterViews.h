//
//  CommonHeaderAndFooterViews.h
//  zalo-contact
//
//  Created by Thiện on 30/11/2021.
//

@import Foundation;
@import UIKit;
#import "FooterObject.h"
#import "HeaderObject.h"
#import "BlankFooterCell.h"
#import "HeaderCell.h"
#import "NullHeaderView.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark - BlankFooterObject
@interface BlankFooterObject : FooterObject

-(instancetype)init;

@end


#pragma mark - ShortHeaderObject
@interface ShortHeaderObject : HeaderObject

@property NSString *title;
- (instancetype)initWithTitle:(NSString *)title;
- (instancetype)init;

@end

#pragma mark - NullHeaderObject
@interface NullHeaderObject : HeaderObject

@end

NS_ASSUME_NONNULL_END
