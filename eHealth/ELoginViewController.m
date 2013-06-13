//
//  ELoginViewController.m
//  eHealth
//
//  Created by god on 13-4-14.
//  Copyright (c) 2013年 god. All rights reserved.
//

#import "ELoginViewController.h"
#import "SVStatusHUD.h"
#define personFile @"person.plist"
#define dataBaseName   @"ehealth.db"

@interface ELoginViewController ()<ASIHTTPRequestDelegate>

@end

@implementation ELoginViewController
@synthesize Pass, Picture, userName, userPassword, Name, Login, spin;
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
//    CGFloat height = self.view.bounds.size.
    
    NSString* path = [[NSBundle mainBundle]pathForResource:@"png_login" ofType:@"png"];
    UIImage* i = [UIImage imageWithContentsOfFile:path];
    UIImageView* pic = [[UIImageView alloc] initWithImage:i];
    [pic setFrame:CGRectMake((width-256*0.5)/2, 0, 256*0.5, 256 * 0.5)];
    self.Picture = pic;
    [self.view addSubview:self.Picture];
    
    UILabel* lname = [[UILabel alloc]initWithFrame:CGRectMake(30, 256 * 0.5 + 20, 80, 25)];
    lname.text = @"用户名:";
    lname.numberOfLines = 1;
    self.Name = lname;

    [self.view addSubview:self.Name];
    
    UITextField* tUserName = [[UITextField alloc]initWithFrame:CGRectMake(30 + 60 + 20, 256 * 0.5 + 20, width - 150, 25)];
    self.userName = tUserName;
    tUserName.borderStyle = UITextBorderStyleRoundedRect;
    [tUserName addTarget:self action:@selector(PassWordBecomeFirst) forControlEvents:UIControlEventEditingDidEndOnExit];
    [self.view addSubview:self.userName];
    
    UILabel* lpass = [[UILabel alloc]initWithFrame:CGRectMake(30, 256 * 0.5 + 20 + 35, 80, 25)];
    lpass.text = @"登陆密码:";
    lpass.numberOfLines = 1;
    self.Pass = lpass;
    [self.view addSubview:self.Pass];
    
    UITextField* tPassWord = [[UITextField alloc] initWithFrame:CGRectMake(30 + 60 + 20, 256 * 0.5 + 20 + 35, width-150 , 25)];
    tPassWord.borderStyle = UITextBorderStyleRoundedRect;
    tPassWord.secureTextEntry = YES;
    [tPassWord addTarget:self action:@selector(tapRelase) forControlEvents:UIControlEventEditingDidEndOnExit];
    self.userPassword = tPassWord;
    [self.view addSubview:self.userPassword];
    
    UIButton* lBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [lBtn setFrame:CGRectMake(width / 2 - 30, 256 * 0.5 + 25 * 4 + 5, 60, 50)];
    [lBtn setTitle:@"登陆" forState:UIControlStateNormal];
    self.Login = lBtn;
    [lBtn addTarget:self action:@selector(connectPost) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.Login];
    
    [self createIfNoDataBase];
    
    NSDictionary *defaults = [NSDictionary dictionaryWithObjectsAndKeys:@"",@"userName",@"",@"password", nil];
    [[NSUserDefaults standardUserDefaults]registerDefaults:defaults];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *uName = [userDefaults objectForKey:@"userName"];
    NSString *pWord = [userDefaults objectForKey:@"password"];
    
    NSLog(@"UP: %@ %@",uName,pWord);
    
    self.userName.text = uName;
    self.userPassword.text = pWord;
   
}

- (NSString *)dataFilePath:(NSString *)fileName
{
    NSString* path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    return [path stringByAppendingPathComponent:fileName];
}

- (void) createIfNoDataBase
{
    if( ![[NSFileManager defaultManager] fileExistsAtPath:[self dataFilePath:dataBaseName]] ){
        /*
        sqlite3* database;
        if( sqlite3_open([[self dataFilePath:dataBaseName] UTF8String], &database) != SQLITE_OK ){
            sqlite3_close(database);
            NSAssert(0, @"failed to open database");
        }
        NSString* createSQL = @"CREATE TABLE IF NOT EXISTS exercise(eid primary key, standardTime, exerciseName, video, exerciseDescription);";
        char* errorMsg;
        if( sqlite3_exec(database, [createSQL UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK ){
            sqlite3_close(database);
            NSAssert(0, @"failed to create table: %s",errorMsg);
        }
        createSQL = @"CREATE TABLE IF NOT EXISTS question(qid primary key, questionContent, score);";
        if( sqlite3_exec(database, [createSQL UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK ){
            sqlite3_close(database);
            NSAssert(0, @"failed to create table: %s",errorMsg);
        }
        createSQL = @"CREATE TABLE IF NOT EXISTS status(sid primary key, tableName, latest);";
        if( sqlite3_exec(database, [createSQL UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK ){
            sqlite3_close(database);
            NSAssert(0, @"failed to create table: %s",errorMsg);
        }
        
        NSString* update = @"INSERT OR REPLACE INTO status(sid, tableName, latest) VALUES (?,?,? );";
        sqlite3_stmt* statement;
        if( sqlite3_prepare_v2(database, [update UTF8String], -1, &statement, NULL) == SQLITE_OK ){
            sqlite3_bind_int(statement, 1, 1);
            sqlite3_bind_text(statement, 2, "exercise", -1, NULL);
            sqlite3_bind_int(statement, 3, -1);
        }
        if( sqlite3_step(statement) != SQLITE_DONE ){
            NSAssert(0, @"failed to update table");
        }
        sqlite3_finalize(statement);
        if( sqlite3_prepare_v2(database, [update UTF8String], -1, &statement, NULL) == SQLITE_OK ){
            sqlite3_bind_int(statement, 1, 2);
            sqlite3_bind_text(statement, 2, "question", -1, NULL);
             sqlite3_bind_int(statement, 3, -1);
        }
        if( sqlite3_step(statement) != SQLITE_DONE ){
            NSAssert(0, @"failed to update table");
        }
        sqlite3_finalize(statement);
        
        if( sqlite3_prepare_v2(database, [update UTF8String], -1, &statement, NULL) == SQLITE_OK ){
            sqlite3_bind_int(statement, 1, 3);
            sqlite3_bind_text(statement, 2, "video", -1, NULL);
             sqlite3_bind_int(statement, 3, -1);
        }
        if( sqlite3_step(statement) != SQLITE_DONE ){
            NSAssert(0, @"failed to update table");
        }
        sqlite3_finalize(statement);
        
        sqlite3_close(database);
         */
        
        NSString *database = [[NSBundle mainBundle]pathForResource:@"ehealth" ofType:@"db"];
        NSString *newPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        newPath = [newPath stringByAppendingPathComponent:@"ehealth.db"];
        NSError *error = [[NSError alloc]init];
        [[NSFileManager defaultManager]copyItemAtPath:database toPath:newPath error:&error];
        
    }
    [self moveVideos];
}

