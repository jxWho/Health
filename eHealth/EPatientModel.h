//
//  EPatientModel.h
//  eHealth
//
//  Created by god on 13-5-9.
//  Copyright (c) 2013年 god. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EPatientModel : NSObject

@property (nonatomic, strong) NSMutableArray *unFinish;
@property (nonatomic, strong) NSMutableArray *finish;
@property (nonatomic, strong) NSMutableArray *questions;
@property (nonatomic, strong) NSMutableArray *todayExercise;
+ (EPatientModel *)sharedEPatientModel;

@end
