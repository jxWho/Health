//
//  EMediaPlayViewController.m
//  eHealth
//
//  Created by god on 13-4-16.
//  Copyright (c) 2013年 god. All rights reserved.
//

#import "EMediaPlayViewController.h"
#import "EToday1ViewController.h"
#import "EPatientModel.h"
#import <sqlite3.h>
#import "EFile.h"
#define dataBaseName   @"ehealth.db"
#define pictureRate    0.7

@interface EMediaPlayViewController ()<ASIHTTPRequestDelegate>
{
    UIImageView* bgView;
    UILabel* breakTime;
    int restTime;
    int countBackUp;//为了重播
    
    //上传数据
    NSDate *movieStartTime;
    NSNumber *totPlay;
}

@end

@implementation EMediaPlayViewController

@synthesize mediaFileName, MovieController, count, textField, label, restView, delegate;

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
    CGFloat width = self.view.bounds.size.width;
    CGFloat height = self.view.bounds.size.height;
    self.view.backgroundColor = [UIColor whiteColor];

    
    countBackUp = [self.count intValue];
    
    
    UILabel* l = [[UILabel alloc]initWithFrame:CGRectMake(8, height * 0.5, width, 30)];
    int c = [self.count intValue];
    l.text = [NSString stringWithFormat:@"%@%d",@"剩余次数:",c];
    self.label = l;
    [self.view addSubview:self.label];
    
    sqlite3* database;
    if( sqlite3_open([[self dataFilePath:dataBaseName] UTF8String], &database) != SQLITE_OK ){
        sqlite3_close(database);
        NSAssert(0, @"failed to open database");
    }
    UITextView *TF = [[UITextView alloc]initWithFrame:CGRectMake(0, height*0.5+30, width, height*0.5 - 30)];
    TF.editable = NO;
    NSString* querty = [NSString stringWithFormat:@"%@%@",@"SELECT exerciseDescription FROM exercise WHERE eid = ",self.eid];
    sqlite3_stmt* statement;
    if( sqlite3_prepare_v2(database, [querty UTF8String], -1, &statement, NULL) == SQLITE_OK ){
        while( sqlite3_step(statement) == SQLITE_ROW ){
            char* s = (char *)sqlite3_column_text(statement, 0);
            TF.text = [NSString stringWithUTF8String:s];
        }
    }
    sqlite3_finalize(statement);
    sqlite3_close(database);
    TF.font = [UIFont boldSystemFontOfSize:18];
    self.textField = TF;
    [self.view addSubview:TF];
    
    [self videoCreate];

}

