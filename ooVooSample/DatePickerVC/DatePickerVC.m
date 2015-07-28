//
//  DatePickerVC.m
//  ooVooFamilySampleShow
//
//  Created by Udi on 5/6/15.
//  Copyright (c) 2015 ooVoo LLC. All rights reserved.
//

#import "DatePickerVC.h"
#import "UIView-Extensions.h"

@interface DatePickerVC ()

@end

@implementation DatePickerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.pickerBirthDay.maximumDate = [NSDate date];
    _lblSelectedDate.text = [self pickerSelectedDateString];

    [self.view addBorderToAllButtons];
}
- (void)viewWillAppear:(BOOL)animated {
    self.navigationItem.title = @"Select Date";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)actPickerChangedValue:(id)sender {

    _lblSelectedDate.text = [self pickerSelectedDateString];
}

- (NSString *)pickerSelectedDateString {

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];

    [dateFormatter setDateFormat:@"dd-MM-yyyy"];

    NSString *formatedDate = [dateFormatter stringFromDate:self.pickerBirthDay.date];
    return formatedDate;
}
- (IBAction)actFinish:(id)sender {

    if ([sender tag] == 2) // set
    {
        [_delegate DatePickerVC_doneWithDate:self.pickerBirthDay.date];
    }

    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
