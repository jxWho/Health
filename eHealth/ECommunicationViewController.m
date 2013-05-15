//
//  ECommunicationViewController.m
//  eHealth
//
//  Created by god on 13-4-25.
//  Copyright (c) 2013年 god. All rights reserved.
//

#import "ECommunicationViewController.h"
#import "ASIHeaders.h"
#import "SVStatusHUD.h"
#import "EFile.h"
#import <QuartzCore/QuartzCore.h>
@interface ECommunicationViewController ()<ASIHTTPRequestDelegate>

@end

@implementation ECommunicationViewController

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
    NSNumber *did = nil;
    NSString *filePath = [EFile dataFilePath:personFile];
    if( [[NSFileManager defaultManager]fileExistsAtPath:filePath] ){
        NSArray *array = [[NSArray alloc]initWithContentsOfFile:filePath];
        did = array[5];
    }
    int iDid =[did intValue];
    self.title = [NSString stringWithFormat:@"与医生%d交谈",iDid];
    self.messages = [[NSMutableArray alloc] initWithObjects:nil];
    NSDictionary *defaluts = [NSDictionary dictionaryWithObjectsAndKeys:@"2013-03-01",@"time1",@"16:32:13",@"time2", nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaluts];
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self createConnect];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    self.messages = nil;
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.messages.count;
}

#pragma mark - Messages view controller
- (BubbleMessageStyle)messageStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *sender = [self.messages[indexPath.row] objectForKey:@"sender"];
    if( [sender isEqualToString:@"0"] )
        return BubbleMessageStyleIncoming;
    else
        return BubbleMessageStyleOutgoing;
//    return (indexPath.row % 2) ? BubbleMessageStyleIncoming : BubbleMessageStyleOutgoing;
}

- (NSString *)textForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.messages[indexPath.row] objectForKey:@"messageContent"];
//    return [self.messages objectAtIndex:indexPath.row];
}

- (void)sendPressed:(UIButton *)sender withText:(NSString *)text
{
//    [self.messages addObject:text];
    
    /*
    if((self.messages.count - 1) % 2)
        [MessageSoundEffect playMessageSentSound];
    else
        [MessageSoundEffect playMessageReceivedSound];
     */
    NSDictionary *newMessage = [[NSDictionary alloc]initWithObjectsAndKeys:text,@"messageContent",[NSDate date],@"time",@"1",@"sender", nil];
    [self.messages addObject:newMessage];
    [self finishSend];
    //上传到服务器
    NSString *filePath = [EFile dataFilePath:personFile];
    NSNumber *pid;
    NSNumber *did;
    if( [[NSFileManager defaultManager]fileExistsAtPath:filePath] ){
        NSArray *array = [NSArray arrayWithContentsOfFile:filePath];
        pid = array[2];
        did = array[5];
    }
    [self createUploadConnectWherePid:pid Did:did messageContent:text];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)createConnect
{
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"HH:mm:ss"];
    NSString *now = [formatter stringFromDate:date];
    NSDateFormatter *formatter2 = [[NSDateFormatter alloc]init];
    [formatter2 setDateFormat:@"YYYY-MM-dd"];
    NSMutableString *ADD = [[NSMutableString alloc]initWithString:@"http://myehealth.sinaapp.com/API/getMessages?pid="];
    
    NSString *filePath = [EFile dataFilePath:personFile];
    NSArray *personData;
    NSString *pid = @"";
    if( [[NSFileManager defaultManager]fileExistsAtPath:filePath] ){
        personData = [[NSArray alloc]initWithContentsOfFile:filePath];
        pid = personData[2];
    }
    
    NSString *time1;
    NSString *time2;

    NSUserDefaults *defaluts = [NSUserDefaults standardUserDefaults];
    time1 = [defaluts objectForKey:@"time1"];
    time2 = [defaluts objectForKey:@"time2"];
    NSLog(@"%@",time2);
    [ADD appendString:pid];
    [ADD appendString:@"&time="];
    [ADD appendString:time1];
    [ADD appendString:@"%20"];
    [ADD appendString:time2];
    NSURL *url = [NSURL URLWithString:ADD];
    NSLog(ADD);
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc]initWithURL:url];
    [request setDelegate:self];
    [request startAsynchronous];
     
}


- (void)createUploadConnectWherePid:(NSNumber *)pid Did:(NSNumber *)did messageContent:(NSString *)message
{
    NSString *add = @"http://myehealth.sinaapp.com/API/addMessage";
    NSURL *url = [NSURL URLWithString:add];
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc]initWithURL:url];
    [request setPostValue:pid forKey:@"pid"];
    [request setPostValue:did forKey:@"did"];
    [request setPostValue:message forKey:@"messageContent"];
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(uploadFinish:)];
    [request startAsynchronous];
}
#pragma mark - ASIHTTPRequest

- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSData *data = [request responseData];
    NSError* error = [[NSError alloc]init];
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    NSNumber *rc = [json objectForKey:@"rc"];
    if( [rc isEqual: @0] ){
        NSArray *arry = [json objectForKey:@"messages"];
        for( int i = [arry count] - 1; i >= 0 ; i-- ){
            [self.messages addObject:arry[i]];
            NSLog(@"%@",arry[i]);
        }
        [self.tableView reloadData];
        [self scrollToBottomAnimated:NO];
        NSLog(@"reload");
    }else{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"失败" message:@"下载失败" delegate:self cancelButtonTitle:@"取消" otherButtonTitles: nil];
        [alert show];
    }
    if( [self spin] )
        [self.spin removeFromSuperview];
        
}

- (void)requestStarted:(ASIHTTPRequest *)request
{
    NSLog(@"start");
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

- (void)uploadFinish:(ASIFormDataRequest *)request
{
    NSData *data = [request responseData];
    NSError *error = [[NSError alloc]init];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    NSNumber *rc = [json objectForKey:@"rc"];
    if( [rc isEqualToNumber:@0] ){
        NSLog(@"上传成功");
        NSDate *date = [NSDate date];
        NSDateFormatter *formatter1 = [[NSDateFormatter alloc]init];
        NSDateFormatter *formatter2 = [[NSDateFormatter alloc]init];
        [formatter1 setDateFormat:@"YYYY-MM-dd"];
        [formatter2 setDateFormat:@"HH-mm-ss"];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setValue:@"time1" forKey:[formatter1 stringFromDate:date]];
        [defaults setValue:@"time2" forKey:[formatter2 stringFromDate:date]];
    } else{
        NSLog(@"上传失败");
        [self.messages removeLastObject];
        [self.tableView reloadData];
        NSString *dataString = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"%@",dataString);
    }
    if( [self spin] )
        [self.spin removeFromSuperview];    
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    [self.spin removeFromSuperview];
    [SVStatusHUD showWithImage:nil status:@"当前网络有问题~"];
    NSLog(@"upload failed");
}

@end
