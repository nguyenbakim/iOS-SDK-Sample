//
//  LogInVC.h
//  ooVooSdkSampleShow
//
//  Created by Udi on 3/30/15.
//  Copyright (c) 2015 ooVoo LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ooVooSDK/ooVooSDK.h>

#import "AuthorizationLoaderVc.h"

@interface LogInVC : UIViewController <AuthorizationDelegate, ooVooAccount>

@property (weak, nonatomic) IBOutlet UIView *viewAuthorization_Container;
@property (weak, nonatomic) IBOutlet UITextField *txt_userId;
@property (weak, nonatomic) IBOutlet UITextField *txtDisplayName;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

- (IBAction)act_LogIn:(id)sender;

@property (retain, nonatomic) ooVooClient *sdk;

@end
