//
//  ETodayViewController.m
//  eHealth
//
//  Created by god on 13-4-13.
//  Copyright (c) 2013年 god. All rights reserved.
//

#import "ETodayViewController.h"
#import "SVStatusHUD.h"
#import "EPatientModel.h"
@interface ETodayViewController ()

@end

@implementation ETodayViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.navigationItem.title = @"今日计划";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"填写问卷" style:UIBarButtonItemStylePlain target:self action:@selector(goToQuestion)];
    EPatientModel *singleton = [EPatientModel sharedEPatientModel];
    
    [self setDelegate:self];
    
    EToday1ViewController* t1VC = [[EToday1ViewController alloc]init];
    EToday2ViewController* t2VC = [[EToday2ViewController alloc]init];
    t1VC.tabBarItem = [[UITabBarItem alloc]initWithTitle:@"未完成" image:nil tag:0];
    t2VC.tabBarItem = [[UITabBarItem alloc]initWithTitle:@"已完成" image:nil tag:1];
    self.viewControllers = [NSArray arrayWithObjects:t1VC,t2VC, nil];
    
    if( [singleton.unFinish count] > 0 )
        self.navigationItem.rightBarButtonItem.enabled = NO;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(exerciseFinish) name:FINISHNOTIFICATION object:nil];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)goToQuestion
{
    EPatientModel *singleton = [EPatientModel sharedEPatientModel];
    if( singleton.questionFlag == NO ){
        EQuestionViewController *EQV = [[EQuestionViewController alloc]init];
        [self.navigationController pushViewController:EQV animated:YES];
    }
    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:FINISHNOTIFICATION object:nil];
}

- (void)exerciseFinish
{
    self.navigationItem.rightBarButtonItem.enabled = YES;
}

#pragma UITabController Method Delegate
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    NSLog(@"acctive!");
    if( [viewController class] == [EToday2ViewController class] ){
        UITableView *tView = (UITableView *)viewController.view;
        [tView reloadData];
        NSLog(@"reload View");
        
    }
}

@end
