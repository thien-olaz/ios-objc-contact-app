//
//  ZaloContactService+Observer.h
//  zalo-contact
//
//  Created by Thiện on 10/12/2021.
//

#import "CellObject.h"
#import "ZaloContactService.h"
#import "ZaloContactService+Private.h"
NS_ASSUME_NONNULL_BEGIN

@interface ZaloContactService ()

@end

@interface ZaloContactService (Observer)

- (void)subcribe:(id<ZaloContactEventListener>)listener;
- (void)unsubcribe:(id<ZaloContactEventListener>)listener;
- (void)notifyListenerWithAddSectionList:(NSArray *)addSections
                       removeSectionList:(NSArray *)removeSections
                              addContact:(NSSet *)addContacts
                           removeContact:(NSSet *)removeContacts
                           updateContact:(NSSet *)updateContacts
                          newContactDict:(NSDictionary *)contactDict
                          newAccountDict:(NSDictionary *)accountDict;
@end

NS_ASSUME_NONNULL_END