- (void)videoCreate
{
    CGFloat width = self.view.bounds.size.width;
    CGFloat height = self.view.bounds.size.height;
    
    NSURL* url = [NSURL fileURLWithPath:self.mediaFileName];
    
    NSString* kk;
    if( [[NSFileManager defaultManager] fileExistsAtPath:self.mediaFileName] )
        kk = @"Exist";
    else{
        kk = @"nonono";
        url = NULL;
    }
    NSLog(@"%@ sdfsdf",kk);
    NSLog(@"test");
    
    self.MovieController = [[MPMoviePlayerController alloc]initWithContentURL:url];
    self.MovieController.controlStyle = MPMovieControlStyleNone;
    self.MovieController.shouldAutoplay = YES;
    [self.MovieController.view setFrame:CGRectMake(0, 0, width, height * 0.5)];
    [self.view addSubview:self.MovieController.view];
    movieStartTime = [NSDate date];
    totPlay = @1;
    
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:self.MovieController];
    [center removeObserver:self name:MPMoviePlayerPlaybackStateDidChangeNotification object:self.MovieController];
    
    [center addObserver:self selector:@selector(finish) name:MPMoviePlayerPlaybackDidFinishNotification object:self.MovieController];
    [center addObserver:self selector:@selector(playbackStateChange) name:MPMoviePlayerPlaybackStateDidChangeNotification object:self.MovieController];
    
    if( url ){
        [self.MovieController play];
    }else{
//        [[NSNotificationCenter defaultCenter]postNotification:[NSNotification notificationWithName:MPMoviePlayerPlaybackDidFinishNotification object:nil]];
        self.count = [NSString stringWithFormat:@"%d",0];
        [SVStatusHUD showWithImage:nil status:@"视频损坏~~~"];
        [self finish];
    }

}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.MovieController pause];
    [self.MovieController.view removeFromSuperview];

}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (NSString *)dataFilePath:(NSString *)fileName
{
    NSString* path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    return  [path stringByAppendingPathComponent:fileName];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)finish
{
//    [self.MovieController.view removeFromSuperview];
    NSLog(@"bofang finish");
    int cnt = [self.count intValue];
    NSLog(@"%d 剩余",cnt);
    cnt --;
    if( cnt > 0 ){
        self.count = [NSString stringWithFormat:@"%d",cnt];
        self.label.text = [NSString stringWithFormat:@"%@%d",@"剩余次数:",cnt];

        [self.MovieController play];
        
        
        int tempTot = [totPlay intValue];
        tempTot ++;
        totPlay = [NSNumber numberWithInt:tempTot];
        
    }else{
        [self.navigationItem setHidesBackButton:YES];
        
        UIImageView* IV1 = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        IV1.backgroundColor = [UIColor whiteColor];
        bgView = IV1;
        [self.view addSubview:bgView];
        
        UILabel *tempLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 30)];
        tempLabel.text = @"下一节的动作为:";
        self.breakTitle = tempLabel;
        [self.view addSubview:self.breakTitle];
        
        //修改为下一张图片
        EToday1ViewController *fatherETV = (EToday1ViewController *)self.delegate;
        NSString *path = nil;
        
        float rate = pictureRate;
        
        if( [fatherETV.todayList count] <= 1 ){
            path = [[NSBundle mainBundle]pathForResource:@"break1" ofType:@"jpg"];
            rate = 0.5;
        }
        else if( [fatherETV.todayList count] > 1 ){
            NSString *pictureName = [fatherETV.todayList[1] objectForKey:@"eid"];
            pictureName = [NSString stringWithFormat:@"ex%@",pictureName];
            path = [[NSBundle mainBundle]pathForResource:pictureName ofType:@"jpg"];
        }
        
        UIImage* im = [UIImage imageWithContentsOfFile:path];
        UIImageView* IV = [[UIImageView alloc]initWithImage:im];
        float tempWidth = im.size.width * rate;
        float tempHeight = im.size.height * rate;
        [IV setFrame:CGRectMake((self.view.bounds.size.width - tempWidth)*0.5, 30, tempWidth, tempHeight)];
        self.restView = IV;
        [self.view addSubview:self.restView];
        
        UILabel* time = [[UILabel alloc]initWithFrame:CGRectMake(10, tempHeight + 30, self.view.bounds.size.width, 30)];
        restTime = 5;
        time.text = [NSString stringWithFormat:@"%@%d%@",@"休息剩余时间:",restTime,@"秒"];
        breakTime = time;
        [self.view addSubview:breakTime];
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            while (1) {
                NSLog(@"thread");
                NSLog(@"%d",restTime);
                sleep(1);
                restTime --;
                dispatch_async(dispatch_get_main_queue(), ^{
                    breakTime.text = [NSString stringWithFormat:@"%@%d%@",@"休息剩余时间:",restTime,@"秒"];
                });
                if( restTime <= 0 ){
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"重做这一节" style:UIBarButtonItemStylePlain target:self action:@selector(redo)];
                        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"下一节" style:UIBarButtonItemStylePlain target:self action:@selector(doNext)];
                    });
                    break;
                }
            }
        });
    }
    //[self.navigationController popViewControllerAnimated:YES];
}

- (void)redo
{
    NSLog(@"redo");
    self.count = [NSString stringWithFormat:@"%d",countBackUp];
    self.label.text = [NSString stringWithFormat:@"%@%d",@"剩余次数:",countBackUp];
    self.navigationItem.rightBarButtonItem = nil;
    self.navigationItem.leftBarButtonItem = nil;
    [self.navigationItem setHidesBackButton:NO];
    [bgView removeFromSuperview];
    [self.restView removeFromSuperview];
    [breakTime removeFromSuperview];
    [self.breakTitle removeFromSuperview];
    
    [self.MovieController play];
    
    int tempTot = [totPlay intValue];
    tempTot ++;
    totPlay = [NSNumber numberWithInt:tempTot];
}

-(void)doNext
{
    NSLog(@"doNext");
    
    //上传数据
    NSDate *endTime = [NSDate date];
    NSTimeInterval howLong = [endTime timeIntervalSince1970] - [movieStartTime timeIntervalSince1970];
    NSNumber *pid = nil;
    NSNumber *did = nil;
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"YYYY-MM-dd"];
    NSString *date = [formatter stringFromDate:endTime];
    
    NSString *filePath = [EFile dataFilePath:personFile];
    if( [[NSFileManager defaultManager]fileExistsAtPath:filePath] ){
        NSArray *array = [NSArray arrayWithContentsOfFile:filePath];
        pid = array[2];
        did = array[5];
    }
    NSNumber *eidNumber = [NSNumber numberWithInt:[self.eid intValue]];
    [self uploadDataWherePid:pid Did:did Eid:eidNumber Count:totPlay ExerciseTime:howLong Date:date];
    
    
}

