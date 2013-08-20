//
//  EQuestionDetailViewController.m
//  eHealth
//
//  Created by god on 13-5-1.
//  Copyright (c) 2013年 god. All rights reserved.
//

#import "EQuestionDetailViewController.h"

@interface EQuestionDetailViewController ()<UITableViewDataSource,UITableViewDelegate>

@end

@implementation EQuestionDetailViewController

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
    // Do any additional setup after loading the view from its nib.
    self.detailText.text = detail;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView Datasource
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"请评分";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [score intValue];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIndentifier = @"questionDetailCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier];
    if( cell == nil )
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier];
    cell.textLabel.text = [NSString stringWithFormat:@"%d",indexPath.row + 1];
    int row = indexPath.row + 1;
    if( [selectedRow intValue] == row )
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    return cell;
    
    
}


#pragma mark - UITableView Delegate Method
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    for( UITableViewCell *cell in [tableView visibleCells] ){
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
    int row = indexPath.row;
    NSString *text = [NSString stringWithFormat:@"%d",row + 1];
    [delegate changeText:text];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    sleep(0.8);
    [self dismissViewControllerAnimated:YES completion:^{}];
}

@end
