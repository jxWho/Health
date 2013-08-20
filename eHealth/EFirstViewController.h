//
//  EFirstViewController.h
//  eHealth
//
//  Created by god on 13-4-14.
//  Copyright (c) 2013年 god. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EPersonViewController.h"
#import "ERecureViewController.h"
#import "ETodayViewController.h"
#import "ASIHeaders.h"
#import "EDrawViewController.h"
#import "ECommunicationViewController.h"
#import "EPatientModel.h"
#import <sqlite3.h>
@interface EFirstViewController : UIViewController
{
    NSString* downloadFlag;
}

@property(nonatomic, weak) UIButton* todayButton;
@property(nonatomic, weak) UIButton* recureButton;
@property(nonatomic, weak) UIButton* personButton;
@property(nonatomic, weak) UIButton* communicationButton;
@property(nonatomic, weak) UIButton* dataButton;
@property(nonatomic, weak) UIActivityIndicatorView* spin;
@property(nonatomic, strong) NSOperationQueue* queue;
@end
