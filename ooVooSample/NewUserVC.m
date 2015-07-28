
//  NewUserVC.m
//  ooVooSdkSampleShow
//
//  Created by Udi on 4/14/15.
//  Copyright (c) 2015 ooVoo LLC. All rights reserved.
//

#import "NewUserVC.h"
#import "FriendsListVc.h"
#import "UIView-Extensions.h"
#import "DatePickerVC.h"

#define Segue_ShowFriend @"Segue_ShowFriend"
#define Segue_SelectBirthDay @"Segue_SelectBirthDay"

@interface NewUserVC () <DatePickerVC_Delegate>

@end

@implementation NewUserVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.sdk = [ooVooClient sharedInstance];
    //self.sdk.Account.delegate=self;

    UIButton *btn = [self.view viewWithTag:100];
    [btn setSelected:true];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];

    // self.pickerBirthDay.maximumDate=[NSDate date];

    [self addBorder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqual:Segue_SelectBirthDay]) {
        DatePickerVC *date = [segue destinationViewController];
        date.delegate = self;
    }
}

- (BOOL)isUserIdEmpty {

    // removing white space from start and end
    if ([[self.txtDisplayName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {

        [self showMessage:@"Please enter full name"];
        return true;
    }

    if ([[self.txtEmail.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
        [self showMessage:@"Please enter email"];
        self.txtPassword.text = @"";
        return true;
    }
    // removing white space from start and end
    if ([[self.txtPassword.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {

        [self showMessage:@"Please enter password"];
        return true;
    }

    if ([[self.txtUsedID.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
        [self showMessage:@"Please enter username"];
        self.txtPassword.text = @"";
        return true;
    }
    return false;
}

NSTimer *timer1;

- (void)showMessage:(NSString *)strMessage {
    [timer1 invalidate];
    _lblMessage.text = strMessage;

    [UIView animateWithDuration:1.0
                     animations:^{
                       _lblMessage.alpha = 1;
                     }];

    timer1 = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(hideMessage) userInfo:nil repeats:NO];
}

- (void)hideMessage {
    NSLog(@"hides message");

    [UIView animateWithDuration:1.0
                     animations:^{
                       _lblMessage.alpha = 0;
                     }];
    [timer1 invalidate];
}

#pragma mark -Textfield Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return true;
}

- (void)keyboardDidShow:(NSNotification *)notification {
    NSDictionary *info = notification.userInfo;
    NSValue *value = info[UIKeyboardFrameEndUserInfoKey];

    CGRect rawFrame = [value CGRectValue];
    CGRect keyboardFrame = [self.view convertRect:rawFrame fromView:nil];

    NSLog(@"keyboardFrame: %@", NSStringFromCGRect(keyboardFrame));
}

//- (IBAction)actPickerChangedValue:(id)sender {
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//
//    [dateFormatter setDateFormat:@"dd-MM-yyyy"];
//
//    NSString *formatedDate = [dateFormatter stringFromDate:self.pickerBirthDay.date];
//
//
//    NSLog(@"selected date = %@",formatedDate);
//
//}

- (IBAction)actDone:(id)sender {

    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setDay:10];
    [comps setMonth:10];
    [comps setYear:2000];
    NSDate *date = [[NSCalendar currentCalendar] dateFromComponents:comps];

    [sender setEnabled:false];

    [self.sdk.Account create:_txtUsedID.text
                    password:_txtPassword.text
                 displayName:_txtDisplayName.text
                       email:_txtEmail.text
                    birthday:_dateBirthDay
                      gender:[self getSlectedGenderType]
                  completion:^(SdkResult *result) {
                    NSLog(@"add account %@ and code %d \n description %@", result.userInfo, result.Result, result.description);

                    //        -40000 invalid parameter
                    //        -60302 useid taken

                    if (result.Result != 0) {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:result.description delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                        [alert show];
                    } else {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Congratulations" message:result.description delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                        [alert show];

                        sleep(1);
                        [self performSegueWithIdentifier:Segue_ShowFriend sender:nil];
                    }

                    [sender setEnabled:true];
                  }];

    //    [self.sdk.Account create:_txtUsedID.text password:_txtPassword.text displayName:_txtDisplayName.text email:_txtEmail.text birthday:self.dateBirthDay gender:[self getSlectedGenderType] completion_handler:^(SdkResult *result) {
    //        NSLog(@"add account %@ and code %d \n description %@",result.userInfo,result.Result,result.description);
    //
    ////        -40000 invalid parameter
    ////        -60302 useid taken
    //
    //        if (result.Result != 0) {
    //            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:result.description delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    //            [alert show];
    //        }
    //        else
    //        {
    //            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Congratulations" message:result.description delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    //            [alert show];
    //
    //            sleep(1);
    //            [self performSegueWithIdentifier:Segue_ShowFriend sender:nil];
    //
    //
    //        }
    //
    //            [sender setEnabled:true];
    //    }];
}

- (IBAction)actSelectGender:(id)sender {
    // 100 =male
    // 101 = female

    UIButton *btn = [self.view viewWithTag:100];
    [btn setSelected:false];

    btn = [self.view viewWithTag:101];
    [btn setSelected:false];

    [sender setSelected:true];
}

- (GenderType)getSlectedGenderType {
    UIButton *btn = [self.view viewWithTag:100];

    if (btn.selected)
        return Male;
    else
        return Female;
}

- (void)addBorder {
    _btnCreate.layer.borderColor = _btnEnterBrthDay.layer.borderColor = [UIColor blackColor].CGColor;
    _btnCreate.layer.borderWidth = _btnEnterBrthDay.layer.borderWidth = 0.5;
    _btnCreate.layer.cornerRadius = _btnEnterBrthDay.layer.cornerRadius = 5;
}
- (NSString *)returnStringForDate:(NSDate *)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];

    [dateFormatter setDateFormat:@"dd-MM-yyyy"];

    NSString *formatedDate = [dateFormatter stringFromDate:date];
    return formatedDate;
}

#pragma mark - DatePickerDelegate

- (void)DatePickerVC_doneWithDate:(NSDate *)date {
    self.dateBirthDay = date;
    [_btnEnterBrthDay setTitle:[self returnStringForDate:date] forState:UIControlStateNormal];
}
@end
