//
//  EAppDelegate.h
//  eHealth
//
//  Created by god on 13-4-12.
//  Copyright (c) 2013年 god. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ELoginViewController.h"
#import "Reachability.h"
#import <MessageUI/MessageUI.h>

@class EViewController;

@interface EAppDelegate : UIResponder <UIApplicationDelegate, MFMailComposeViewControllerDelegate>
{
    Reachability *internetReach;
    Reachability *wifiReach;
    BOOL interConnect;
    BOOL wifiConnect;
}

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) ELoginViewController* viewController;

@property (nonatomic, strong) UIAlertView *alert;

@end
