//
//  Contact.h
//  zalo-contact
//
//  Created by LAp14886 on 15/11/2021.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Contact : NSObject
@property NSString *header;
- (id) initWithFirstName:(NSString *)firstName
                lastName:(NSString *)lastName
             phoneNumber:(NSString *)phoneNumber;

- (NSString *) fullName;

@end

NS_ASSUME_NONNULL_END
