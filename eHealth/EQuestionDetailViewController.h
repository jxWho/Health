//
//  EQuestionDetailViewController.h
//  eHealth
//
//  Created by god on 13-5-1.
//  Copyright (c) 2013年 god. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EQuestionDetailViewDelgete <NSObject>

@required
- (void)changeText:(NSString *)text;


@end

@interface EQuestionDetailViewController : UIViewController
{
    NSNumber *score;
    NSString *detail;
    NSNumber *selectedRow;
    id<EQuestionDetailViewDelgete> delegate;
}
@property (weak, nonatomic) IBOutlet UITextView *detailText;
@property (weak, nonatomic) IBOutlet UITableView *choices;


@end
