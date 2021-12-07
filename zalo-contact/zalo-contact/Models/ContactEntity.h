//
//  ContactEntity.h
//  zalo-contact
//
//  Created by LAp14886 on 15/11/2021.
//

#import <Foundation/Foundation.h>
@import IGListKit;
NS_ASSUME_NONNULL_BEGIN

@interface ContactEntity : NSObject<NSSecureCoding, IGListDiffable>

@property NSString *fullName;
@property NSString *header;
@property NSString *subtitle;

- (id)initWithFirstName:(NSString *)firstName
               lastName:(NSString *)lastName
            phoneNumber:(NSString *)phoneNumber
               subtitle:(nullable NSString *)subtitle;

- (id)initWithFirstName:(NSString *)firstName
               lastName:(NSString *)lastName
            phoneNumber:(NSString *)phoneNumber
               imageUrl:(NSString *)url
               subtitle:(nullable NSString *)subtitle;

- (NSString *)lastName;
- (NSString *)phoneNumber;

- (NSString * __nullable)imageUrl;
- (id<NSObject>)diffIdentifier;
- (BOOL)isEqualToDiffableObject:(nullable id<IGListDiffable>)object;
- (NSComparisonResult)compare:(ContactEntity *)entity;
+ (NSArray<ContactEntity*>*) insertionSort:(NSArray<ContactEntity*> *)array;
+ (NSString *)headerFromFirstName:(nullable NSString *)firstName andLastName:(nullable NSString *)lastName;

@end

NS_ASSUME_NONNULL_END
