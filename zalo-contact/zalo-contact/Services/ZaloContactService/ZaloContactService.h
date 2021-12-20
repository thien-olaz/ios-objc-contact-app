//
//  ZaloContactService.h
//  zalo-contact
//
//  Created by Thiện on 06/12/2021.
//

#import <Foundation/Foundation.h>
#import "MockAPIService.h"
#import "ChangeFootprint.h"

NS_ASSUME_NONNULL_BEGIN

typedef NSMutableArray<ContactEntity *> ContactEntityMutableArray;
typedef NSMutableDictionary<NSString *, ContactEntity *> AccountMutableDictionary;
typedef NSMutableOrderedSet<ChangeFootprint *> AccountIdMutableOrderedSet;
typedef NSMutableArray<OnlineContactEntity *> OnlineContactEntityMutableArray;
typedef NSMutableDictionary<NSString *, NSMutableArray<ContactEntity *>*> ContactMutableDictionary;

@protocol ZaloContactEventListener <NSObject>

- (void)onLoadSavedDataCompleteWithContact:(ContactMutableDictionary *)loadContact andAccount:(AccountMutableDictionary *)loadAccount;
- (void)onServerChangeWithFullNewList:(ContactMutableDictionary *)loadContact andAccount:(AccountMutableDictionary *)loadAccount;
- (void)onServerChangeWithAddSectionList:(NSMutableArray<NSString *>*)addSectionList
                       removeSectionList:(NSMutableArray<NSString *>*)removeSectionList
                              addContact:(NSOrderedSet<ChangeFootprint *>*)addContacts
                           removeContact:(NSOrderedSet<ChangeFootprint *>*)removeContacts
                           updateContact:(NSOrderedSet<ChangeFootprint *>*)updateContacts
                          newContactDict:(ContactMutableDictionary*)contactDict
                          newAccountDict:(AccountMutableDictionary*)accountDict;
- (void)onServerChangeOnlineFriendsWithAddContact:(ContactEntityMutableArray*)addContacts
                                    removeContact:(ContactEntityMutableArray*)removeContacts
                                    updateContact:(ContactEntityMutableArray*)updateContacts;
@end


@interface ZaloContactService : NSObject {
    OnlineContactEntityMutableArray *onlineList;
}

@property (readonly) NSMutableArray<id<ZaloContactEventListener>> *listeners;

+ (ZaloContactService *)sharedInstance;

- (OnlineContactEntityMutableArray *)getOnlineContactList;

- (ContactMutableDictionary *)getFullContactDict;
- (AccountMutableDictionary *)getAccountList;

- (void)deleteContactWithId:(NSString *)accountId;

@end

NS_ASSUME_NONNULL_END
