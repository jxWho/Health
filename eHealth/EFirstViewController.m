//
//  EFirstViewController.m
//  eHealth
//
//  Created by god on 13-4-14.
//  Copyright (c) 2013年 god. All rights reserved.
//

#import "EFirstViewController.h"
#import "SVStatusHUD.h"
#define dataBaseName   @"ehealth.db"
#define personFile @"person.plist"


@interface EFirstViewController ()<ASIHTTPRequestDelegate, UIAlertViewDelegate>
{
    BOOL videoDownloadFlag; //所有视频都下载完毕的标志
    NSString *videoLatest; //最新的视频邮戳
}
@end

@implementation EFirstViewController

@synthesize todayButton = _todayButton;
@synthesize recureButton = _recureButton;
@synthesize personButton = _personButton;
@synthesize communicationButton = _communicationButton;
@synthesize dataButton = _dataButton;
@synthesize spin = _spin;
@synthesize queue = _queue;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)logOut
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)reflesh
{
    [self checkUpdateAndDownloadList];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.navigationItem setHidesBackButton:YES];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"注销" style:UIBarButtonItemStyleBordered target:self action:@selector(logOut)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"刷新" style:UIBarButtonItemStyleBordered target:self action:@selector(reflesh)];
    
    self.navigationItem.title = @"首页";
    self.view.backgroundColor = [UIColor whiteColor];
    CGFloat width = self.view.bounds.size.width;
    CGFloat height = self.view.bounds.size.height;
    CGFloat base = width / 11;
    NSLog(@"%f %f",width,height);
    
   
    
    UIButton *tBtn = [[UIButton alloc] initWithFrame:CGRectMake(base, base, 119*0.8, 114*0.8)];
    //[pushuBtn addTarget:self action:@selector(pushuToVC:) forControlEvents:UIControlEventTouchUpInside];
    [tBtn addTarget:self action:@selector(pushToToday:) forControlEvents:UIControlEventTouchUpInside];
    NSString* path = [[NSBundle mainBundle] pathForResource:@"png_lbutton_exercise" ofType:@"png"];
    [tBtn setImage:[UIImage imageWithContentsOfFile:path] forState:UIControlStateNormal];
    self.todayButton = tBtn;
    [self.view addSubview:self.todayButton];
    
    UIButton* rBtn = [[UIButton alloc]initWithFrame:CGRectMake(base + width * 0.5, base , 119*0.8, 114*0.8)];
    path = [[NSBundle mainBundle] pathForResource:@"png_lbutton_plan" ofType:@"png"];
    [rBtn setImage:[UIImage imageWithContentsOfFile:path] forState:UIControlStateNormal];
    [rBtn addTarget:self action:@selector(pushToRecure:) forControlEvents:UIControlEventTouchUpInside];
    self.recureButton = rBtn;
    [self.view addSubview:self.recureButton];
    
    UIButton* pBtn = [[UIButton alloc] initWithFrame:CGRectMake(base , base + height/4 ,  119*0.8, 114*0.8)];
    path = [[NSBundle mainBundle] pathForResource:@"png_lbutton_personalinfo" ofType:@"png"];
    [pBtn setImage:[UIImage imageWithContentsOfFile:path] forState:UIControlStateNormal];
    [pBtn addTarget:self action:@selector(pushToPerson:) forControlEvents:UIControlEventTouchUpInside];
    self.personButton = pBtn;
    [self.view addSubview:self.personButton];
    
    UIButton* cBtn = [[UIButton alloc] initWithFrame:CGRectMake(base + width * 0.5, base + height/4, 119 * 0.8, 114 * 0.8)];
    path = [[NSBundle mainBundle]pathForResource:@"png_lbutton_guestbook" ofType:@"png"];
    [cBtn setImage:[UIImage imageWithContentsOfFile:path] forState:UIControlStateNormal];
    [cBtn addTarget:self action:@selector(pushToComm:) forControlEvents:UIControlEventTouchUpInside];
    self.communicationButton = cBtn;
    [self.view addSubview:self.communicationButton];
    
    UIButton* dBtn = [[UIButton alloc] initWithFrame:CGRectMake(base , base + height/2, 119*0.8, 114*0.8)];
    path = [[NSBundle mainBundle]pathForResource:@"png_lbutton_chart" ofType:@"png"];
    [dBtn setImage:[UIImage imageWithContentsOfFile:path] forState:UIControlStateNormal];
    [dBtn addTarget:self action:@selector(pushToData:) forControlEvents:UIControlEventTouchUpInside];
    self.dataButton = dBtn;
    [self.view addSubview:self.dataButton];
    
    if( [downloadFlag isEqualToString:@"first"] ){
        downloadFlag = @"second";
        [self checkUpdateAndDownloadList];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)disableAndEnableAllButtons:(BOOL) able
{
    self.todayButton.enabled = able;
    self.recureButton.enabled = able;
    self.personButton.enabled = able;
    self.communicationButton.enabled = able;
    self.dataButton.enabled = able;
    self.navigationItem.rightBarButtonItem.enabled = able;
}



