//
//  EDrawViewController.h
//  eHealth
//
//  Created by god on 13-4-20.
//  Copyright (c) 2013年 god. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ELineChartView.h"
#import "ASIHeaders.h"
@interface EDrawViewController : UIViewController

@property(nonatomic, strong) ELineChartView* lineChartView;
@property(nonatomic, strong) NSMutableArray *pointArr;
@property(nonatomic, strong) NSMutableArray* vArr;
@property(nonatomic, strong) NSMutableArray* hArr;
@property(nonatomic, strong)UIActivityIndicatorView* spin;
@property(assign) NSInteger Unit;
@end
