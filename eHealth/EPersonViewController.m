//
//  EPersonViewController.m
//  eHealth
//
//  Created by god on 13-4-13.
//  Copyright (c) 2013年 god. All rights reserved.
//

#import "EPersonViewController.h"
#define personFile @"person.plist"
@interface EPersonViewController ()

@end

@implementation EPersonViewController

@synthesize bar1, label1, image1, bar2, label2, image2, patientDate, patientName, patientNumber, patientSex, doctorName, doctorNumber;

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

    self.navigationItem.title = @"个人资料";
    self.view.backgroundColor = [UIColor whiteColor];
    CGFloat width = self.view.bounds.size.width;
//    CGFloat height = self.view.bounds.size.height;
    
    NSString* filePath = [self dataFilePath];
    NSArray* array = nil;
    BOOL exit = false;
    if( [[NSFileManager defaultManager] fileExistsAtPath:filePath] ){
        array = [[NSArray alloc]initWithContentsOfFile:filePath];
        exit = true;
    }
    
    
    NSString* path = [[NSBundle mainBundle] pathForResource:@"png_ltitlebar.fw" ofType:@"png"];
    UIImage* tImag = [UIImage imageWithContentsOfFile:path];
    UIImageView* tView = [[UIImageView alloc]initWithImage:tImag];
    [tView setFrame:CGRectMake(0, 0, 320, 32)];
    self.bar1 = tView;
    [self.view addSubview:self.bar1];
    
    UILabel* l1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 32)];
    l1.text = @"病人资料";
    l1.backgroundColor = [UIColor clearColor];
    self.label1 = l1;
    [self.view addSubview:self.label1];
    
    path = [[NSBundle mainBundle] pathForResource:@"png_login" ofType:@"png"];
    UIImageView* patientView = [[UIImageView alloc]initWithImage:[UIImage imageWithContentsOfFile:path]];
    [patientView setFrame:CGRectMake(0, 32, 256*0.4, 256*0.4)];
    self.image1 = patientView;
    [self.view addSubview:self.image1];
    //在图片旁边添加 性别、姓名、住院号、入院日期  考虑用归档？
    UILabel* sex = [[UILabel alloc]initWithFrame:CGRectMake(256*0.5 + 10, 32, width - 256*0.5, 256*0.5 / 4)];
    sex.text = @"性别:";
    if(exit){
        NSString* s;
        if( array[0] )
            s = @"男";
        else
            s = @"女";
        sex.text = [NSString stringWithFormat:@"%@%@",sex.text,s];
    }
    self.patientSex = sex;
    [self.view addSubview:self.patientSex];
    
    UILabel* name = [[UILabel alloc]initWithFrame:CGRectMake(256 * 0.5 + 10 , 32 + 256 * 0.5 / 4, width - 256 * 0.5, 256*0.5/4)];
    name.text = @"患者姓名:";
    if(exit){
        name.text = [NSString stringWithFormat:@"%@%@",name.text,array[1]];
    }
    self.patientName = name;
    [self.view addSubview:self.patientName];
    
    UILabel* Number = [[UILabel alloc]initWithFrame:CGRectMake(256 * 0.5 + 10, 32 + ( 256 * 0.5 / 4) * 2, width - 256 * 0.5, 256 * 0.5 /4)];
    Number.text = @"住院号:";
    if(exit){
        Number.text = [NSString stringWithFormat:@"%@%@",Number.text,array[2]];
    }
    self.patientNumber = Number;
    [self.view addSubview:self.patientNumber];
    
    UILabel* data = [[UILabel alloc]initWithFrame:CGRectMake(265 * 0.5 + 10, 32 + (256 * 0.5 / 4) * 3, width - 256 * 0.5, 256 * 0.5 /4)];
    data.text = @"住院日期:";
    if(exit){
        data.text = [NSString stringWithFormat:@"%@%@",data.text,array[3]];
    }
    self.patientDate = data;
//    self.patientDate.font = self.patientName.font;
    [self.view addSubview:self.patientDate];

    
    path = [[NSBundle mainBundle] pathForResource:@"png_ltitlebar.fw" ofType:@"png"];
    tImag = [UIImage imageWithContentsOfFile:path];
    UIImageView* tView2 = [[UIImageView alloc]initWithImage:[UIImage imageWithContentsOfFile:path]];
    [tView2 setFrame:CGRectMake(0, 32 + 256 * 0.5, 320, 32)];
    self.bar2 = tView2;
    [self.view addSubview:self.bar2];
    
    UILabel* l2 = [[UILabel alloc]initWithFrame:CGRectMake(0 , 32 + 256 * 0.5, 320, 32)];
    l2.text = @"主诊医生";
    
    l2.backgroundColor = [UIColor clearColor];
    self.label2 = l2;
    [self.view addSubview:self.label2];
    
    path = [[NSBundle mainBundle]pathForResource:@"png_doctor" ofType:@"png"];
    UIImageView* doctoerView = [[UIImageView alloc]initWithImage:[UIImage imageWithContentsOfFile:path]];
    [doctoerView setFrame:CGRectMake(width - 256 * 0.5, 32 + 256 * 0.5 + 32, 256 * 0.5, 256 * 0.5)];
    self.image2 = doctoerView;
    [self.view addSubview:self.image2];
    //添加医生的名字、编号  归档？
    UILabel* doctorName1 = [[UILabel alloc]initWithFrame:CGRectMake(0 + 10, 32 + 256 * 0.5 + 32, width - 256*0.5, 256*0.5 /4)];
    doctorName1.text = @"医生:";
    if(exit){
        doctorName1.text = [NSString stringWithFormat:@"%@%@",doctorName1.text,array[4]];
    }
    self.doctorName = doctorName1;
    [self.view addSubview:self.doctorName];
    
    UILabel* dNum = [[UILabel alloc]initWithFrame:CGRectMake(0 + 10, 32 + 256*0.5 + 32 + 256*0.5/4, width - 256*0.5, 256*0.5/4)];
    dNum.text = @"医生编号:";
    if (exit) {
        dNum.text = [NSString stringWithFormat:@"%@%@",dNum.text,array[5]];
    }
    self.doctorNumber = dNum;
    [self.view addSubview:self.doctorNumber];
            
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)dataFilePath
{
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentsDirectory = [paths objectAtIndex:0];
    return  [documentsDirectory stringByAppendingPathComponent:personFile];
}

@end
