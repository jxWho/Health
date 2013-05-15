//
//  EPersonViewController.h
//  eHealth
//
//  Created by god on 13-4-13.
//  Copyright (c) 2013年 god. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EPersonViewController : UIViewController

@property(nonatomic, weak) UIImageView* bar1;
@property(nonatomic, weak) UILabel* label1;
@property(nonatomic, weak) UIImageView* image1;
@property(nonatomic, weak) UIImageView* bar2;
@property(nonatomic, weak) UILabel* label2;
@property(nonatomic, weak) UIImageView* image2;
@property(nonatomic, weak) UILabel* patientName;
@property(nonatomic, weak) UILabel* patientSex;
@property(nonatomic, weak) UILabel* patientNumber;
@property(nonatomic, weak) UILabel* patientDate;
@property(nonatomic, weak) UILabel* doctorName;
@property(nonatomic, weak) UILabel* doctorNumber;

//modal
@property(nonatomic, strong) NSDictionary *patient;
@property(nonatomic, strong) NSDictionary *doctor;
@end
