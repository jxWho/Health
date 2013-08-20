//
//  EActionSheetDatePicker.h
//  eHealth
//
//  Created by god on 13-4-21.
//  Copyright (c) 2013年 god. All rights reserved.
//

#import "EAbstarctActionSheetPicker.h"

@interface EActionSheetDatePicker : EAbstarctActionSheetPicker

+ (id)showPickerWithTitle:(NSString *)title datePickerMode:(UIDatePickerMode)datePickerMode selectedDate:(NSDate *)selectedDate target:(id)target action:(SEL)action origin:(id)origin;

- (id)initWithTitle:(NSString *)title datePickerMode:(UIDatePickerMode)datePickerMode selectedDate:(NSDate *)selectedDate target:(id)target action:(SEL)action origin:(id)origin;

- (void)eventForDatePicker:(id)sender;

@end
