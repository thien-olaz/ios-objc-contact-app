//
//  ContactDataController.h
//  zalo-contact
//
//  Created by Thiện on 24/12/2021.
//

#import <Foundation/Foundation.h>
@import CoreData;
#import "ContactEntity.h"
#import "CoreDataContactEntityAdapter.h"

NS_ASSUME_NONNULL_BEGIN
typedef void (^CallbackBlock) (void);

@interface ContactDataController : NSObject

+ (ContactDataController *)sharedInstance;

@property NSManagedObjectContext *managedObjectContext;

- (id)initWithCompletionBlock:(CallbackBlock)callback;

- (void)saveContactArrayToData:(NSArray<ContactEntity *> *)contacts;
- (void)addContactToData:(ContactEntity *)contact;
- (void)updateContactInData:(ContactEntity *)contact;
- (void)deleteContactFromData:(NSString *)accountId;

- (NSArray<ContactEntity *>*)getSavedData;

@end

NS_ASSUME_NONNULL_END
