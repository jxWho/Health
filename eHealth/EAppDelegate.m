//
//  EAppDelegate.m
//  eHealth
//
//  Created by god on 13-4-12.
//  Copyright (c) 2013年 god. All rights reserved.
//

#import "EAppDelegate.h"
#import "SVStatusHUD.h"

@implementation EAppDelegate


- (void)exerciseFinish
{
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter1 = [[NSDateFormatter alloc]init];
    [formatter1 setDateFormat:@"MM-dd"];

    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateString = [formatter stringFromDate:date];
    dateString = [NSString stringWithFormat:@"%@-%@-%@-%@",dateString,@"00",@"00",@"00"];
    [formatter setDateFormat:@"yyyy-MM-dd-HH-mm-ss"];
    date = [formatter dateFromString:dateString];
    NSTimeInterval timeInterval = [date timeIntervalSince1970];
    timeInterval += 24 * 3600;
    date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    
    dateString = [formatter1 stringFromDate:date];


    
    UIApplication *application = [UIApplication sharedApplication];
    
    NSArray *array = application.scheduledLocalNotifications;
    NSInteger cnt = [array count];
    
    for( int i = 0; i < cnt; i++ )
        for( int j = 0; j < [array count]; j++ ){
            UILocalNotification *noti = array[j];
            NSDictionary *dic = noti.userInfo;
            NSString *userDateString = [dic objectForKey:@"date"];
            if( [userDateString isEqualToString:dateString] == NO ){
                [application cancelLocalNotification:noti];
                break;
            }
        }
    
}

- (void)addNoti
{
    UIApplication *app  = [UIApplication sharedApplication];
    NSString *settingTime = [[NSUserDefaults standardUserDefaults] objectForKey:@"alertTime"];
    if( [settingTime isEqualToString:@"提醒时间为:  设置提醒时间"] || settingTime == nil )
        settingTime = @"12:00";
    
    NSDate *date1 = [NSDate date];
    NSDateFormatter *formatter1 = [[NSDateFormatter alloc]init];
    [formatter1 setDateFormat:@"MM-dd"];
    
    for( UILocalNotification *tempNoti in [app scheduledLocalNotifications] ){
        NSString *tempDate = [tempNoti.userInfo objectForKey:@"date"];
        if ( [tempDate isEqualToString:[formatter1 stringFromDate:date1]] )
            return;
        NSLog(@"%@",[tempNoti.userInfo objectForKey:@"date"]);
    }
    
    for( int i = 0; i < 3; i++ ){   //同时创建三个
    
        UILocalNotification *noti = [[UILocalNotification alloc]init];
        NSLog(@"create");
        
        if( noti ){
            NSDate *date = [NSDate date];
            
            NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
            [formatter setDateFormat:@"yyyy-MM-dd"];
            NSString *dateString = [formatter stringFromDate:date];
            dateString = [NSString stringWithFormat:@"%@-%@-%@-%@",dateString,@"00",@"00",@"00"];
            [formatter setDateFormat:@"yyyy-MM-dd-HH-mm-ss"];
            date = [formatter dateFromString:dateString];
            NSArray *chunk = [settingTime componentsSeparatedByString:@":"];
            NSTimeInterval timeInterval = [date timeIntervalSince1970];
            timeInterval += 24 * 3600;
            timeInterval += [(NSString *)chunk[0] intValue] * 3600;
            timeInterval += [chunk[1] intValue] * 60;
            timeInterval += i * 600;
            NSLog(@"%d %d",[chunk[0] intValue], [chunk[1] intValue]);
            noti.fireDate = [NSDate dateWithTimeIntervalSince1970:timeInterval];
            noti.timeZone = [NSTimeZone defaultTimeZone];
            noti.soundName = UILocalNotificationDefaultSoundName;
            noti.alertBody = @"今天的锻炼时间到啦~~~";
            noti.alertAction = @"进入锻炼";
            noti.repeatInterval = NSDayCalendarUnit;
            noti.applicationIconBadgeNumber =  1;
            NSDictionary *infoDic = [NSDictionary dictionaryWithObjectsAndKeys:[formatter1 stringFromDate:date1],@"date", nil];
            noti.userInfo = infoDic;
            [app scheduleLocalNotification:noti];
        }
    }
}

- (void)reachabilityChanged: (NSNotification *)note
{
    Reachability *tempReach = [note object];
    NetworkStatus netStatus = [tempReach currentReachabilityStatus];
    if( netStatus == ReachableViaWiFi )
        wifiConnect = YES;
    else if( netStatus == ReachableViaWWAN )
        interConnect = YES;
    else if( netStatus == NotReachable ){
        if( tempReach == internetReach )
            interConnect = NO;
        else wifiConnect = NO;
    }
    if( wifiConnect == NO && interConnect == NO ){
        [SVStatusHUD showWithImage:nil status:@"当前无网络状态~"];
    }
}

- (void) internetCheck
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    internetReach = [Reachability reachabilityForInternetConnection];
    interConnect = YES;
    [internetReach startNotifier];
    
    wifiReach = [Reachability reachabilityForLocalWiFi];
    wifiConnect = YES;
    [wifiReach startNotifier];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    application.applicationIconBadgeNumber = 0;
    application.statusBarHidden = NO;
    [self addNoti];
    
    [self internetCheck];
    self.viewController  = [[ELoginViewController alloc]init];
    [self.viewController setValue:@"first" forKey:@"downloadFlag"];
    self.window.rootViewController = [[UINavigationController alloc]initWithRootViewController:self.viewController];
    [self.window makeKeyAndVisible];
    
    UILocalNotification *localNoti = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if( localNoti ){
        [[UIApplication sharedApplication] cancelLocalNotification:localNoti];
        NSLog(@"delete one");
    }
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(exerciseFinish) name:FINISHNOTIFICATION object:nil];
    
    return YES;
}



- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    
    UIApplication *app = [UIApplication sharedApplication];
    app.applicationIconBadgeNumber -= 1;
    /*
    NSArray *localArray = [app scheduledLocalNotifications];
    UILocalNotification *localNoti = nil;
    NSString *standardDate = [notification.userInfo objectForKey:@"date"];
    if( localArray )
        for( UILocalNotification *notiTemp in  localArray){
            NSDictionary *dict = notiTemp.userInfo;
            NSString *p = [dict objectForKey:@"date"];
            if( [p isEqualToString:standardDate] ){
                localNoti = notiTemp;
                [app cancelLocalNotification:localNoti];
                NSLog(@"delete");
            }
        }
     */
    [app cancelLocalNotification:notification];
    NSLog(@"receive");
    return;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
