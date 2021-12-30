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

@protocol ContactDataErrorManager <NSObject>

- (void)onStorageError:(NSArray*)failedToSaveContactArray;

@end

@interface ContactDataManager : NSObject

+ (ContactDataManager *)sharedInstance;

@property id<ContactDataErrorManager> errorManager;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (id)initWithCompletionBlock:(CallbackBlock)callback;

- (void)addContactToData:(ContactEntity *)contact;
- (void)updateContactInData:(ContactEntity *)contact;
- (void)deleteContactFromData:(NSString *)accountId;

- (NSArray<ContactEntity *>*)getSavedData;
- (void)save;

@end

NS_ASSUME_NONNULL_END
