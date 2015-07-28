//
//  NewUserVC.h
//  ooVooSdkSampleShow
//
//  Created by Udi on 4/14/15.
//  Copyright (c) 2015 ooVoo LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ooVooFamily/ooVooFamily.h>

@interface NewUserVC : UIViewController <UITextFieldDelegate>
@property (retain, nonatomic) ooVooClient *sdk;

- (IBAction)actDone:(id)sender;

- (IBAction)actSelectGender:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *txtUsedID;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;
@property (weak, nonatomic) IBOutlet UITextField *txtDisplayName;
@property (weak, nonatomic) IBOutlet UITextField *txtEmail;
@property (weak, nonatomic) IBOutlet UIButton *btnCreate;
@property (weak, nonatomic) IBOutlet UIButton *btnEnterBrthDay;
@property (weak, nonatomic) IBOutlet UILabel *lblMessage;
@property (weak, nonatomic) NSDate *dateBirthDay;
@end
