//
//  ZaloContactService.h
//  zalo-contact
//
//  Created by Thiện on 06/12/2021.
//

#import <Foundation/Foundation.h>
#import "MockAPIService.h"

NS_ASSUME_NONNULL_BEGIN

typedef NSMutableDictionary<NSString *, NSArray<ContactEntity *>*> ContactDictionary;

@protocol ZaloContactEventListener <NSObject>

- (void)onReceiveNewList;
- (void)onAddContact:(ContactEntity *)contact;
- (void)onDeleteContact:(ContactEntity *)contact;
- (void)onUpdateContact:(ContactEntity *)contact toContact:(ContactEntity *)newContact;

@end

@interface ZaloContactService : NSObject {
    ContactDictionary *contactDictionary;
    NSLock *contactDictionaryLock;
    
    NSMutableDictionary<NSString *, ContactEntity *> *accountDictionary;
    NSLock *accountDictionaryLock;
    
    NSMutableArray<id<ZaloContactEventListener>> *listeners;
}

@property id<APIServiceProtocol> apiService;
@property NSDate *lastUpdateTime;

+ (ZaloContactService *)sharedInstance;
- (ContactDictionary *)getFullContactDict;
- (NSArray<ContactEntity *>*)getFullContactList;
- (void)fetchLocalContact;
- (ContactEntity *)getContactsWithPhoneNumber:(NSString *)phoneNumber;

- (void)deleteContactWithPhoneNumber:(NSString *)phoneNumber;

@end

NS_ASSUME_NONNULL_END
