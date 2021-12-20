//
//  ContactChangeEntity.h
//  zalo-contact
//
//  Created by Thiện on 20/12/2021.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ChangeFootprint : NSObject

@property NSString *accountId;
@property NSDate *date;

+ (instancetype)initChangeBy:(NSString *)accountId;

- (instancetype)initWithAccountId:(NSString *)accountId andUpdateTime:(NSDate *)date;
- (BOOL)isEqual:(id)object;
- (NSUInteger)hash;

@end

NS_ASSUME_NONNULL_END
