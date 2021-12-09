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
                                          alertControllerWithTitle:@"Không có quyền truy cập"
                                          message:@"Xin hãy vào cài đặt và cấp quyền truy cập danh bạ"
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action = [UIAlertAction
                             actionWithTitle:@"Mở cài đặt"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * _Nonnull action)
                             {
        // Open setting
        [UIApplication.sharedApplication
         openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]
         options:@{}
         completionHandler:^(BOOL Success){
            
        }];
    }];
    
    [alertController addAction:action];
    
    return alertController;
}

@end
