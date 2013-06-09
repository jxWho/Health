//
//  EPatientModel.h
//  eHealth
//
//  Created by god on 13-5-9.
//  Copyright (c) 2013年 god. All rights reserved.
//

#import <Foundation/Foundation.h>

#define FINISHNOTIFICATION @"finishnotification"

@interface EPatientModel : NSObject
{
    
}
@property (nonatomic, strong) NSMutableArray *unFinish;     //eid and count
@property (nonatomic, strong) NSMutableArray *finish;       //eid
@property (nonatomic, strong) NSMutableArray *questions;
@property (nonatomic, strong) NSMutableArray *todayExercise;
@property (nonatomic) BOOL questionFlag;  //标志是否完成问卷
+ (EPatientModel *)sharedEPatientModel;

@end
