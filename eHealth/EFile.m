//
//  EFile.m
//  eHealth
//
//  Created by god on 13-4-27.
//  Copyright (c) 2013年 god. All rights reserved.
//

#import "EFile.h"

@implementation EFile

+ (NSString *)dataFilePath:(NSString *)fileName
{
    NSString* path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    return [path stringByAppendingPathComponent:fileName];
}

@end
