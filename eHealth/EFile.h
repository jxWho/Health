//
//  EFile.h
//  eHealth
//
//  Created by god on 13-4-27.
//  Copyright (c) 2013年 god. All rights reserved.
//

#import <Foundation/Foundation.h>
#define personFile @"person.plist"
#define dataBaseName   @"ehealth.db"

@interface EFile : NSObject

+ (NSString *)dataFilePath:(NSString *)fileName;

@end
