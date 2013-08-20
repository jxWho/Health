//
//  ERecureViewController.m
//  eHealth
//
//  Created by god on 13-4-13.
//  Copyright (c) 2013年 god. All rights reserved.
//

#import "ERecureViewController.h"
#import "ASIHeaders.h"
#import "SVStatusHUD.h"
#define planFile @"plan.plist"
#define personFile @"person.plist"
#define dataBaseName   @"ehealth.db"

#import "EActionSheetDatePicker.h"
#import "EAbstarctActionSheetPicker.h"
#import "NSDate+TCUtils.h"
#import "EPatientModel.h"

@interface ERecureViewController ()<ASIHTTPRequestDelegate>

@property (nonatomic, retain) EAbstarctActionSheetPicker *actionSheetPicker;
@property (nonatomic, retain) NSDate *selectedDate;

@end


@implementation ERecureViewController

@synthesize Plan,spin;
@synthesize actionSheetPicker = _actionSheetPicker;
@synthesize selectedDate = _selectedDate;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIImage* bgview = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"png_background2" ofType:@"png"]];
    self.view.backgroundColor = [UIColor colorWithPatternImage:bgview];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //设置用户默认值
    NSDictionary *defaults = [NSDictionary dictionaryWithObjectsAndKeys:@"设置提醒时间",@"alertTime", nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
    
    self.Plan = [EPatientModel sharedEPatientModel].todayExercise;
    self.navigationItem.title = @"我的康复计划";
//    [self Getplan];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString* )dataFilePath:(NSString *)fileName
{
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* path = [paths objectAtIndex:0];
    return [path stringByAppendingPathComponent:fileName];
}

-(void)Getplan
{
    [self downloadData];
}

- (void)downloadData
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
    [request startAsynchronous];
}



- (void)reloadListData
{
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    if(section == 0)
        return 1;
    else
        return [self.Plan count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *NotiCellIdentifier = @"NotiCell";
    static NSString *planCell = @"planCell";
    if( indexPath.section == 0 ){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NotiCellIdentifier ];
        if( cell == NULL )
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NotiCellIdentifier ];
        
        NSUserDefaults *defaluts = [NSUserDefaults standardUserDefaults];
        NSString *alertTime = [defaluts objectForKey:@"alertTime"];
        if( alertTime == nil )
            cell.textLabel.text = @"设置提醒时间"; 
        else
            cell.textLabel.text = [NSString stringWithFormat:@"%@%@",@"提醒时间为:  ",alertTime];
        
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        return cell;
    }else{
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:planCell];
        if( cell == nil )
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:planCell];
        int num = indexPath.row;
        
        NSString* eid = (NSString *)[self.Plan[num] objectForKey:@"eid"];
        
        sqlite3* database;
        NSString* databasePath = [self dataFilePath:dataBaseName];
        if (sqlite3_open([databasePath UTF8String], &database) != SQLITE_OK ) {
            sqlite3_close(database);
            NSAssert(0, @"Failed to open database");
        }
        NSString* query = [NSString stringWithFormat:@"%@%@",@"SELECT exerciseName, exerciseDescription FROM exercise WHERE eid = ",eid];
        sqlite3_stmt* statement;
        NSString* title;
        NSString* detail;
        if( sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil) == SQLITE_OK ){
            while ( sqlite3_step(statement) == SQLITE_ROW ){
                char* a = (char *)sqlite3_column_text(statement, 0);
                char* b = (char *)sqlite3_column_text(statement, 1);
                
                title = [[NSString alloc] initWithUTF8String:a];
                detail = [[NSString alloc] initWithUTF8String:b];
            }
        }
        cell.textLabel.text = title;
        cell.detailTextLabel.text = detail;
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        return cell;
    }
    
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if( section == 0 )
    {
        return @"提醒参数设定";
    }else{
        return @"我的康复计划列表";
    }
}



- (void)dateWasSelected:(NSDate *)date
{
    self.selectedDate = date;
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"HH:mm"];

    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:[formatter stringFromDate:date] forKey:@"alertTime"];
    [self.tableView reloadData];
    
    //重新设置提醒
    [self addNoti];
}