- (NSString* )dataFilePath:(NSString *)fileName
{
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* path = [paths objectAtIndex:0];
    return [path stringByAppendingPathComponent:fileName];
}

- (void)checkUpdateAndDownloadList //更新数据库资料
{
    sqlite3* database;
    if( sqlite3_open([[self dataFilePath:dataBaseName] UTF8String],&database) != SQLITE_OK ){
        sqlite3_close(database);
        NSAssert(0, @"failed to open database");
    }
    //获得邮戳
    int stamp[3];
    NSString* query = @"SELECT latest FROM status ORDER BY sid;";
    sqlite3_stmt* statement;
    if( sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil) == SQLITE_OK ){
        int cnt = 0;
        while( sqlite3_step(statement) == SQLITE_ROW ){
            stamp[cnt++] = sqlite3_column_int(statement, 0);
            
        }
    }else{
        NSLog(@"prepare failed");
    }
    if( ![self queue] )
        self.queue = [[NSOperationQueue alloc]init];
    [self.queue setMaxConcurrentOperationCount:1];
    //检查锻炼项目有无更新
    ASIHTTPRequest* r1 = [self checkExerciseUpdate:stamp[0]];
    //检查问卷有无更新
    ASIHTTPRequest* r2 = [self checkQuestionUpdate:stamp[1]];
    //检查视频有无更新
    ASIHTTPRequest* r3 = [self checkVideoUpdate:stamp[2]];
    //获取今天的任务
    ASIHTTPRequest *r4 = [self createTodayConnect];
    //获取锻炼状态
    ASIHTTPRequest *r5 = [self createFinishConnect];
    //获取问卷
    ASIHTTPRequest *r6 = [self GetTodayQuestions];
    [self.queue addOperation:r1];
    [self.queue addOperation:r2];
    [self.queue addOperation:r3];
    [self.queue addOperation:r4];
    [self.queue addOperation:r5];
    [self.queue addOperation:r6];
}

- (ASIHTTPRequest *) checkExerciseUpdate:(int)stamp
{
    NSString* address = [NSString stringWithFormat:@"%@%d",@"http://myehealth.sinaapp.com/API/checkExerciseUpdate?stamp=",stamp];
    NSURL* url = [NSURL URLWithString:address];
    ASIHTTPRequest* requset = [[ASIHTTPRequest alloc]initWithURL:url];
    [requset setDelegate:self];
    [requset setDidFinishSelector:@selector(checkExerciseDone:)];
//    [requset startAsynchronous];
    return requset;
}

- (ASIHTTPRequest *) checkQuestionUpdate:(int)stamp
{
    NSString* address = [NSString stringWithFormat:@"%@%d",@"http://myehealth.sinaapp.com/API/checkQuestionUpdate?stamp=",stamp];
    NSURL* url = [NSURL URLWithString:address];
    ASIHTTPRequest* requset = [[ASIHTTPRequest alloc]initWithURL:url];
    [requset setDelegate:self];
    [requset setDidFinishSelector:@selector(checkQuestionDone:)];
//    [requset startAsynchronous];
    return requset;
}

