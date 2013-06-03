//
//  EQuestionViewController.m
//  eHealth
//
//  Created by god on 13-5-1.
//  Copyright (c) 2013年 god. All rights reserved.
//

#import "EQuestionViewController.h"
#import "EPatientModel.h"
#import <QuartzCore/QuartzCore.h>
#import "ASIHeaders.h"
#import "SVStatusHUD.h"
#import <sqlite3.h>
#import "EFile.h"
@interface EQuestionViewController () <ASIHTTPRequestDelegate>
{
    NSIndexPath *selectedPath;
}
@end

@implementation EQuestionViewController

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
    self.questions = [[NSMutableArray alloc]init];
    [self getFromDataBase];
    for( int i = 0; i < [_questions count]; i++ )
        NSLog(@"%@",_questions[i]);
    self.Question.delegate = self;
    [self.Question reloadData];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"提交问卷" style:UIBarButtonItemStyleDone target:self action:@selector(submit:)];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)getFromDataBase
{
    sqlite3 *database;
    if( sqlite3_open([[EFile dataFilePath:dataBaseName] UTF8String], &database) != SQLITE_OK ){
        NSAssert(0, @"failed to open database");
        sqlite3_close(database);
    }
    NSString *query = @"SELECT questionContent, score,qid FROM question";
    sqlite3_stmt *statement;
    NSString *content;
    NSNumber *score;
    NSNumber *qid;
    if( sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil) == SQLITE_OK ){
        while ( sqlite3_step(statement) == SQLITE_ROW ) {
            char *a = (char *)sqlite3_column_text(statement, 0);
            int b = sqlite3_column_int(statement, 1);
            int c = sqlite3_column_int(statement, 2);
            content = [NSString stringWithUTF8String:a];
            score = [NSNumber numberWithInt:b];
            qid = [NSNumber numberWithInt:c];
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:content,@"content",score,@"score",qid,@"qid",nil];
            EPatientModel *singleton = [EPatientModel sharedEPatientModel];
            NSLog(@"%d",[singleton.questions count]);
            for( int i = 0; i < [singleton.questions count]; i++ ){
                NSNumber *tempQid = singleton.questions[i];
                int tempqid = [tempQid intValue];
                int intQid = [qid intValue];
                if( tempqid == intQid ){
                    NSLog(@"%@",tempQid);
                    [self.questions addObject:dic];
                    break;
                }
            }
        }
    }
    sqlite3_finalize(statement);
    sqlite3_close(database);
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_questions count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"QuestionCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    int row = indexPath.row;
    NSString *content = [_questions[row] objectForKey:@"content"];
    cell.textLabel.text = [NSString stringWithFormat:@"问题%d:",row+1];
    cell.detailTextLabel.text = content;
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    
     EQuestionDetailViewController *detailViewController = [[EQuestionDetailViewController alloc] initWithNibName:@"EQuestionDetailViewController" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *cellTextLabel = cell.textLabel.text;
    NSArray *array = [cellTextLabel componentsSeparatedByString:@":"];
    
    int row = indexPath.row;
    NSString *content = [_questions[row] objectForKey:@"content"];
    NSNumber *score = [_questions[row] objectForKey:@"score"];
    NSNumber *selectedRow = [NSNumber numberWithInt:[array[1] intValue]];
    [detailViewController setValue:content forKey:@"detail"];
    [detailViewController setValue:score forKey:@"score"];
    [detailViewController setValue:self forKey:@"delegate"];
    [detailViewController setValue:selectedRow forKey:@"selectedRow"];
    selectedPath = indexPath;
    
    [self.navigationController presentModalViewController:detailViewController animated:YES];
//    [self.navigationController pushViewController:detailViewController animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

#pragma mark - Detail Method
- (void)changeText:(NSString *)text
{
    UITableViewCell *cell = [self.Question cellForRowAtIndexPath:selectedPath];
    NSString *detailText = cell.textLabel.text;
    NSArray *array = [detailText componentsSeparatedByString:@":"];
    cell.textLabel.text = [NSString stringWithFormat:@"%@:%@分",array[0],text];

}

#pragma mark - Button Methods

- (void)submit:(id) sender
{
    NSArray *cells = [_Question visibleCells];
    for( UITableViewCell *tempCell in cells ){
        NSString *cellText = tempCell.textLabel.text;
        NSArray *array = [cellText componentsSeparatedByString:@":"];
        if( [array[1] intValue] == 0 ){
            //未填写完成
            
            [SVStatusHUD showWithImage:nil status:@"你还没有填写好问卷~"];
            return;
        }
    }
    //填写完成了，提交
    [self createQuestionConnect];
}

- (void)createQuestionConnect
{
    NSString *filePath = [EFile dataFilePath:personFile];
    NSString *did = nil;
    NSString *pid = nil;
    if( [[NSFileManager defaultManager]fileExistsAtPath:filePath] ){
        NSArray *array = [NSArray arrayWithContentsOfFile:filePath];
        did = array[5];
        pid = array[2];
    }
    if( did == nil || pid == nil )
        return;
    
    NSMutableArray *records = [[NSMutableArray alloc]init];
    NSArray *cells = [_Question visibleCells];
    for( int i = 0; i < [_questions count]; i++ ){
        NSNumber *qid = [_questions[i] objectForKey:@"qid"];
        NSString *qidString = [NSString stringWithFormat:@"%@",qid];
        NSString *text = ((UITableViewCell *)cells[i]).textLabel.text;
        NSArray *tempArrary = [text componentsSeparatedByString:@":"];
        int score = [tempArrary[1] intValue];
        NSString *scoreString = [NSString stringWithFormat:@"%d",score];
        NSDictionary *tempDic = [NSDictionary dictionaryWithObjectsAndKeys:scoreString,@"score",qidString,@"qid", nil];
        [records addObject:tempDic];
    }
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"YYYY-MM-dd"];
    NSString *dateString = [formatter stringFromDate:date];
    NSNumber *count = [NSNumber numberWithInt:[records count]];
    NSString *countString = [NSString stringWithFormat:@"%@",count];
    NSDictionary *sendDic = [NSDictionary dictionaryWithObjectsAndKeys:did,@"doctorID",records,@"records",dateString,@"date",pid,@"patientID",countString,@"count", nil];

    NSData *questionData = nil;
    if( [NSJSONSerialization isValidJSONObject:sendDic] ){
        NSError *error;
        questionData = [NSJSONSerialization dataWithJSONObject:sendDic options:NSJSONWritingPrettyPrinted error:&error];
        
    }
    NSLog(@"json is %@",questionData);
    NSString *dataString = [[NSString alloc]initWithData:questionData encoding:NSUTF8StringEncoding];
    NSLog(@"%@",dataString);
    NSString *add = @"http://myehealth.sinaapp.com/API/addFeedbackRecord";
    NSURL *url = [NSURL URLWithString:add];
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc]initWithURL:url];
    [request setDelegate:self];
    [request setPostValue:dataString forKey:@"result"];
    [request startAsynchronous];
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

- (void)requestFailed:(ASIHTTPRequest *)request
{
    [SVStatusHUD showWithImage:nil status:@"当前网络有问题~"];
    if( self.spin )
        [self.spin removeFromSuperview];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSLog(@"finish");
    NSData *data = [request responseData];
    NSError *error = [[NSError alloc]init];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    NSNumber *rc = [json objectForKey:@"rc"];
    NSLog(@"%@",json);
    EPatientModel *singleton = [EPatientModel sharedEPatientModel];
    if( [rc isEqual:@0] ){
        [self.navigationController popViewControllerAnimated:YES];
        singleton.questionFlag = YES;
    }else{
        //提交失败...
        [SVStatusHUD showWithImage:nil status:@"提交失败，请重新提交~"];
        singleton.questionFlag = NO;
        
    }
}

@end
