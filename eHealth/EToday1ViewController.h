//
//  EToday1ViewController.h
//  eHealth
//
//  Created by god on 13-4-13.
//  Copyright (c) 2013年 god. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHeaders.h"
#import <sqlite3.h>
#import "EMediaPlayViewController.h"
@interface EToday1ViewController : UIViewController<ASIHTTPRequestDelegate>
{
    NSNumber *nowRow; //回调时即将播放的行数
}

@property(nonatomic, weak)UIActivityIndicatorView* spin;

//modal
@property(nonatomic, strong)NSMutableArray* todayList;
@property(nonatomic, strong)EMediaPlayViewController* EMVP;
@end
