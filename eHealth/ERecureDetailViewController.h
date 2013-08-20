//
//  ERecureDetailViewController.h
//  eHealth
//
//  Created by god on 13-4-16.
//  Copyright (c) 2013年 god. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ERecureDetailViewController : UIViewController

@property(nonatomic, weak) UIImageView* imageView;
@property(nonatomic, weak) UITextView* textView;
@property(nonatomic, copy) NSString* eid;
@property(nonatomic, weak) UINavigationBar *NVBar;

@end
