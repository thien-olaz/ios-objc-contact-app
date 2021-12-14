//
//  ZaloContactService.h
//  zalo-contact
//
//  Created by Thiện on 06/12/2021.
//

#import <Foundation/Foundation.h>
#import "MockAPIService.h"

NS_ASSUME_NONNULL_BEGIN

typedef NSMutableArray<ContactEntity *> ContactEntityArray;
typedef NSMutableDictionary<NSString *, NSMutableArray<ContactEntity *>*> ContactDictionary;

@protocol ZaloContactEventListener <NSObject>
- (void)onLoadSavedDataComplete:(ContactDictionary *)loadedData;
- (void)onReceiveNewList;
- (void)onAddContact:(ContactEntity *)contact;
- (void)onDeleteContact:(ContactEntity *)contact;
- (void)onUpdateContact:(ContactEntity *)contact toContact:(ContactEntity *)newContact;
- (void)onServerChangeWithAddSectionList:(NSMutableArray<NSString *>*)addSectionList
                       removeSectionList:(NSMutableArray<NSString *>*)removeSectionList
                              addContact:(ContactEntityArray*)addContacts
                           removeContact:(ContactEntityArray*)removeContacts
                           updateContact:(ContactEntityArray*)updateContacts;
@end

@interface ZaloContactService : NSObject {
    NSLock *serviceLock;
    ContactDictionary *contactDictionary;
    NSMutableDictionary<NSString *, ContactEntity *> *accountDictionary;
    NSMutableArray<id<ZaloContactEventListener>> *listeners;
}

@property id<APIServiceProtocol> apiService;

+ (ZaloContactService *)sharedInstance;
- (ContactDictionary *)getFullContactDict;
- (NSArray<ContactEntity *>*)getFullContactList;
- (void)fetchLocalContact;
- (ContactEntity *)getContactsWithPhoneNumber:(NSString *)phoneNumber;
- (void)deleteContactWithPhoneNumber:(NSString *)phoneNumber;

@end

NS_ASSUME_NONNULL_END
