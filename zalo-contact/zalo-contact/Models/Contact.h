//
//  Contact.h
//  zalo-contact
//
//  Created by LAp14886 on 15/11/2021.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

//MARK: - rename - entity - model ...
@interface Contact : NSObject
- (id) initWithFirstName:(NSString *)firstName
                lastName:(NSString *)lastName
             phoneNumber:(NSString *)phoneNumber;

- (id) initWithFirstName:(NSString *)firstName
                lastName:(NSString *)lastName
    phoneNumber:(NSString *)phoneNumber
                imageUrl:(NSString *)url;

- (NSString *) header;
- (NSString *) fullName;
- (NSString * __nullable) imageUrl;

@end

NS_ASSUME_NONNULL_END
