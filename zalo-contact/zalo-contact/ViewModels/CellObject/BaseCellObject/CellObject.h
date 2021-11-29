//
//  CellObject.h
//  zalo-contact
//
//  Created by Thiện on 29/11/2021.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Cellobject - base

@interface CellObject : NSObject

@property(nonatomic, assign) Class cellClass;

- (instancetype)initWithCellClass:(Class)cellClass;

@end

#pragma mark - Protocol for updating cell
@protocol ZaloCell

@required
- (void)setNeedsObject:(CellObject *)object;

@end

NS_ASSUME_NONNULL_END
