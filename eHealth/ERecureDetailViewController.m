//
//  ERecureDetailViewController.m
//  eHealth
//
//  Created by god on 13-4-16.
//  Copyright (c) 2013年 god. All rights reserved.
//

#import "ERecureDetailViewController.h"
#import <sqlite3.h>
#define databaseName @"ehealth.db"
#include <string.h>

@interface ERecureDetailViewController ()<UINavigationBarDelegate>
{
    UIButton *barItem;
}
@end

@implementation ERecureDetailViewController

@synthesize imageView, textView;

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
    self.title = @"康复动作详细资料";
	// Do any additional setup after loading the view.
    UIImage* bgview = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"png_background2" ofType:@"png"]];
    self.view.backgroundColor = [UIColor colorWithPatternImage:bgview];
//    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.navigationController setNavigationBarHidden:NO];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStyleDone target:self action:@selector(Go)];

    
    CGFloat width = self.view.bounds.size.width;
    
    UITextView* TV = [[UITextView alloc]initWithFrame:CGRectMake(30, 5, width - 60, 80)];
    TV.backgroundColor = [UIColor clearColor];
    sqlite3* database;
    
    int pictureId = 0;
    char *videoNameTemp = NULL;
    
    if( sqlite3_open([[self dataFilePath:databaseName] UTF8String], &database) != SQLITE_OK ){
        sqlite3_close(database);
        NSAssert(0, @"failed to open database");
    }
    NSString* query = [NSString stringWithFormat:@"%@%@",@"SELECT  video, exerciseDescription FROM exercise WHERE eid = ",self.eid ];
    sqlite3_stmt* statement;
    if( sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, NULL) == SQLITE_OK ){
        sqlite3_step(statement);
        char *s = (char *)sqlite3_column_text(statement, 1);
        TV.text = [NSString stringWithUTF8String:s];
        
        videoNameTemp = (char *)sqlite3_column_text(statement, 0);
        int llen = strlen(videoNameTemp);
        for( int i = 0; i < llen; i++ ){
            if( videoNameTemp[i] >= '0' && videoNameTemp[i] <= '9' )
                pictureId = pictureId * 10 + videoNameTemp[i] - '0';
            if( videoNameTemp[i] == '.' )
                break;
        }
        
        sqlite3_finalize(statement);
    }
    sqlite3_close(database);
    
    

    TV.font = [UIFont boldSystemFontOfSize:15];
    self.textView = TV;
    TV.editable = NO;
    [self.view addSubview:self.textView];
    
    NSString* pictureName = [NSString stringWithFormat:@"%@%d",@"ex",pictureId];
    NSLog(@"p %@",pictureName);
    
    NSString* pictruePath = nil;
    if( pictureId == 4 )
         pictruePath = [[NSBundle mainBundle]pathForResource:pictureName ofType:@"png"];
    else
        pictruePath = [[NSBundle mainBundle]pathForResource:pictureName ofType:@"jpg"];

    if( pictruePath ){
        UIImage* i = [UIImage imageWithContentsOfFile:pictruePath];
        UIImageView* iView = [[UIImageView alloc]initWithImage:i];
        CGFloat pWidth = i.size.width * 0.7;
        [iView setFrame:CGRectMake((width - pWidth)/2, 30 + 80 , i.size.width*0.7, i.size.height*0.7)];
        self.imageView = iView;
        [self.view addSubview:self.imageView];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)dataFilePath:(NSString *)fileName
{
    NSString* path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    return [path stringByAppendingPathComponent:fileName];
}

- (void)Go
{
    [self dismissViewControllerAnimated:YES completion:^{}];
}


@end
