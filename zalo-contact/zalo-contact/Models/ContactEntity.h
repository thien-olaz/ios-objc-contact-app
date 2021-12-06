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
- (id)initWithFirstName:(NSString *)firstName
               lastName:(NSString *)lastName
            phoneNumber:(NSString *)phoneNumber;

- (id)initWithFirstName:(NSString *)firstName
               lastName:(NSString *)lastName
            phoneNumber:(NSString *)phoneNumber
               imageUrl:(NSString *)url;

- (NSString *)header;
- (NSString *)fullName;
- (NSString *)lastName;
- (NSString * __nullable)imageUrl;
- (id<NSObject>)diffIdentifier;
- (BOOL)isEqualToDiffableObject:(nullable id<IGListDiffable>)object;
- (NSComparisonResult)compare:(ContactEntity *)entity;
+ (NSArray<ContactEntity*>*) insertionSort:(NSArray<ContactEntity*> *)array;
@end

NS_ASSUME_NONNULL_END
