//
//  EQuestionViewController.h
//  eHealth
//
//  Created by god on 13-5-1.
//  Copyright (c) 2013年 god. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EQuestionDetailViewController.h"

@interface EQuestionViewController : UITableViewController<EQuestionDetailViewDelgete>
@property (strong, nonatomic) IBOutlet UITableView *Question;

@property(nonatomic, strong) NSMutableArray *questions;
@property (weak, nonatomic) UIActivityIndicatorView *spin;

@end
