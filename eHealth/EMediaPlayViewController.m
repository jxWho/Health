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
#import <QuartzCore/QuartzCore.h>
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
    UIImage* bgview = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"png_background2" ofType:@"png"]];
    self.view.backgroundColor = [UIColor colorWithPatternImage:bgview];
    CGFloat width = self.view.bounds.size.width;
    CGFloat height = self.view.bounds.size.height;
//    self.view.backgroundColor = [UIColor whiteColor];

    
    countBackUp = [self.count intValue];
    
    
    UILabel* l = [[UILabel alloc]initWithFrame:CGRectMake(8, height * 0.5, width, 30)];
    l.backgroundColor = [UIColor clearColor];
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
    TF.backgroundColor = [UIColor clearColor];
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
    
//    NSURL* url = [NSURL fileURLWithPath:self.mediaFileName];
    NSURL *url = [NSURL fileURLWithPath:@"a.mp4"];
    
    /*
    NSString* kk;
    if( [[NSFileManager defaultManager] fileExistsAtPath:self.mediaFileName] )
        kk = @"Exist";
    else{
        kk = @"nonono";
        url = NULL;
    }
    NSLog(@"%@ sdfsdf",kk);
    NSLog(@"test");
     */
    
    self.MovieController = [[MPMoviePlayerController alloc]initWithContentURL:url];
    if( self.MovieController == nil)
        assert(@"fail file");
    self.MovieController.controlStyle = MPMovieControlStyleNone;
    self.MovieController.shouldAutoplay = YES;
    [self.MovieController.view setFrame:CGRectMake(0, 0, width, height * 0.5)];
    [self.view addSubview:self.MovieController.view];
    totPlay = @1;
    
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:self.MovieController];
    [center removeObserver:self name:MPMoviePlayerPlaybackStateDidChangeNotification object:self.MovieController];
    
    [center addObserver:self selector:@selector(finish) name:MPMoviePlayerPlaybackDidFinishNotification object:self.MovieController];
    [center addObserver:self selector:@selector(playbackStateChange) name:MPMoviePlayerPlaybackStateDidChangeNotification object:self.MovieController];
    
    if( url ){
//        [self.MovieController play];
        [self previewCreate];
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
    CGFloat width = self.view.bounds.size.width;
    CGFloat height = self.view.bounds.size.height;
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
//        IV1.backgroundColor = [UIColor whiteColor];
        UIImage* bgview = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"png_background2" ofType:@"png"]];
        IV1.backgroundColor = [UIColor colorWithPatternImage:bgview];
        bgView = IV1;
        [self.view addSubview:bgView];
        
        NSString *path = nil;
        path = [[NSBundle mainBundle]pathForResource:@"break1" ofType:@"jpg"];
        float rate = 0.5;
        UIImage* im = [UIImage imageWithContentsOfFile:path];
        UIImageView* IV = [[UIImageView alloc]initWithImage:im];
        float tempWidth = im.size.width * rate;
        float tempHeight = im.size.height * rate;
        [IV setFrame:CGRectMake((self.view.bounds.size.width - tempWidth)*0.5, 30, tempWidth, tempHeight)];
        IV.backgroundColor = [UIColor clearColor];
        self.restView = IV;
        [self.view addSubview:self.restView];
        
        UILabel* time = [[UILabel alloc]initWithFrame:CGRectMake((width-self.view.bounds.size.width)/2, tempHeight + 30, self.view.bounds.size.width, 30)];
        time.textAlignment = NSTextAlignmentCenter;
        time.backgroundColor = [UIColor clearColor];
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

    
    [self.MovieController play];
    movieStartTime = [NSDate date]; //记录开始的播放时间

    
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
    NSLog(@"exerciseTime is %f",howLong);
    
}

//重新加载播放视图
- (void)reloadThisView
{
    [bgView removeFromSuperview];
    [self.restView removeFromSuperview];
    [breakTime removeFromSuperview];
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
    if( [singleton.unFinish  count] == 1  ){
        [request setPostValue:[NSNumber numberWithInt:1] forKey:@"isLast"];
        NSLog(@"last");
    }
    [request startAsynchronous];
}

#pragma mark - 
#pragma mark ASIHTTERequest Method

- (void)requestStarted:(ASIHTTPRequest *)request
{
    if( ![self spin] ){
        UIActivityIndicatorView* t  = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [t setCenter:self.view.center];
        [t setBackgroundColor:[UIColor blackColor]];
        [t setAlpha:0.8];
        t.layer.cornerRadius = 8;
        t.layer.masksToBounds = YES;
        self.spin = t;
        
        [self.spin setFrame:CGRectZero];
        CGRect orientationFrame = [UIScreen mainScreen].bounds;
        CGFloat activeHeight = orientationFrame.size.height;
        CGFloat posY = floor(activeHeight*0.39);
        CGFloat posX = orientationFrame.size.width/2;
        CGPoint newCenter;
        newCenter = CGPointMake(posX, posY);
        [self.spin setCenter:newCenter];
        
        [self.spin setBounds:CGRectMake(0, 0, 160, 100)];
        [self.view addSubview:self.spin];
        [self.spin startAnimating];
        [self.spin becomeFirstResponder];
    }

}


