//
//  ContactEntity.h
//  zalo-contact
//
//  Created by LAp14886 on 15/11/2021.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ContactEntity : NSObject

@property (readonly) NSString *accountId;

@property NSString *header;
@property NSString *subtitle;
@property NSString *email;
@property (readonly) NSString *firstName;
@property (readonly) NSString *lastName;
@property (readonly) NSString *fullName;
@property (readonly) NSUInteger diffHash;
@property (nonatomic) NSString *phoneNumber;
@property (nullable) NSString *imageUrl;

- (id)initWithAccountId:(NSString *)Id
              firstName:(NSString *)fname
               lastName:(NSString *)lname
            phoneNumber:(NSString *)phoneNumber
               subtitle:(nullable NSString *)subtitle
                  email:(NSString *)email;

- (NSString * __nullable)imageUrl;

- (NSComparisonResult)compare:(ContactEntity *)entity;
- (NSComparisonResult)compareToSearch:(ContactEntity *)entity;
- (BOOL)isEqual:(id)object;

// MARK: Class method
+ (NSArray<ContactEntity*>*) insertionSort:(NSArray<ContactEntity*> *)array;
+ (NSString *)headerFromFirstName:(nullable NSString *)firstName andLastName:(nullable NSString *)lastName;
+ (NSArray<ContactEntity *> *)mergeArray:(NSArray<ContactEntity *> *)arr1 withArray:(NSArray<ContactEntity *> *)arr2;
+ (NSMutableDictionary<NSString*, NSArray<ContactEntity*>*> *)mergeContactDict:(NSMutableDictionary<NSString*, NSArray<ContactEntity*>*> *)incommingDict
                                                                        toDict:(NSMutableDictionary<NSString*, NSArray<ContactEntity*>*> *)dict2;
@end

NS_ASSUME_NONNULL_END
