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
typedef NSMutableDictionary<NSString *, ContactEntity *> AccountDictionary;
typedef NSMutableSet<NSString *> AccountIdSet;
typedef NSMutableArray<OnlineContactEntity *> OnlineContactEntityArray;
typedef NSMutableDictionary<NSString *, NSMutableArray<ContactEntity *>*> ContactDictionary;

@protocol ZaloContactEventListener <NSObject>
- (void)onLoadSavedDataComplete:(ContactDictionary *)loadedData;
- (void)onReceiveNewList;
- (void)onAddContact:(ContactEntity *)contact;
- (void)onDeleteContact:(ContactEntity *)contact;
- (void)onUpdateContact:(ContactEntity *)contact toContact:(ContactEntity *)newContact;

- (void)onServerChangeWithAddSectionList:(NSMutableArray<NSString *>*)addSectionList
                       removeSectionList:(NSMutableArray<NSString *>*)removeSectionList
                              addContact:(AccountIdSet*)addContacts
                           removeContact:(AccountIdSet*)removeContacts
                           updateContact:(AccountIdSet*)updateContacts
                          newContactDict:(ContactDictionary*)contactDict
                          newAccountDict:(AccountDictionary*)accountDict;

- (void)onServerChangeOnlineFriendsWithAddContact:(ContactEntityArray*)addContacts
                                    removeContact:(ContactEntityArray*)removeContacts
                                    updateContact:(ContactEntityArray*)updateContacts;
@end

@interface ZaloContactService : NSObject {    
    ContactDictionary *contactDictionary;
    NSMutableDictionary<NSString *, ContactEntity *> *accountDictionary;
    OnlineContactEntityArray *onlineList;
    NSMutableArray<id<ZaloContactEventListener>> *listeners;
}

@property id<APIServiceProtocol> apiService;

+ (ZaloContactService *)sharedInstance;
- (OnlineContactEntityArray *)getOnlineContactList;
- (ContactDictionary *)getFullContactDict;
- (NSArray<ContactEntity *>*)getFullContactList;
- (void)fetchLocalContact;
- (ContactEntity *)getContactsWithPhoneNumber:(NSString *)phoneNumber;
- (void)deleteContactWithId:(NSString *)accountId;

@end

NS_ASSUME_NONNULL_END
