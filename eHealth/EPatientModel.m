//
//  EPatientModel.m
//  eHealth
//
//  Created by god on 13-5-9.
//  Copyright (c) 2013年 god. All rights reserved.
//

#import "EPatientModel.h"

@implementation EPatientModel

- (id)init
{
    NSAssert(0, @"singleton");
    return nil;
}

- (id) initSingleton
{
    if( self = [super init] ){
        //初始化
        self.unFinish = [[NSMutableArray alloc]init];
        self.finish = [[NSMutableArray alloc]init];
        self.questions = [[NSMutableArray alloc]init];
        self.todayExercise = [[NSMutableArray alloc]init];
    }
    return self;
}

+ (EPatientModel *)sharedEPatientModel
{
    static EPatientModel *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc]initSingleton];
    });
    return instance;
}

@end
