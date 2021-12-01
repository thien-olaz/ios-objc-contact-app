//
//  UIAlertControllerExt.m
//  zalo-contact
//
//  Created by Thiện on 25/11/2021.
//

#import "UIAlertControllerExt.h"

@implementation UIAlertController (Common)

+ (UIAlertController *)contactPermisisonAlert {
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"No permission"
                                          message:@"Please go to setting and turn on contact access permission"
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action = [UIAlertAction
                             actionWithTitle:@"Open setting"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * _Nonnull action)
                             {
        // Open setting
        [UIApplication.sharedApplication
         openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]
         options:@{}
         completionHandler:^(BOOL Success){}];
    }];
    
    [alertController addAction:action];
    
    return alertController;
}

@end
