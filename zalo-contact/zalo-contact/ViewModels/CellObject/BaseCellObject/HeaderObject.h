//
//  HeaderObject.h
//  zalo-contact
//
//  Created by Thiện on 29/11/2021.
//

@import Foundation;
@import CoreGraphics;
NS_ASSUME_NONNULL_BEGIN

@interface HeaderObject : NSObject

@property(nonatomic, assign) Class headerClass;

- (instancetype)initWithHeaderClass:(Class)headerClass;
@end


#pragma mark - Protocol for updating cell

@protocol ZaloHeader

@required
- (void)setNeedsObject:(HeaderObject *)object;
+ (CGFloat)heightForHeaderWithObject:(HeaderObject *)object;

@end

NS_ASSUME_NONNULL_END
