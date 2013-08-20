//
//  ASIHTTPRequest+checkStatus.m
//  eHealth
//
//  Created by god on 13-5-17.
//  Copyright (c) 2013年 god. All rights reserved.
//

#import "ASIHTTPRequest+checkStatus.h"
#import "Reachability.h"
@implementation ASIHTTPRequest (checkStatus)


+ (BOOL)isNetworkAvaible
{
    
    return !([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == kNotReachable);
}


@end