- (ASIHTTPRequest *) checkVideoUpdate:(int)stamp
{
    NSString* address = [NSString stringWithFormat:@"%@%d",@"http://myehealth.sinaapp.com/API/checkVideoUpdate?stamp=",stamp];
    NSURL* url = [NSURL URLWithString:address];
    ASIHTTPRequest* requset = [[ASIHTTPRequest alloc]initWithURL:url];
    [requset setDelegate:self];
    [requset setDidFinishSelector:@selector(checkVideoDone:)];
    return requset;
}

- (void) downloadVieo:(NSString* )videoName
{
    NSString* filename = [NSString stringWithFormat:@"%@%@",@"http://myehealth.sinaapp.com/Public/",videoName];
    NSURL* url = [NSURL URLWithString:filename];
    ASIHTTPRequest* request = [[ASIHTTPRequest alloc]initWithURL:url];
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* path = [paths objectAtIndex:0];
    path = [path stringByAppendingPathComponent:videoName];
    NSLog(@"%@",path);
    [request setDownloadDestinationPath:path];
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(videoFinish:)];
    [self.queue addOperation:request];
}

#pragma Button Methods
- (void)pushToPerson:(id)sender
{
    EPersonViewController* personVC = [[EPersonViewController alloc]init];
    [self.navigationController pushViewController:personVC animated:YES];
}

- (void)pushToRecure:(id)sender
{
    ERecureViewController* recureVC = [[ERecureViewController alloc]initWithStyle:UITableViewStyleGrouped];
    [self.navigationController pushViewController:recureVC animated:YES];
}

- (void)pushToToday:(id)sender
{
    ETodayViewController* tVC = [[ETodayViewController alloc]init];
    [self.navigationController pushViewController:tVC animated:YES];
}

- (void)pushToData:(id)sender
{
    EDrawViewController* dVC= [[EDrawViewController alloc]init];
    [self.navigationController pushViewController:dVC animated:YES];
}

- (void)pushToComm:(id)sender
{
    ECommunicationViewController *CVC = [[ECommunicationViewController alloc]init];
    [self.navigationController pushViewController:CVC animated:YES];
}

#pragma mark - ASIHTTPRequest
- (void)requestStarted:(ASIHTTPRequest *)request{
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
    [self disableAndEnableAllButtons:NO];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    [SVStatusHUD showWithImage:nil status:@"当前网络有问题~"];
    if( self.spin )
        [self.spin removeFromSuperview];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    if( self.spin )
        [self.spin removeFromSuperview];
    
}

- (void)checkExerciseDone:(ASIHTTPRequest *)request
{
    NSData* data = [request responseData];
    NSError* error = [[NSError alloc]init];
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    NSArray* array = [json objectForKey:@"exercises"];
    NSString* rc= [NSString stringWithFormat:@"%@",[json objectForKey:@"rc"]];
    NSString* COUNT = [NSString stringWithFormat:@"%@",[json objectForKey:@"count"]];
    
    if( [rc isEqualToString:@"0"] && ![COUNT isEqualToString:@"0"] ){
        sqlite3* database;
        if( sqlite3_open([[self dataFilePath:dataBaseName] UTF8String], &database) != SQLITE_OK ){
            sqlite3_close(database);
            NSAssert(0, @"failed to open database");
        }
        for( int i = 0; i < [array count]; i++ ){
            NSString* eid = [array[i] objectForKey:@"eid"];
            NSString* exerciseName = [array[i] objectForKey:@"exerciseName"];
            NSString* video = [array[i] objectForKey:@"video"];
            NSString* exerciseDescription = [array[i] objectForKey:@"exerciseDescription"];
            NSString* standardTime = [array[i] objectForKey:@"standardTime"];
            
            NSString* update = @"INSERT OR REPLACE INTO exercise (eid, standardTime, exerciseName, video,exerciseDescription)"
                                "VALUES(?,?,?,?,?)";
            sqlite3_stmt* statement;
            if( sqlite3_prepare_v2(database, [update UTF8String], -1, &statement, nil) == SQLITE_OK ){
                sqlite3_bind_int(statement, 1, [eid intValue]);
                sqlite3_bind_text(statement, 2, [standardTime UTF8String], -1, NULL);
                sqlite3_bind_text(statement, 3, [exerciseName UTF8String], -1, NULL);
                sqlite3_bind_text(statement, 4, [video UTF8String], -1, NULL);
                sqlite3_bind_text(statement, 5, [exerciseDescription UTF8String], -1, NULL);
            }
            if( sqlite3_step(statement) != SQLITE_DONE ){
                NSAssert(0, @"Error updating table");
            }
            sqlite3_finalize(statement);
            NSLog(@"update");
        }
        NSString* newStamp = [json objectForKey:@"latest"];
        NSString* update = @"INSERT OR REPLACE INTO status (sid,tableName,latest) VAlUES(?,?,?);";
        sqlite3_stmt* statement;
        if( sqlite3_prepare_v2(database, [update UTF8String], -1, &statement, nil) == SQLITE_OK ){
            sqlite3_bind_int(statement, 1, 1);
            sqlite3_bind_text(statement, 2, "exercise", -1, NULL);
            sqlite3_bind_int(statement, 3, [newStamp intValue]);
        }
        if( sqlite3_step(statement) != SQLITE_DONE ){
            NSAssert(0, @"Error updating table");
        }
        sqlite3_finalize(statement);
        sqlite3_close(database);
    }
    if( self.spin )
        [self.spin removeFromSuperview];
    
    if( [self.queue operationCount] == 0 )
        [self disableAndEnableAllButtons:YES];
}

