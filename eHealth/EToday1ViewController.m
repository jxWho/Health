//
//  EToday1ViewController.m
//  eHealth
//
//  Created by god on 13-4-13.
//  Copyright (c) 2013年 god. All rights reserved.
//

#import "EToday1ViewController.h"
#import "EQuestionViewController.h"
#import <QuartzCore/QuartzCore.h>
#define dataBaseName   @"ehealth.db"
#import "SVStatusHUD.h"
#define personFile @"person.plist"
#import "EPatientModel.h"

@interface EToday1ViewController ()<UITableViewDelegate, UITableViewDataSource, EMedia>

@end

@implementation EToday1ViewController


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

    self.view.backgroundColor = [UIColor whiteColor];
    CGFloat width = self.view.bounds.size.width;
    CGFloat height = self.view.bounds.size.height;
    UITableView* listView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, width, height)];
    [listView setDelegate:self];
    [listView setDataSource:self];
    [listView setTag:1];
    [self.view addSubview:listView];
    
    self.todayList = [EPatientModel sharedEPatientModel].unFinish;
    [self reloadListData];
//    [self getToDoList];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)createConnect
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
    [request startAsynchronous];
}

- (void)createFinishConnect
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
    [request startAsynchronous];
}

- (NSString* )dataFilePath:(NSString* )fileName
{
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES );
    NSString* path = paths[0];
    return [path stringByAppendingPathComponent:fileName];
}



- (void)getToDoList
{
    [self createConnect];
}

- (void)reloadListData
{
    UITableView* a = (UITableView *)[self.view viewWithTag:1];
    [a reloadData];
}

#pragma mark - UITableView Data Source

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.todayList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* cellSymbol = @"ToDoCell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellSymbol];
    if( cell == nil ){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellSymbol];
    }
    int num = indexPath.row;
    //NSLog(@"%@",self.todayList[num]);
    
    NSString* eid = (NSString *)[self.todayList[num] objectForKey:@"eid"];
    
    sqlite3* database;
    NSString* databasePath = [self dataFilePath:dataBaseName];
    if (sqlite3_open([databasePath UTF8String], &database) != SQLITE_OK ) {
        sqlite3_close(database);
        NSAssert(0, @"Failed to open database");
    }
    NSString* query = [NSString stringWithFormat:@"%@%@;",@"SELECT exerciseName, exerciseDescription FROM exercise WHERE eid = ",eid];
    NSLog(query);
    sqlite3_stmt* statement;
    NSString* title;
    NSString* detail;
    if( sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil) == SQLITE_OK ){
        while ( sqlite3_step(statement) == SQLITE_ROW ){
            char* a = (char *)sqlite3_column_text(statement, 0);
            char* b = (char *)sqlite3_column_text(statement, 1);
            
            title = [[NSString alloc] initWithUTF8String:a];
            detail = [[NSString alloc] initWithUTF8String:b];
            NSLog(@"ok");
        }
    }
    sqlite3_finalize(statement);
    sqlite3_close(database);
    cell.textLabel.text = title;
    cell.detailTextLabel.text = detail;
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    return cell;
}

#pragma mark - UITableView Method
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //跳转到播放页面
    if( indexPath.row == 0 ){
        int row = indexPath.row;
        nowRow = [NSNumber numberWithInt:row];
        NSString* eid = [self.todayList[row] objectForKey:@"eid"];
        sqlite3* database;
        if( sqlite3_open([[self dataFilePath:dataBaseName] UTF8String], &database) != SQLITE_OK ){
            sqlite3_close(database);
            NSAssert(0, @"falied to open database");
        }
        NSString* query = [NSString stringWithFormat:@"%@%@;",@"SELECT video FROM exercise WHERE eid = ",eid];
        sqlite3_stmt* statemet;
        NSString* fileName;
        if( sqlite3_prepare_v2(database, [query UTF8String], -1, &statemet, NULL) == SQLITE_OK ){
            sqlite3_step(statemet);
            fileName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statemet, 0)];
        }
        sqlite3_finalize(statemet);
        sqlite3_close(database);
        NSString* path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        fileName = [path stringByAppendingPathComponent:fileName];
        NSString* COUNT = [self.todayList[row] objectForKey:@"count"];
        EMediaPlayViewController* nextVC = [[EMediaPlayViewController alloc]init];
        [nextVC setValue:fileName forKey:@"mediaFileName"];
        [nextVC setValue:COUNT forKey:@"count"];
        [nextVC setValue:[self.todayList[row] objectForKey:@"eid"] forKey:@"eid"];
        [nextVC setValue:self forKey:@"delegate"];
        [nextVC setValue:nowRow forKey:@"nowRow"];
        self.EMVP = nextVC;
        [self.navigationController pushViewController:self.EMVP animated:YES];
    }else{
        [SVStatusHUD showWithImage:nil status:@"请从第一项开始训练~~"];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}



