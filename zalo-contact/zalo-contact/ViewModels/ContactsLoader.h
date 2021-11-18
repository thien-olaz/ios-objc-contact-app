//
//  ContactsLoader.h
//  zalo-contact
//
//  Created by LAp14886 on 15/11/2021.
//

#import <Foundation/Foundation.h>
#import "../ViewModels/NSObject_ListDiffable.h"
#import "../Ultilities/UserContacts.h"
#import "../Models/ContactAdapter.h"
#import "../Models/ContactGroup.h"
NS_ASSUME_NONNULL_BEGIN

@interface ContactsLoader : NSObject

-(NSMutableArray *) contactGroup;
-(void) update;
@end

NS_ASSUME_NONNULL_END
