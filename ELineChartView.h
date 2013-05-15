//
//  ELineChartView.h
//  eHealth
//
//  Created by god on 13-4-20.
//  Copyright (c) 2013年 god. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface ELineChartView : UIView

//横竖轴距离间隔
@property (assign) NSInteger hInterval;
@property (assign) NSInteger vInterval;

//横竖轴显示标签
@property (nonatomic, strong) NSArray *hDesc;
@property (nonatomic, strong) NSArray *vDesc;

//点信息
@property (nonatomic, strong) NSArray *array;

@end