- (void)checkQuestionDone:(ASIHTTPRequest *)request
{
    NSData* data = [request responseData];
    NSError* error = [[NSError alloc]init];
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    NSArray* array = [json objectForKey:@"questions"];
    NSString* rc= [NSString stringWithFormat:@"%@",[json objectForKey:@"rc"]];
    NSString* COUNT = [NSString stringWithFormat:@"%@",[json objectForKey:@"count"]];
    
    if( [rc isEqualToString:@"0"] && ![COUNT isEqualToString:@"0"] ){
        sqlite3* database;
        if(  sqlite3_open([[self dataFilePath:dataBaseName] UTF8String], &database) != SQLITE_OK ){
            sqlite3_close(database);
            NSAssert(0, @"failed to open database");
        }
        
        for (int i = 0; i < [array count]; i++) {
            NSString* qid = [array[i] objectForKey:@"qid"];
            NSString* questionContent = [array[i] objectForKey:@"questionContent"];
            NSString* score = [array[i] objectForKey:@"score"];
            
            NSString* update = @"INSERT OR REPLACE INTO question (qid, questionContent, score) VALUES(?, ?, ?);";
            sqlite3_stmt* statement;
            if( sqlite3_prepare_v2(database, [update UTF8String], -1, &statement, nil) == SQLITE_OK ){
                sqlite3_bind_int(statement, 1, [qid intValue]);
                sqlite3_bind_text(statement, 2, [questionContent UTF8String], -1, NULL);
                sqlite3_bind_int(statement, 3, [score intValue]);
            }
            if( sqlite3_step(statement) != SQLITE_DONE )
                NSAssert(0, @"Error updating table");
            sqlite3_finalize(statement);
            NSLog(@"question");
        }

        NSString* latest = [json objectForKey:@"latest"];
        NSString* update = @"INSERT OR REPLACE INTO status (sid,tableName,latest) VAlUES(?,?,?);";
        sqlite3_stmt* statement;
        if( sqlite3_prepare_v2(database, [update UTF8String], -1, &statement, NULL) == SQLITE_OK ){
            sqlite3_bind_int(statement, 1, 2);
            sqlite3_bind_text(statement, 2, "question", -1, NULL);
            sqlite3_bind_int(statement, 3, [latest intValue]);
        }
        if( sqlite3_step(statement) != SQLITE_DONE )
                NSAssert(0, @"error to update");
        sqlite3_finalize(statement);
        NSLog(@"question");
        sqlite3_close(database);
    }
    if( self.spin )
        [self.spin removeFromSuperview];
    
    if( [self.queue operationCount] == 0 )
        [self disableAndEnableAllButtons:YES];
}

