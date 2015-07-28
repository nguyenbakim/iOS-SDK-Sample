//
//  DatePickerVC.h
//  ooVooFamilySampleShow
//
//  Created by Udi on 5/6/15.
//  Copyright (c) 2015 ooVoo LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DatePickerVC_Delegate <NSObject>

- (void)DatePickerVC_doneWithDate:(NSDate *)date;

@end

@interface DatePickerVC : UIViewController
@property (weak, nonatomic) id<DatePickerVC_Delegate> delegate;

@property (weak, nonatomic) IBOutlet UIDatePicker *pickerBirthDay;
- (IBAction)actPickerChangedValue:(id)sender;

- (IBAction)actFinish:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *lblSelectedDate;

@end
