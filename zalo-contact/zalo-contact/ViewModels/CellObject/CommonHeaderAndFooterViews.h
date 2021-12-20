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
#import "BlankFooterView.h"
#import "HeaderView.h"
#import "NullHeaderView.h"
#import "ActionHeaderView.h"
#import "ContactFooterView.h"
#import "CellObject.h"
#import "NullFooterView.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark - BlankFooterObject
@interface BlankFooterObject : FooterObject

- (instancetype)init;

@end

#pragma mark - ContactFooterObject
@interface ContactFooterObject : FooterObject

- (instancetype)init;

@end

#pragma mark - ShortHeaderObject
@interface ShortHeaderObject : HeaderObject

@property NSString *title;
- (instancetype)initWithTitle:(NSString *)title;
- (instancetype)init;
- (instancetype)initWithTitle:(NSString *)title andTitleLetter:(NSString *)letter;

@end

#pragma mark - NullHeaderObject
@interface NullHeaderObject : HeaderObject

- (instancetype)initWithLeter:(NSString *)letter;
    
@end

#pragma mark - NullFooterObject
@interface NullFooterObject: FooterObject

@end

#pragma mark - Action header
typedef void (^ActionBlock)(void);
@interface ActionHeaderObject : HeaderObject

@property (copy) ActionBlock block;
@property NSString *title;
@property NSString *buttonTitle;

- (instancetype)initWithTitle:(NSString *)title andButtonTitle:(NSString *)btnTitle;
    
@end

NS_ASSUME_NONNULL_END
