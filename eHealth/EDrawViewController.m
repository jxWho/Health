//
//  EDrawViewController.m
//  eHealth
//
//  Created by god on 13-4-20.
//  Copyright (c) 2013年 god. All rights reserved.
//

#import "EDrawViewController.h"
#define personFile @"person.plist"
#import "EActionSheetDatePicker.h"
#import "EAbstarctActionSheetPicker.h"
#import "SVStatusHUD.h"
#import "NSDate+TCUtils.h"

@interface EDrawViewController ()<ASIHTTPRequestDelegate>
{
    int Interval;
     NSDate *startDate;
}
@property (nonatomic, retain) EAbstarctActionSheetPicker *actionSheetPicker;
@property (nonatomic, retain) NSDate *selectedDate;

@end

@implementation EDrawViewController

@synthesize lineChartView, hArr, vArr, spin;
@synthesize actionSheetPicker = _actionSheetPicker;
@synthesize selectedDate = _selectedDate;
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
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"设置起始日期" style:UIBarButtonItemStylePlain target:self action:@selector(setStartDate:)];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewWillAppear:(BOOL)animated
{
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"dd/MM/YYYY"];
    NSString *eDate = [dateFormatter stringFromDate:currentDate];
    NSInteger eMiao = [currentDate timeIntervalSince1970];
    Interval = 10;
    eMiao = eMiao - Interval * 24 * 3600;
    NSDate *SDate = [NSDate dateWithTimeIntervalSince1970:eMiao];
    NSString *sDate = [dateFormatter stringFromDate:SDate];
    startDate = SDate;
    
    NSString* pid = nil;
    if( [[NSFileManager defaultManager] fileExistsAtPath:[self dataFilePath:personFile]] ){
        NSArray* tempArray = [NSArray arrayWithContentsOfFile:[self dataFilePath:personFile]];
        pid = tempArray[2];
    }
    
    
    
     
    [self createConnectAtPid:pid startAt:sDate endAt:eDate];
}


- (NSString* )dataFilePath:(NSString *)fileName
{
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* path = [paths objectAtIndex:0];
    return [path stringByAppendingPathComponent:fileName];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)createConnectAtPid:(NSString *)PID startAt:(NSString *)BDate endAt:(NSString *)EDate
{
    NSString *splitBDate = [BDate copy];
    [splitBDate componentsSeparatedByString:@"/"];
    NSString *splitEDate = [EDate copy];
    [splitEDate componentsSeparatedByString:@"/"];
    NSString* add = [NSString stringWithFormat:@"%@%@&begDate=%@&endDate=%@",@"http://myehealth.sinaapp.com/API/getDayRecords?pid=",PID,BDate,EDate];
    NSLog(add);
    NSURL *url = [NSURL URLWithString:add];
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc]initWithURL:url];
    [request setDelegate:self];
    [request startAsynchronous];
}


#pragma mark - ASIHTTPRequst Methods

-(void)requestStarted:(ASIHTTPRequest *)request
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

- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSData* data = [request responseData];
    NSError *error = [[NSError alloc]init];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    NSString *rc = [json objectForKey:@"rc"];
    if( [rc intValue] == 0 ){
        
        
        
        
        ELineChartView *LCV = [[ELineChartView alloc]initWithFrame:self.view.frame];
        self.lineChartView = LCV;
        NSInteger pp = [[UIScreen mainScreen]bounds].size.width /11;
        [self.lineChartView setVInterval:pp];
        self.vArr = [[NSMutableArray alloc]init];
        self.hArr = [[NSMutableArray alloc]init];
        self.pointArr = [[NSMutableArray alloc]init];
        float k = 0;
        for( int i = 0; i <= 5; i++ ){
            [self.vArr addObject:[NSString stringWithFormat:@"%.1f",k]];
            k += 0.2;
        }
        
        
        
        //下面是构造图表的方法
        int recordCount = [[json objectForKey:@"count"] intValue];
        NSDateFormatter *formatter1 = [[NSDateFormatter alloc]init];
        NSDateFormatter *formatter2 = [[NSDateFormatter alloc]init];
        [formatter1 setDateFormat:@"dd/MM"];
        [formatter2 setDateFormat:@"YYYY-MM-dd"];
        
        
        if( recordCount > 0 ){
            NSArray *records = [json objectForKey:@"records"];
            
            while ([self.pointArr count] > 0 )
                [self.pointArr removeLastObject];
            
            for( int i = 0; i < Interval; i++ ){
                NSInteger miao = [startDate timeIntervalSince1970] + i * 24 * 3600 ;
                NSDate *newDate = [NSDate dateWithTimeIntervalSince1970:miao];
                NSString *standardDate = [formatter2 stringFromDate:newDate];
                BOOL tempFlag = NO;
                for( int j = 0; j < [records count]; j++ )
                    if( [standardDate isEqualToString:[records[j] objectForKey:@"date"]] ){
                        NSLog(standardDate);
                        float rate = [[records[j] objectForKey:@"rate"] floatValue];
                        NSLog(@"%.1f",rate);
                        [self.pointArr addObject:[NSValue valueWithCGPoint:CGPointMake(self.lineChartView.vInterval * i, rate * 100)]];
                        tempFlag = YES;
                        break;
                    }
                if( !tempFlag )
                    [self.pointArr addObject:[NSValue valueWithCGPoint:CGPointMake(self.lineChartView.vInterval * i, 0)]];
            }
        }else{
            
            for( int i = 0; i < Interval; i++ )
                [self.pointArr addObject:[NSValue valueWithCGPoint:CGPointMake(self.lineChartView.vInterval * i, 0)]];
        }
        
        for( int i = 0; i < 10; i++ ){
            
                NSInteger miao = [startDate timeIntervalSince1970] + i * 24 * 3600 ;
                NSDate *newDate = [NSDate dateWithTimeIntervalSince1970:miao];
                NSString *hString = [formatter1 stringFromDate:newDate];
                [self.hArr addObject:hString];
            
            
        }
        
        /*
        [self.pointArr addObject:[NSValue valueWithCGPoint:CGPointMake(self.lineChartView.vInterval * 0, 10)]];
        [self.pointArr addObject:[NSValue valueWithCGPoint:CGPointMake(self.lineChartView.vInterval * 1, 40)]];
        [self.pointArr addObject:[NSValue valueWithCGPoint:CGPointMake(self.lineChartView.vInterval * 2, 30)]];
        [self.pointArr addObject:[NSValue valueWithCGPoint:CGPointMake(self.lineChartView.vInterval * 3, 50)]];
        [self.pointArr addObject:[NSValue valueWithCGPoint:CGPointMake(self.lineChartView.vInterval * 4, 80)]];
        [self.pointArr addObject:[NSValue valueWithCGPoint:CGPointMake(self.lineChartView.vInterval * 5, 20)]];
        [self.pointArr addObject:[NSValue valueWithCGPoint:CGPointMake(self.lineChartView.vInterval * 6, 50)]];
        [self.pointArr addObject:[NSValue valueWithCGPoint:CGPointMake(self.lineChartView.vInterval * 7, 70)]];
        [self.pointArr addObject:[NSValue valueWithCGPoint:CGPointMake(self.lineChartView.vInterval * 8, 60)]];
        [self.pointArr addObject:[NSValue valueWithCGPoint:CGPointMake(self.lineChartView.vInterval * 9, 90)]];
        */
        [self.lineChartView setArray:self.pointArr];
        [self.lineChartView setVDesc:self.vArr];
        [self.lineChartView setHDesc:self.hArr];
        [self addTable];
        
        
        for( int i = 0; i < self.pointArr.count; i++ ){
            CGPoint point = [self.pointArr[i]  CGPointValue];
            NSLog(@"%f %f",point.x, point.y);
        }

    }
    
    if( [self spin] )
        [self.spin stopAnimating];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    if( [self spin] )
        [self.spin stopAnimating];
    [SVStatusHUD showWithImage:nil status:@"当前网络有问题~"];
}

- (void)addTable
{
     [self.view addSubview:self.lineChartView];
}

- (void)setStartDate:(UIControl *)sender
{
    if( self.selectedDate == nil )
        self.selectedDate = [NSDate date];
    _actionSheetPicker = [[EActionSheetDatePicker alloc] initWithTitle:@"" datePickerMode:UIDatePickerModeDate selectedDate:self.selectedDate target:self action:@selector(dateWasSelected:) origin:sender];
    self.actionSheetPicker.hideCancel = YES;
    [self.actionSheetPicker showActionSheetPicker];
    
}

- (void)dateWasSelected:(NSDate *)selectedDate
{
    self.selectedDate = selectedDate;
    startDate = selectedDate;
    
    
    //根据picker来重构一个图表
    NSString* pid = nil;
    if( [[NSFileManager defaultManager] fileExistsAtPath:[self dataFilePath:personFile]] ){
        NSArray* tempArray = [NSArray arrayWithContentsOfFile:[self dataFilePath:personFile]];
        pid = tempArray[2];
    }
    
    [self.lineChartView removeFromSuperview];
    NSInteger miao = [startDate timeIntervalSince1970];
    miao += 10 * 24 * 3600;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:miao];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"dd/MM/YYYY"];
    
    [self createConnectAtPid:pid startAt:[formatter stringFromDate:startDate] endAt:[formatter stringFromDate:date]];
}

@end