- (void)addNoti
{
    /*
        先删除所有的提醒，再重新构造
     */
    UIApplication *app  = [UIApplication sharedApplication];
    [app cancelAllLocalNotifications];
    
    NSString *settingTime = [[NSUserDefaults standardUserDefaults] objectForKey:@"alertTime"];
    if( [settingTime isEqualToString:@"提醒时间为:  设置提醒时间"] || settingTime == nil )
        settingTime = @"12:00";
    
    NSDate *date1 = [NSDate date];
    NSDateFormatter *formatter1 = [[NSDateFormatter alloc]init];
    [formatter1 setDateFormat:@"MM-dd"];
    
    for( int i = 0; i < 3; i++ ){   //同时创建三个
        
        UILocalNotification *noti = [[UILocalNotification alloc]init];
        NSLog(@"create");
        
        if( noti ){
            NSDate *date = [NSDate date];
            
            NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
            [formatter setDateFormat:@"yyyy-MM-dd"];
            NSString *dateString = [formatter stringFromDate:date];
            dateString = [NSString stringWithFormat:@"%@-%@-%@-%@",dateString,@"00",@"00",@"00"];
            [formatter setDateFormat:@"yyyy-MM-dd-HH-mm-ss"];
            date = [formatter dateFromString:dateString];
            NSArray *chunk = [settingTime componentsSeparatedByString:@":"];
            NSTimeInterval timeInterval = [date timeIntervalSince1970];
            timeInterval += 24 * 3600;
            timeInterval += [(NSString *)chunk[0] intValue] * 3600;
            timeInterval += [chunk[1] intValue] * 60;
            timeInterval += i * 600;
            NSLog(@"%d %d",[chunk[0] intValue], [chunk[1] intValue]);
            noti.fireDate = [NSDate dateWithTimeIntervalSince1970:timeInterval];
            noti.timeZone = [NSTimeZone defaultTimeZone];
            noti.soundName = UILocalNotificationDefaultSoundName;
            noti.alertBody = @"今天的锻炼时间到啦~~~";
            noti.alertAction = @"进入锻炼";
//            noti.repeatInterval = NSDayCalendarUnit;
            noti.applicationIconBadgeNumber =  1;
            NSDictionary *infoDic = [NSDictionary dictionaryWithObjectsAndKeys:[formatter1 stringFromDate:date1],@"date", nil];
            noti.userInfo = infoDic;
            [app scheduleLocalNotification:noti];
        }
    }

}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int section = indexPath.section;
    if( section == 0 ){
        if( self.selectedDate == nil )
            self.selectedDate = [NSDate date];
        _actionSheetPicker = [[EActionSheetDatePicker alloc] initWithTitle:@"" datePickerMode:UIDatePickerModeTime selectedDate:self.selectedDate target:self action:@selector(dateWasSelected:) origin:[tableView cellForRowAtIndexPath:indexPath]];
        self.actionSheetPicker.hideCancel = YES;
        [self.actionSheetPicker showActionSheetPicker];
    }else{
        int row = indexPath.row;
        NSString* eid = [self.Plan[row] objectForKey:@"eid"];
        ERecureDetailViewController* nextVC = [[ERecureDetailViewController alloc]init];
        [nextVC setValue:eid forKey:@"eid"];
//        [self.navigationController presentViewController:nextVC animated:YES completion:^{}];
        UINavigationController *nv = [[UINavigationController alloc]initWithRootViewController:nextVC];
        [self.navigationController presentViewController:nv animated:YES completion:^{}];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}



#pragma mark - ASIHTTPRequest Method
- (void)requestStarted:(ASIHTTPRequest *)request
{
    UIActivityIndicatorView* t  = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [t setCenter:self.view.center];
    [t setBackgroundColor:[UIColor blackColor]];
    [t setAlpha:0.8];
    t.layer.cornerRadius = 8;
    t.layer.masksToBounds = YES;
    self.spin = t;
    
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

- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSData* data = [request responseData];
    NSError* error = [[NSError alloc]init];
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];

    NSArray* pArray = [json objectForKey:@"plans"];
    int cnt = [pArray count];
    for( int i = 0; i < cnt; i++ )
        [self.Plan addObject:pArray[i]];
    [self.spin removeFromSuperview];
    [self reloadListData];

}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    [SVStatusHUD showWithImage:nil status:@"当前网络有问题~"];
    if( self.spin )
        [self.spin removeFromSuperview];
}

@end
