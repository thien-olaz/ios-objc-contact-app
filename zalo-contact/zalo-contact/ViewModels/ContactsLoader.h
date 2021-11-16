//
//  ContactsLoader.h
//  zalo-contact
//
//  Created by LAp14886 on 15/11/2021.
//

#import <Foundation/Foundation.h>
#import "../ViewModels/NSObject_ListDiffable.h"

NS_ASSUME_NONNULL_BEGIN

@interface ContactsLoader : NSObject

@property NSMutableArray* contactsArray;

- (void) fetchContacts;

@end

NS_ASSUME_NONNULL_END
