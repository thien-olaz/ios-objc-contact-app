//
//  Contact+CoreDataProperties.h
//  zalo-contact
//
//  Created by Thiện on 24/12/2021.
//
//

#import "Contact+CoreDataClass.h"
#import "ContactEntity.h"

NS_ASSUME_NONNULL_BEGIN

@interface Contact (CoreDataProperties)

+ (NSFetchRequest<Contact *> *)fetchRequest NS_SWIFT_NAME(fetchRequest());

- (void)applyPropertiesFromContactEntity:(ContactEntity *)contactEntity;

@property (nullable, nonatomic, copy) NSString *accountId;
@property (nullable, nonatomic, copy) NSString *email;
@property (nullable, nonatomic, copy) NSString *firstName;
@property (nullable, nonatomic, copy) NSString *fullName;
@property (nullable, nonatomic, copy) NSString *header;
@property (nullable, nonatomic, copy) NSString *lastName;
@property (nullable, nonatomic, copy) NSString *phoneNumber;
@property (nullable, nonatomic, copy) NSString *subtitle;

@end

NS_ASSUME_NONNULL_END
