//
//  FooterObject.h
//  zalo-contact
//
//  Created by Thiện on 29/11/2021.
//

@import Foundation;
@import CoreGraphics;
NS_ASSUME_NONNULL_BEGIN

@interface FooterObject : NSObject

@property(nonatomic, assign) Class footerClass;

- (instancetype)initWithFooterClass:(Class)footerClass;

@end

#pragma mark - Protocol for updating cell

@protocol ZaloFooter

@required
- (void)setNeedsObject:(FooterObject *)object;
+ (CGFloat)heightForFooterWithObject:(FooterObject *)object;

@end

NS_ASSUME_NONNULL_END
