//
//  ZaloContactService+Observer.m
//  zalo-contact
//
//  Created by Thiện on 10/12/2021.
//
#import "ZaloContactService+Observer.h"
#import "ZaloContactService+Storage.h"

@interface ZaloContactService (Observer)

- (void)saveLatestChanges;

@end

@implementation ZaloContactService (Observer)

#pragma mark - Observer
// Check thread safe
- (void)subcribe:(id<ZaloContactEventListener>)listener {
    if (!self.listeners) {
        self.listeners = NSMutableArray.new;
    }
    [self.listeners addObject:listener];
}
// Check thread safe
- (void)unsubcribe:(id<ZaloContactEventListener>)listener {
    if (!self.listeners) {
        return;
    }
    [self.listeners removeObject:listener];
}

- (void)notifyListenerWithAddSectionList:(NSArray *)addSections
                       removeSectionList:(NSArray *)removeSections
                              addContact:(NSSet *)addContacts
                           removeContact:(NSSet *)removeContacts
                           updateContact:(NSSet *)updateContacts
                          newContactDict:(NSDictionary *)contactDict
                          newAccountDict:(NSDictionary *)accountDict {
    
    for (id<ZaloContactEventListener> listener in self.listeners) {
        if ([listener respondsToSelector:@selector(onServerChangeWithAddSectionList:removeSectionList:addContact:removeContact:updateContact:newContactDict:newAccountDict:)]) {
            [listener onServerChangeWithAddSectionList:addSections.copy
                                     removeSectionList:removeSections.copy
                                            addContact:addContacts.copy
                                         removeContact:removeContacts.copy
                                         updateContact:updateContacts.copy
                                        newContactDict:contactDict.copy
                                        newAccountDict:accountDict.copy];
        }
    }
}


@end
