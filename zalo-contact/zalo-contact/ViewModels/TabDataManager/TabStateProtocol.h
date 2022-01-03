//
//  TabStateProtocol.h
//  zalo-contact
//
//  Created by Thiện on 03/01/2022.
//

#import <Foundation/Foundation.h>
#import "ContactViewModel.h"

NS_ASSUME_NONNULL_BEGIN


@protocol TabStateProtocol

- (void)switchToTabClass:(Class)tabClass;
- (void)switchToContactTab;
- (void)switchToOnlineTab;

@end


NS_ASSUME_NONNULL_END
