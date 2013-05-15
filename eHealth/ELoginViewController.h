//
//  ELoginViewController.h
//  eHealth
//
//  Created by god on 13-4-14.
//  Copyright (c) 2013年 god. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CommonCrypto/CommonDigest.h>
#import "ASIHeaders.h"
#import <QuartzCore/QuartzCore.h>
#import "EFirstViewController.h"
#import <sqlite3.h>


@interface ELoginViewController : UIViewController
{
    NSString* downloadFlag;
}

@property(nonatomic, weak) UIImageView* Picture;
@property(nonatomic, strong) UITextField* userName;
@property(nonatomic, strong) UITextField* userPassword;
@property(nonatomic, weak) UILabel* Name;
@property(nonatomic, weak) UILabel* Pass;
@property(nonatomic, weak) UIButton* Login;
@property(nonatomic, weak) UIActivityIndicatorView* spin;


@end
