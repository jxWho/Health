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


@interface EToday2ViewController ()<UITableViewDataSource,UITableViewDelegate>

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
    self.Finished = [EPatientModel sharedEPatientModel].finish;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [(UITableView *)self.view reloadData];
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
    NSLog(@"eid is %@ and titile is %@",eid, title);
    return cell;
}

#pragma mark - UItableViewDelegate Method

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}




@end
