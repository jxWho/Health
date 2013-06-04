//
//  EToday2ViewController.m
//  eHealth
//
//  Created by god on 13-4-13.
//  Copyright (c) 2013年 god. All rights reserved.
//

#import "EToday2ViewController.h"
#import "SVStatusHUD.h"
#import "ASIHeaders.h"
#import <QuartzCore/QuartzCore.h>
#import <sqlite3.h>
#define dataBaseName   @"ehealth.db"
#define personFile @"person.plist"
#import "EPatientModel.h"


@interface EToday2ViewController ()<UITableViewDataSource,UITableViewDelegate, ASIHTTPRequestDelegate>

@end

@implementation EToday2ViewController
@synthesize Finished, spin;

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

    CGFloat navHeight = self.navigationController.navigationBar.bounds.size.height;

    UITableView* listView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - 49 - navHeight)];
    [listView setDataSource:self];
    [listView setDelegate:self];
    [listView setTag:1];
    [self.view addSubview:listView];
}



- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:NO];
    
    
    self.Finished = [EPatientModel sharedEPatientModel].finish;
    

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:NO];
    
    self.Finished = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSString *)dataFilePath:(NSString *)fileName
{
    NSString* path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    return [path stringByAppendingPathComponent:fileName];
}

- (void)createConnectUnfinish
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

- (void)reloadListData
{
   UITableView* tV = (UITableView *)[self.view viewWithTag:1];
    [tV reloadData];
}

#pragma mark - UITableView DataSource
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.Finished count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* cellIdentifier = @"finishCell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if( !cell )
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    
    sqlite3* database;
    if( sqlite3_open([[self dataFilePath:dataBaseName] UTF8String], &database) != SQLITE_OK ){
        sqlite3_close(database);
        NSAssert(0, @"failed to open database");
    }
    NSInteger row = indexPath.row;
    NSString* eid = self.Finished[row];
    NSString* query = [NSString stringWithFormat:@"%@%@",@"SELECT exerciseName, exerciseDescription FROM exercise WHERE eid = ",eid];
    sqlite3_stmt* statement;
    NSString* title;
    NSString* detail;
    if( sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, NULL) == SQLITE_OK ){
        while(sqlite3_step(statement) == SQLITE_ROW){
            char* t = (char *)sqlite3_column_text(statement, 0);
            char* d = (char *)sqlite3_column_text(statement, 1);
            title = [NSString stringWithUTF8String:t];
            detail = [NSString stringWithUTF8String:d];
        }
    }
    sqlite3_finalize(statement);
    sqlite3_close(database);
    cell.textLabel.text = title;
    cell.detailTextLabel.text = detail;
    return cell;
}

#pragma mark - UItableViewDelegate Method

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - ASIHttpRequest Method
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
    [self.spin becomeFirstResponder];}

- (void)finishDownload:(ASIHTTPRequest *)request
{
    NSData* data = [request responseData];
    NSError* error = [[NSError alloc]init];
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    NSLog(@"%@",json);
    NSArray* dataArray = [json objectForKey:@"finished"];
    for (int i = 0; i < [dataArray count]; i++) {
        [self.Finished addObject:dataArray[i]];
    }
    UITableView *tView = (UITableView *)[self.view viewWithTag:1];
    [tView reloadData];
    [self.spin removeFromSuperview];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    [SVStatusHUD showWithImage:nil status:@"当前网络有问题~"];
    if( self.spin )
        [self.spin removeFromSuperview];
}

@end
