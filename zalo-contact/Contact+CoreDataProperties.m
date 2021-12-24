//
//  Contact+CoreDataProperties.m
//  zalo-contact
//
//  Created by Thiện on 24/12/2021.
//
//

#import "Contact+CoreDataProperties.h" 

@implementation Contact (CoreDataProperties)

+ (NSFetchRequest<Contact *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"Contact"];
}

- (void)applyPropertiesFromContactEntity:(ContactEntity *)contactEntity {
    self.accountId = contactEntity.accountId;
    self.lastName = contactEntity.lastName;
    self.firstName = contactEntity.firstName;
    self.fullName = contactEntity.fullName;
    self.phoneNumber = contactEntity.phoneNumber;
    self.email = contactEntity.email;
    self.header = contactEntity.header;
    self.subtitle = contactEntity.subtitle;
}

@dynamic accountId;
@dynamic email;
@dynamic firstName;
@dynamic fullName;
@dynamic header;
@dynamic lastName;
@dynamic phoneNumber;
@dynamic subtitle;

@end