- (void) moveVideos
{
    //,@"video5",@"video6",@"video7",@"video8"
    NSArray *videos = [[NSArray alloc]initWithObjects:@"video1r",@"video1l",@"video2",@"video3r",@"video3l",@"video4",@"video9",@"video10r",@"video10l",@"video11",@"video12r",@"video12l",@"video13r",@"video13l",@"video14",@"video15r",@"video15l",@"video16b",@"video16f",@"video17r",@"video17l",@"video18r",@"video18l",@"video19",@"video20",@"testVideo2", nil];
    
    for( int i = 0; i < [videos count]; i++ ){
        NSString *video = [[NSBundle mainBundle]pathForResource:videos[i] ofType:@"mp4"];
        NSString *newPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        newPath = [newPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4",videos[i]]];
        if( [[NSFileManager defaultManager] fileExistsAtPath:video] ){
            NSError *error = [[NSError alloc]init];
            [[NSFileManager defaultManager]copyItemAtPath:video toPath:newPath error:&error];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)PassWordBecomeFirst
{
    [self.userPassword becomeFirstResponder];
}

- (void)tapRelase
{
    [self.userPassword resignFirstResponder];
    [self.userName resignFirstResponder];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch* touch = [touches anyObject];
    UIView* view = [touch view];
    if( view == self.view ){
        [self tapRelase];
    }
}

- (void)connectPost
{
    NSString* add = @"http://myehealth.sinaapp.com/Patient/checkLogin";
    NSURL* url = [NSURL URLWithString:add];
    ASIFormDataRequest* request = [[ASIFormDataRequest alloc]initWithURL:url];
    [request setDelegate:self];
    NSString* name = self.userName.text;
    NSString* pass =  [self md5HexDigest:self.userPassword.text];
    [request setPostValue:name forKey:@"pid"];
    [request setPostValue:pass forKey:@"patientPassword"];
    BOOL netWorkOk = [ASIHTTPRequest isNetworkAvaible];
    if( netWorkOk )
        [request startAsynchronous];
    else
        [SVStatusHUD showWithImage:nil status:@"没有网络~~"];
    
}

- (NSString *)dataFilePath
{
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentsDirectory = [paths objectAtIndex:0];
    return  [documentsDirectory stringByAppendingPathComponent:personFile];
}

- (void)saveToLocal:(NSDictionary*) json
{


    NSMutableArray* temp = [[NSMutableArray alloc]init];
    [temp addObject:[json objectForKey:@"patientGender"]];
    [temp addObject:[json objectForKey:@"patientName"]];
    [temp addObject:[json objectForKey:@"pid"]];
    [temp addObject:[json objectForKey:@"admissionDate"]];
    [temp addObject:[json objectForKey:@"doctorName"]];
    [temp addObject:[json objectForKey:@"did"]];
    [temp addObject:[json objectForKey:@"doctorGender"]];
    [temp writeToFile:[self dataFilePath] atomically:YES];
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
    
    [self.spin becomeFirstResponder];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    [self.spin removeFromSuperview];
    
    NSData* data = [request responseData];
    NSError* error = [[NSError alloc]init];
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    NSNumber *rc = [json objectForKey:@"rc"];
    NSLog(@"%@",rc);
    if( [rc isEqual:@0] ){
        [self saveToLocal:json];
        EFirstViewController* nextVC = [[EFirstViewController alloc]init];
        [nextVC setValue:downloadFlag forKey:@"downloadFlag"];
        [self.navigationController pushViewController:nextVC animated:YES];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setValue:self.userPassword.text forKey:@"userName"];
        [defaults setValue:self.userPassword.text forKey:@"password"];
        
    }else{
        //密码或者用户名错误
        [SVStatusHUD showWithImage:nil status:@"密码或者用户名错误~~"];
    }
    
    
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    [SVStatusHUD showWithImage:nil status:@"当前网络有问题~"];
    if( self.spin )
        [self.spin removeFromSuperview];
    NSLog(@"failed");
}



#pragma mark - MD5加密
-(NSString *) md5HexDigest:(NSString* )S
{
    const char* original_str = [S UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(original_str,strlen(original_str),result);
    NSMutableString* hash = [NSMutableString string];
    for (int i = 0; i < 16; i++)
        [hash appendFormat:@"%02X",result[i]];
    return [hash lowercaseString];
}

@end
