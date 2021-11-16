//
//  FriendRequest.h
//  zalo-contact
//
//  Created by Thiện on 16/11/2021.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FriendRequest : NSObject

@property NSString *fistName;
@property NSString *lastName;

@property NSString *phoneNumber;
@property NSDate *receiveDate;

// MARK: - Todo
/// "Tìm kiếm số điện thoại" - "Muốn kết bạn" ... replace with enum later
@property NSString *requestType;

@property BOOL viewed;

@end

NS_ASSUME_NONNULL_END
