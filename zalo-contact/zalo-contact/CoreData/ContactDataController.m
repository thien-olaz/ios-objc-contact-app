//
//  ContactDataController.m
//  zalo-contact
//
//  Created by Thiện on 24/12/2021.
//

#import "ContactDataController.h"
#import "Contact+CoreDataClass.h"

#define LOG(str) NSLog(@"💾 ContactDataController : %@", str);
@interface ContactDataController ()

@property dispatch_queue_t contactCoreDataQueue;
@property NSMutableDictionary<NSString *, Contact *> *storeContactDict;

@end

@implementation ContactDataController

static ContactDataController *sharedInstance = nil;

+ (ContactDataController *)sharedInstance {
    @synchronized([ContactDataController class]) {
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
    
    NSManagedObjectContext *moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [moc setPersistentStoreCoordinator:coordinator];
    [self setManagedObjectContext:moc];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSPersistentStoreCoordinator *psc = [[self managedObjectContext] persistentStoreCoordinator];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSURL *documentsURL = [[fileManager URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
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
    for (ContactEntity *contact in contacts) [self addContactToData:contact];
    LOG(@"Added new contact array");
}

- (void)addContactToData:(ContactEntity *)contact {
    Contact *ct = (Contact *)[NSEntityDescription insertNewObjectForEntityForName:@"Contact" inManagedObjectContext:self.managedObjectContext];
    [ct applyPropertiesFromContactEntity:contact];
    [self.storeContactDict setObject:ct forKey:ct.accountId];
    [self.managedObjectContext save:NULL];
    LOG(@"Added new contact");
}

- (void)updateContactInData:(ContactEntity *)contact {
    Contact *contactToUpdate = [self.storeContactDict objectForKey:contact.accountId];
    [contactToUpdate applyPropertiesFromContactEntity:contact];
    [self.managedObjectContext save:NULL];
    LOG(@"Updated contact");
}

- (void)deleteContactFromData:(NSString *)accountId {
    Contact *contactToDelete = [self.storeContactDict objectForKey:accountId];
    if (contactToDelete) [self.managedObjectContext deleteObject:contactToDelete];
    [self.managedObjectContext save:NULL];
    LOG(@"Removed contact");
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
    for (Contact *ct in self.storeContactDict.allValues) {
        LOG(ct.fullName);
    }
}

@end