- (void)uploadFinish:(ASIHTTPRequest *)request
{
    [self.spin removeFromSuperview];
    
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

#pragma mark -
#pragma subView

//创建一个预览界面
- (void)previewCreate
{
    __block UIImageView* IV = nil;
    __block UILabel* time = nil;
    __block UILabel *tempLabel = nil;
    __block UIImageView *IV1 = nil;
    __block UITextView* TV = nil;
    
    CGFloat width = self.view.bounds.size.width;
    
    
    IV1 = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
//    IV1.backgroundColor = [UIColor whiteColor];
    UIImage* bgview = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"png_background2" ofType:@"png"]];
    IV1.backgroundColor = [UIColor colorWithPatternImage:bgview];
    [self.view addSubview:IV1];
    
    
    tempLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 30)];
    tempLabel.backgroundColor = [UIColor clearColor];
    tempLabel.textAlignment = NSTextAlignmentCenter;
    tempLabel.text = @"准备进行的动作为:";
    [self.view addSubview:tempLabel];
    
    sqlite3* database;
    if( sqlite3_open([[self dataFilePath:databaseName] UTF8String], &database) != SQLITE_OK ){
        sqlite3_close(database);
        NSAssert(0, @"failed to open database");
    }
    
    int pictureId = 0;
    char *videoNameTemp = NULL;
    char *tvTest = NULL;
    NSString *tvNsstring = nil;
    
    NSString* query = [NSString stringWithFormat:@"%@%@",@"SELECT exerciseDescription, video FROM exercise WHERE eid = ",self.eid ];
    sqlite3_stmt* statement;
    if( sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, NULL) == SQLITE_OK ){
        sqlite3_step(statement);
        
        tvTest = (char *)sqlite3_column_text(statement, 0);
        tvNsstring = [NSString stringWithUTF8String:tvTest];
        
        videoNameTemp = (char *)sqlite3_column_text(statement, 1);
        
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
    
    
    
    //修改为下一张图片
    EToday1ViewController *fatherETV = (EToday1ViewController *)self.delegate;
    
    NSString *path = nil;
    float rate = pictureRate;
   
    NSString *pictureName = [fatherETV.todayList[0] objectForKey:@"eid"];
    pictureName = [NSString stringWithFormat:@"ex%d",pictureId];
    
    if( pictureId == 4 )
        path = [[NSBundle mainBundle]pathForResource:pictureName ofType:@"png"];
    else
        path = [[NSBundle mainBundle]pathForResource:pictureName ofType:@"jpg"];
    
    UIImage* im = [UIImage imageWithContentsOfFile:path];
    IV = [[UIImageView alloc]initWithImage:im];
    float tempWidth = im.size.width * rate;
    float tempHeight = im.size.height * rate;
    [IV setFrame:CGRectMake((self.view.bounds.size.width - tempWidth)*0.5, 30, tempWidth, tempHeight)];

    [self.view addSubview:IV];
    
    time = [[UILabel alloc]initWithFrame:CGRectMake((width-self.view.bounds.size.width)/2, tempHeight + 30, self.view.bounds.size.width, 30)];
    __block int rTime = 5;
    time.backgroundColor = [UIColor clearColor];
    time.textAlignment = NSTextAlignmentCenter;
    time.text = [NSString stringWithFormat:@"%@%d秒",@"预览时间:",rTime];
    [self.view addSubview:time];
    
    TV = [[UITextView alloc]initWithFrame:CGRectMake(0, tempHeight + 30 + 30 + 10, width, 150)];
    TV.editable = NO;
    TV.backgroundColor = [UIColor clearColor];
    TV.font = [UIFont boldSystemFontOfSize:18];
    TV.text = tvNsstring;
    NSLog(@"%@",tvNsstring);
    [self.view addSubview:TV];
    [self.navigationItem setHidesBackButton:YES];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        while (1) {
            NSLog(@"thread");
            NSLog(@"%d",rTime);
            sleep(1);
            rTime --;
            dispatch_async(dispatch_get_main_queue(), ^{
                time.text = [NSString stringWithFormat:@"%@%d%@",@"预览时间:",rTime,@"秒"];
            });
            if( rTime <= 0 ){
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [IV removeFromSuperview];
                    [time removeFromSuperview];
                    [tempLabel removeFromSuperview];
                    [IV1 removeFromSuperview];
                    [TV removeFromSuperview];
                    [self.MovieController play];
                    [self.navigationItem setHidesBackButton:NO];

                });
                break;
            }
        }
    });

}


@end
