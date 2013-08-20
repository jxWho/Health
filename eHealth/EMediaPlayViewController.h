//
//  EMediaPlayViewController.h
//  eHealth
//
//  Created by god on 13-4-16.
//  Copyright (c) 2013年 god. All rights reserved.
//

@protocol EMedia <NSObject>

@required
- (void)goToNext;
- (void)showQuestionNoti;
@end

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "SVStatusHUD.h"
@interface EMediaPlayViewController : UIViewController
{
    
}
@property(nonatomic, copy) NSString* mediaFileName;
@property(nonatomic, strong) MPMoviePlayerController* MovieController;
@property(nonatomic, copy) NSString* count;
@property(nonatomic, weak) UILabel* label;
@property(nonatomic, weak) UITextView* textField;
@property(nonatomic, copy) NSString* eid;
@property(nonatomic, weak) UIImageView* restView;
@property(nonatomic, weak) id delegate;
@property(nonatomic, weak) UIActivityIndicatorView* spin;


@end
