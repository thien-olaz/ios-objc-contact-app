//
//  Contact.h
//  zalo-contact
//
//  Created by LAp14886 on 15/11/2021.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Contact : NSObject

@property NSString *name;
@property NSString *phoneNumber;

- (id) initWith:(NSString *)name phoneNumber:(NSString *)phoneNumber;
                                              
@end

NS_ASSUME_NONNULL_END
