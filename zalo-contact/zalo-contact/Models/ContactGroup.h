//
//  ContactGroup.h
//  zalo-contact
//
//  Created by Thiện on 18/11/2021.
//

#import <Foundation/Foundation.h>
#import "Contact.h"
NS_ASSUME_NONNULL_BEGIN

@interface ContactGroup : NSObject

@property NSString *header;
@property NSMutableArray<Contact *> *contacts;

- (id) initWithContactArray:(NSArray<Contact *> *)contacts;

@end

NS_ASSUME_NONNULL_END
