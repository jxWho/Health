//
//  EToday2ViewController.h
//  eHealth
//
//  Created by god on 13-4-13.
//  Copyright (c) 2013年 god. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EToday2ViewController : UITableViewController

@property(nonatomic, strong) NSMutableArray* Finished;
@property(nonatomic, weak) UIActivityIndicatorView* spin;
@property(nonatomic, weak) UITableView *ListView;
@end