- (void)checkVideoDone:(ASIHTTPRequest *)request
{
    NSData* data = [request responseData];
    NSError* error = [[NSError alloc]init];
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    NSArray* array = [json objectForKey:@"video"];
    NSString* rc= [NSString stringWithFormat:@"%@",[json objectForKey:@"rc"]];
    NSString* COUNT = [NSString stringWithFormat:@"%@",[json objectForKey:@"count"]];
    
    if( [rc isEqualToString:@"0"] && ![COUNT isEqualToString:@"0"] ){
        
        videoLatest = [json objectForKey:@"latest"];
        
        for( int i = 0; i < [array count]; i++ ){
            NSString* name = array[i];
            [self downloadVieo:name];
            
        }
    }
    if( self.spin )
        [self.spin removeFromSuperview];
    
    if( [self.queue operationCount] == 0 )
        [self disableAndEnableAllButtons:YES];

    
}

- (void)videoFinish:(ASIHTTPRequest *)request
{
    if( [self.queue operationCount] == 0 ){
        
        
        sqlite3* database;
        if( sqlite3_open([[self dataFilePath:dataBaseName]UTF8String], &database ) != SQLITE_OK ){
            sqlite3_close(database);
            NSAssert(0, @"failed to open database");
        }
        NSString* update = @"INSERT OR REPLACE INTO status (sid, tableName, latest) VALUES (?,?,?);";
        sqlite3_stmt* statement;
        if( sqlite3_prepare(database, [update UTF8String], -1, &statement, NULL) == SQLITE_OK ){
            sqlite3_bind_int(statement, 1, 3);
            sqlite3_bind_text(statement, 2, "video", -1, NULL);
            sqlite3_bind_int(statement, 3, [videoLatest intValue]);
        }
        if( sqlite3_step(statement) != SQLITE_DONE ){
            NSAssert(0, @"error to udpdate databse");
        }
        sqlite3_finalize(statement);
    }
    
    [self.spin removeFromSuperview];
    [self disableAndEnableAllButtons:YES];

}

#pragma mark - init Model


//获取今日计划
- (ASIHTTPRequest *)createTodayConnect
{
    NSString* pid = nil;
    if( [[NSFileManager defaultManager] fileExistsAtPath:[self dataFilePath:personFile]] ){
        NSArray* tempArray = [NSArray arrayWithContentsOfFile:[self dataFilePath:personFile]];
        pid = tempArray[2];
    }
    NSString* add =[NSString stringWithFormat:@"%@%@",@"http://myehealth.sinaapp.com/API/getPlans?pid=",pid];
    NSURL* url = [NSURL URLWithString:add];
    ASIHTTPRequest* request = [[ASIHTTPRequest alloc]initWithURL:url];
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(todayDownload:)];

    return request;
}

- (void)todayDownload:(ASIHTTPRequest *)request
{
    NSData* data = [request responseData];
    NSError* error = [[NSError alloc]init];
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    NSArray* dataArray = [json objectForKey:@"plans"];
    NSNumber *rc = [json objectForKey:@"rc"];
    if( [rc isEqual:@0] ){
        EPatientModel *singleton = [EPatientModel sharedEPatientModel];
        singleton.todayExercise = [[NSMutableArray alloc]init];
        singleton.unFinish = [[NSMutableArray alloc]init];
        for( int i = 0; i < [dataArray count]; i++ ){
            [singleton.todayExercise addObject:dataArray[i]];

            [singleton.unFinish addObject:dataArray[i]];
        }
    }
    if( self.spin )
        [self.spin removeFromSuperview];
    
    if( [self.queue operationCount] == 0 )
        [self disableAndEnableAllButtons:YES];
}

- (ASIHTTPRequest *)createFinishConnect
{
    NSString* pid = nil;
    if( [[NSFileManager defaultManager] fileExistsAtPath:[self dataFilePath:personFile]] ){
        NSArray* tempArray = [NSArray arrayWithContentsOfFile:[self dataFilePath:personFile]];
        pid = tempArray[2];
    }
    NSString* add =[NSString stringWithFormat:@"%@%@",@"http://myehealth.sinaapp.com/API/getPlanStatus?pid=",pid];
    NSURL* url = [NSURL URLWithString:add];
    ASIHTTPRequest* request = [[ASIHTTPRequest alloc]initWithURL:url];
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(finishDownload:)];

    return request;
}

