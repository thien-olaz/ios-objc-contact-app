//
//  CellItem.h
//  zalo-contact
//
//  Created by Thiện on 25/11/2021.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CellItem : NSObject

@property NSString *cellType;
@property NSObject *data;

+ (instancetype)initWithType:(NSString *)type data:(NSObject *)data;

@end

NS_ASSUME_NONNULL_END
