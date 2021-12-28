//
//  ContactDataController.m
//  zalo-contact
//
//  Created by Thiện on 24/12/2021.
//

#import "ContactDataManager.h"
#import "Contact+CoreDataClass.h"
#import "GCDThrottle.h"

// ưu nhược
// migrate data - field mới - sau
#define LOG(str) //NSLog(@"💾 ContactDataController : %@", str);
#define LOG2(str1, str2) //NSLog(@"🌍 ContactDataManager : %@", [NSString stringWithFormat:str1, str2])
@interface ContactDataManager ()

@property (strong, nonatomic) dispatch_queue_t contactCoreDataQueue;
@property (strong, nonatomic) NSMutableDictionary<NSString *, Contact *> *storeContactDict;

@end

@implementation ContactDataManager

static ContactDataManager *sharedInstance = nil;

+ (ContactDataManager *)sharedInstance {
    @synchronized([ContactDataManager class]) {
        if (!sharedInstance)
            sharedInstance = [[self alloc] initWithCompletionBlock:^{}];
        return sharedInstance;
    }
    return nil;
}

- (id)init {
    self = [super init];
    self.storeContactDict = [NSMutableDictionary new];
    dispatch_queue_attr_t qos = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_USER_INITIATED, -1);
    _contactCoreDataQueue = dispatch_queue_create("_contactCoreDataQueue", qos);
    return self;
}

- (id)initWithCompletionBlock:(CallbackBlock)callback;
{
    self = [self init];
    if (!self) return nil;
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"contactModel" withExtension:@"momd"];
    NSAssert(modelURL, @"Failed to locate momd bundle in application");
    
    NSManagedObjectModel *mom = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    NSAssert(mom, @"Failed to initialize mom from URL: %@", modelURL);
    
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    
    NSManagedObjectContext *moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [moc setPersistentStoreCoordinator:coordinator];
    [self setManagedObjectContext:moc];
    
    DISPATCH_ASYNC_IF_NOT_IN_QUEUE(GLOBAL_QUEUE, ^{
        NSPersistentStoreCoordinator *psc = [[self managedObjectContext] persistentStoreCoordinator];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSURL *documentsURL = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        NSURL *storeURL = [documentsURL URLByAppendingPathComponent:@"DataModel.sqlite"];
        
        NSError *error = nil;
        NSPersistentStore *store = [psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error];
        if (!store) {
            NSLog(@"Failed to initalize persistent store: %@\n%@", [error localizedDescription], [error userInfo]);
            abort();
        }
        if (!callback) {
            return;
        }
        dispatch_sync(dispatch_get_main_queue(), ^{
            callback();
        });
    });
    return self;
}

- (void)throttleSave {
    __weak typeof(self) weakSelf = self;
    dispatch_throttle_by_type(1, GCDThrottleTypeInvokeAndIgnore, ^{
        [weakSelf save];
    });
}

- (void)save {
    [self.managedObjectContext save:NULL];
}

- (void)deleteWholeTable {
    NSFetchRequest *request = [Contact fetchRequest];
    NSBatchDeleteRequest *delete = [[NSBatchDeleteRequest alloc] initWithFetchRequest:request];
    [self.managedObjectContext executeRequest:delete error:NULL];
    LOG(@"Deleted all contacts");
}

- (void)saveContactArrayToData:(NSArray<ContactEntity *> *)contacts {
    // delete old dadta
    [self deleteWholeTable];
    //add new data
    for (ContactEntity *contact in contacts) {
        Contact *ct = (Contact *)[NSEntityDescription insertNewObjectForEntityForName:@"Contact" inManagedObjectContext:self.managedObjectContext];
        [ct applyPropertiesFromContactEntity:contact];
        [self.storeContactDict setObject:ct forKey:ct.accountId];
    }
    
    [self throttleSave];
    LOG(@"Added new contact array");
}

- (void)addContactToData:(ContactEntity *)contact {
    Contact *ct = (Contact *)[NSEntityDescription insertNewObjectForEntityForName:@"Contact" inManagedObjectContext:self.managedObjectContext];
    [ct applyPropertiesFromContactEntity:contact];
    [self.storeContactDict setObject:ct forKey:ct.accountId];
    [self throttleSave];
    LOG2(@"Add contact %@", contact.accountId);
}

- (void)updateContactInData:(ContactEntity *)contact {
    Contact *contactToUpdate = [self.storeContactDict objectForKey:contact.accountId];
    [contactToUpdate applyPropertiesFromContactEntity:contact];
    [self throttleSave];
    LOG2(@"Updated contact %@", contact.accountId);
}

- (void)deleteContactFromData:(NSString *)accountId {
    Contact *contactToDelete = [self.storeContactDict objectForKey:accountId];
    if (contactToDelete) [self.managedObjectContext deleteObject:contactToDelete];
    [self throttleSave];
    LOG2(@"Removed contact %@", accountId);
}

- (NSArray<ContactEntity *>*)getSavedData {
    [self.storeContactDict removeAllObjects];
    NSMutableArray<ContactEntity*>* contactEntity = [NSMutableArray new];
    
    NSArray<Contact*>* objects = [self.managedObjectContext executeFetchRequest:Contact.fetchRequest error:NULL];
    
    for (Contact *contact in objects) {
        CoreDataContactEntityAdapter *convertedContact = [[CoreDataContactEntityAdapter alloc] initWithContact:contact];
        [contactEntity addObject:convertedContact];
        [self.storeContactDict setObject:contact forKey:contact.accountId];
    }
    
    return contactEntity;
}

- (void)logsAllSavedContact {
    LOG(@"All data");
//    for (Contact *ct in self.storeContactDict.allValues) {
//        LOG(ct.fullName);
//    }
}

@end