- (void)finishDownload:(ASIHTTPRequest *)request
{
    NSData* data = [request responseData];
    NSError* error = [[NSError alloc]init];
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    NSArray* dataArray = [json objectForKey:@"finished"];
    NSNumber *rc = [json objectForKey:@"rc"];
    if( [rc isEqual:@0] ){
        EPatientModel *singleton = [EPatientModel sharedEPatientModel];
        
        //改变当天的已完成、未完成
        singleton.finish = [[NSMutableArray alloc]init];
        for( int i = 0; i < [dataArray count]; i++ ){
            [singleton.finish addObject:dataArray[i]];
            for( int j = 0; j < [singleton.unFinish count]; j++ ){
                NSString *eid = [singleton.unFinish[j] objectForKey:@"eid"];
                if( [eid isEqualToString:dataArray[i]] ){

                    [singleton.unFinish removeObjectAtIndex:j];
                    break;
                }
            }
        }
        
        //是否填写了问卷
        NSNumber *feedbacked = [json objectForKey:@"feedbacked"];
        singleton.questionFlag = [feedbacked intValue];
        
    }
    if( self.spin )
        [self.spin removeFromSuperview];
    
    if( [self.queue operationCount] == 0 )
        [self disableAndEnableAllButtons:YES];
}


- (ASIHTTPRequest *)GetTodayQuestions
{
    NSString* pid = nil;
    if( [[NSFileManager defaultManager] fileExistsAtPath:[self dataFilePath:personFile]] ){
        NSArray* tempArray = [NSArray arrayWithContentsOfFile:[self dataFilePath:personFile]];
        pid = tempArray[2];
    }
    NSString* add =[NSString stringWithFormat:@"%@%@",@"http://myehealth.sinaapp.com/API/getFeedbacks?pid=",pid];
    NSURL* url = [NSURL URLWithString:add];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setDelegate: self];
    [request setDidFinishSelector:@selector(questionsFinish:)];
    return request;
}

- (void)questionsFinish:(ASIHTTPRequest *)request
{
    NSData *data = [request responseData];
    NSError *error = [NSError new];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error ];
    NSNumber *rc = [json objectForKey:@"rc"];
    
    if( [rc isEqualToNumber:@0] ){
        NSArray *array = [json objectForKey:@"feedbacks"];
        EPatientModel *singleton = [EPatientModel sharedEPatientModel];
        singleton.questions = [[NSMutableArray alloc]init];
        for( int i = 0; i < [array count]; i++ ){
            NSNumber *qid = [array[i] objectForKey:@"qid"];
            [singleton.questions addObject:qid];
        }
        for (int i = 0 ; i < [singleton.questions count]; i++)
            NSLog(@"%@",singleton.questions[i]);
    }
    if( self.spin )
        [self.spin removeFromSuperview];
    
    if( [self.queue operationCount] == 0 )
        [self disableAndEnableAllButtons:YES];
}

- (void)checkAndDeleteTodayNoti
{
    EPatientModel *singleton = [EPatientModel sharedEPatientModel];
    if( [singleton.unFinish count] != 0 )
        return;
    
    //删除今天的所有noti;
    NSDateFormatter *formatter1 = [[NSDateFormatter alloc]init];
    [formatter1 setDateFormat:@"MM-dd"];
    NSDate *date = [NSDate date];
    NSString *todayDateString = [formatter1 stringFromDate:date];
    
    UIApplication *application = [UIApplication sharedApplication];
    NSArray *notis = [application scheduledLocalNotifications];
    
    for( UILocalNotification *noti in notis ){
        NSDictionary *info =  noti.userInfo;
        NSString *sDate = [info objectForKey:@"date"];
        if( [sDate isEqualToString:todayDateString] )
            [application cancelLocalNotification:noti];
    }
    
}

@end
