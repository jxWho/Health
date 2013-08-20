//
//  ECommunicationViewController.h
//  eHealth
//
//  Created by god on 13-4-25.
//  Copyright (c) 2013年 god. All rights reserved.
//

#import "MessagesViewController.h"

@interface ECommunicationViewController : MessagesViewController

@property (nonatomic, strong) NSMutableArray *messages;
@property(nonatomic, weak) UIActivityIndicatorView* spin;

@end
