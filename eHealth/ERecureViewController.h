//
//  ERecureViewController.h
//  eHealth
//
//  Created by god on 13-4-13.
//  Copyright (c) 2013年 god. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <sqlite3.h>
#import "ERecureDetailViewController.h"
@interface ERecureViewController : UITableViewController<UITableViewDataSource, UITableViewDelegate>

@property(nonatomic, weak)UIActivityIndicatorView* spin;


//modal
@property(nonatomic, strong) NSMutableArray* Plan;

@end