//重新加载播放视图
- (void)reloadThisView
{
    [bgView removeFromSuperview];
    [self.restView removeFromSuperview];
    [breakTime removeFromSuperview];
    [self.breakTitle removeFromSuperview];
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem = nil;
    [self.navigationItem setHidesBackButton:NO];
    [self.MovieController.view removeFromSuperview];

    self.view.backgroundColor = [UIColor whiteColor];
    [self videoCreate];
    
    countBackUp = [self.count intValue];
    
    int c = [self.count intValue];
    self.label.text = [NSString stringWithFormat:@"%@%d",@"剩余次数:",c];
    
    
    sqlite3* database;
    if( sqlite3_open([[self dataFilePath:dataBaseName] UTF8String], &database) != SQLITE_OK ){
        sqlite3_close(database);
        NSAssert(0, @"failed to open database");
    }
    NSString* querty = [NSString stringWithFormat:@"%@%@",@"SELECT exerciseDescription FROM exercise WHERE eid = ",self.eid];
    sqlite3_stmt* statement;
    if( sqlite3_prepare_v2(database, [querty UTF8String], -1, &statement, NULL) == SQLITE_OK ){
        while( sqlite3_step(statement) == SQLITE_ROW ){
            char* s = (char *)sqlite3_column_text(statement, 0);
            self.textField.text = [NSString stringWithUTF8String:s];
        }
    }
    sqlite3_finalize(statement);
    sqlite3_close(database);
    
}

- (void)uploadDataWherePid:(NSNumber *)pid Did:(NSNumber *)did Eid:(NSNumber *)eid Count:(NSNumber *)Count ExerciseTime:(NSTimeInterval)exerciseTime Date:(NSString *)date
{
    EPatientModel *singleton = [EPatientModel sharedEPatientModel];
    NSString *add = @"http://myehealth.sinaapp.com/API/addPlanRecord";
    NSURL *url = [NSURL URLWithString:add];
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc]initWithURL:url];
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(uploadFinish:)];
    [request setPostValue:pid forKey:@"pid"];
    [request setPostValue:did forKey:@"did"];
    [request setPostValue:eid forKey:@"eid"];
    [request setPostValue:Count forKey:@"count"];
    [request setPostValue:[NSNumber numberWithDouble: exerciseTime] forKey:@"exerciseTime"];
    [request setPostValue:date forKey:@"date"];
    if( [singleton.unFinish  count] == 1  )
        [request setPostValue:[NSNumber numberWithInt:1] forKey:@"isLast"];
    [request startAsynchronous];
}

#pragma mark - ASIHTTERequest Method

- (void)requestStarted:(ASIHTTPRequest *)request
{
    
}


- (void)uploadFinish:(ASIHTTPRequest *)request
{
    NSData *data = [request responseData];
    NSError *error = [[NSError alloc]init];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    NSNumber *rc = [json objectForKey:@"rc"];
    NSLog(@"%@",json);
    if( [rc isEqual:@0] ){
        NSLog(@"upload succeed!");
        EPatientModel *singleton = [EPatientModel sharedEPatientModel];
        [bgView removeFromSuperview];
        [self.restView removeFromSuperview];
        [breakTime removeFromSuperview];
        [delegate goToNext];
        
        if( [singleton.unFinish count] > 0 ){
            NSLog(@"%d",[singleton.unFinish count]);
            [self reloadThisView];
        }else{
            [self.navigationController popViewControllerAnimated:YES];
            [delegate showQuestionNoti];
        }
        
    }else{
        NSLog(@"upload failed");
    }
}

- (void)playbackStateChange
{
    MPMoviePlaybackState state = [self.MovieController playbackState];
    switch (state) {
            case MPMoviePlaybackStateStopped:
            NSLog(@"停止");
            [[NSNotificationCenter defaultCenter]postNotification:[NSNotification notificationWithName:MPMoviePlayerPlaybackDidFinishNotification object:nil]];
            self.count = [NSString stringWithFormat:@"%d",0];
            [SVStatusHUD showWithImage:nil status:@"视频损坏~~~"];
            break;
            
        case MPMoviePlaybackStatePlaying:
            NSLog(@"播放中");
            break;
            
        case MPMoviePlaybackStatePaused:
            NSLog(@"暫停");
            break;
            
        case MPMoviePlaybackStateInterrupted:
            NSLog(@"播放被中斷");
            break;
            
        case MPMoviePlaybackStateSeekingForward:
            NSLog(@"往前快轉");
            break;
            
        case MPMoviePlaybackStateSeekingBackward:
            NSLog(@"往後快轉");
            break;
            
        default:
            NSLog(@"無法辨識的狀態");
            break;
    }
}

@end