#pragma mark - ASIHTTPRequst

- (void)requestStarted:(ASIHTTPRequest *)request
{
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



- (void)todayDownload:(ASIHTTPRequest *)request
{
    NSData* data = [request responseData];
    NSError* error = [[NSError alloc]init];
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    NSArray* dataArray = [json objectForKey:@"plans"];
    for( int i = 0; i < [dataArray count]; i++ )
        [self.todayList addObject:dataArray[i]];
    
    [self createFinishConnect];
    [self.spin removeFromSuperview];
}

- (void)finishDownload:(ASIHTTPRequest *)request
{
    NSData* data = [request responseData];
    NSError* error = [[NSError alloc]init];
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    NSArray* dataArray = [json objectForKey:@"finished"];
    for( int i = 0; i < [dataArray count]; i++ )
        for( int j = 0; j < [self.todayList count]; j++ ){
            NSString* eid = [self.todayList[j] objectForKey:@"eid"];
            if( [eid isEqualToString:dataArray[i]] ){
                [self.todayList removeObjectAtIndex:j];
                break;
            }
        }
    [self reloadListData];
    [self.spin removeFromSuperview];
    //NSLog(@"%d",[[json objectForKey:@"unfinished"] count]);
    
    //if finish all exercise ,then do question,make a noti to remaind the user
    if( [self.todayList count] == 0 )
        [SVStatusHUD showWithImage:nil status:@"记得填问卷哦~~~"];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    [SVStatusHUD showWithImage:nil status:@"当前网络有问题~"];
    if( self.spin )
        [self.spin removeFromSuperview];
}

#pragma mark - protoccol Method
- (void)goToNext
{
    NSLog(@"receive");
  
    UITableView* fatherView = (UITableView *)[self.view viewWithTag:1];
    
     
    int row = [nowRow intValue];
    row++;
    nowRow = [NSNumber numberWithInt:row];
    /*
    UITableViewCell* cell = [fatherView cellForRowAtIndexPath:iPath];
     */
    if( [self.todayList count] > 0 ){
        [self.todayList removeObjectAtIndex:0];
        
        EPatientModel *singleton = [EPatientModel sharedEPatientModel];
        NSDictionary *firstExercise = singleton.unFinish[0];
        [singleton.finish addObject:firstExercise];
        
    }
    [fatherView reloadData];
    
    if( [self.todayList count] > 0  ){
        
        NSString* eid = [self.todayList[0] objectForKey:@"eid"];

        sqlite3* database;
        if( sqlite3_open([[self dataFilePath:dataBaseName] UTF8String], &database) != SQLITE_OK ){
            sqlite3_close(database);
            NSAssert(0, @"falied to open database");
        }
        NSString* query = [NSString stringWithFormat:@"%@%@;",@"SELECT video FROM exercise WHERE eid = ",eid];
        sqlite3_stmt* statemet;
        NSString* fileName;
        if( sqlite3_prepare_v2(database, [query UTF8String], -1, &statemet, NULL) == SQLITE_OK ){
            sqlite3_step(statemet);
            char *tempSS = (char *)sqlite3_column_text(statemet, 0);
            NSLog(@"%s",tempSS);
            fileName = [NSString stringWithUTF8String:tempSS];
        }
        sqlite3_finalize(statemet);
        sqlite3_close(database);
        NSString* path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        fileName = [path stringByAppendingPathComponent:fileName];
        
        NSString* COUNT = [self.todayList[0] objectForKey:@"count"];

        [self.EMVP setValue:fileName forKey:@"mediaFileName"];
        [self.EMVP setValue:COUNT forKey:@"count"];
        [self.EMVP setValue:[self.todayList[0] objectForKey:@"eid"] forKey:@"eid"];
        [self.EMVP setValue:self forKey:@"delegate"];
        [self.EMVP setValue:nowRow forKey:@"nowRow"];
    }else{
        NSLog(@"no such cell");
        //进入问卷
        nowRow = @-1;
        [self.EMVP setValue:nowRow forKey:@"nowRow"];
    }
}

- (void)showQuestionNoti
{
    if( [self.todayList count] == 0 )
        [SVStatusHUD showWithImage:nil status:@"记得填问卷哦~~~"];
}

@end
