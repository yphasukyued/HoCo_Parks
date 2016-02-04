//
//  CustomAlert.m
//  iOSHoCoParks
//
//  Created by Yongyuth Phasukyued on 8/25/15.
//  Copyright (c) 2015 Howard County. All rights reserved.
//

#import "CustomAlert.h"

@interface CustomAlert ()

@end

@implementation CustomAlert

+ (UIViewController *)makePhoneCall {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Call a Park Ranger"
                                                                             message:@"410-245-1410"
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action)
                               {
                                   NSString *phoneStr = [NSString stringWithFormat:@"tel:4102451410"];
                                   [[UIApplication sharedApplication]
                                    openURL:[NSURL URLWithString:phoneStr]];
                                   
                               }];
    
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * action)
                                   {
                                       [alertController dismissViewControllerAnimated:YES completion:nil];
                                   }];
    [alertController addAction:actionOk];
    [alertController addAction:actionCancel];
    return alertController;
}

+ (UIViewController *)openMenuInformation:(NSString *)info mtitle:(NSString *)title {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:info
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action)
                               {
                                  [alertController dismissViewControllerAnimated:YES completion:nil];
                               }];
    
    [alertController addAction:actionOk];
    return alertController;
}

+ (UIViewController *)lowMemoryAlert {
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Low Memory"
                                          message:@"Your device is running low on memory, please exit and restart this app."
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"Exit"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action)
                               {
                                   exit(0);
                               }];
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * action)
                                   {
                                       [alertController dismissViewControllerAnimated:YES completion:nil];
                                   }];
    [alertController addAction:actionOk];
    [alertController addAction:actionCancel];
    return alertController;
}
@end
