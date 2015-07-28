//
//  LogInVC.m
//  ooVooSdkSampleShow
//
//  Created by Udi on 3/30/15.
//  Copyright (c) 2015 ooVoo LLC. All rights reserved.
//

#import "LogInVC.h"
#import "UIView-Extensions.h"
#import "ActiveUserManager.h"

#import "SettingBundle.h"
#import "UserDefaults.h"

#define User_isInVideoView @"User_isInVideoView"

#define Segue_Authorization @"ToAuthorizationView"
#define Segue_PushTo_ConferenceVC @"ConferenceVC"

#define UserDefault_UserId @"UserID"


@interface LogInVC () {
  
    __weak IBOutlet UIActivityIndicatorView *spinner;
}

@end

@implementation LogInVC

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.

    self.sdk = [ooVooClient sharedInstance];
    self.sdk.Account.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    
    _txt_userId.text = [self randomUser];
    
    UIButton *btnLoging = [self.view viewWithTag:100];
    btnLoging.enabled = true;
    self.navigationItem.title = @"Login";
}
- (void)viewDidDisappear:(BOOL)animated {
    self.txt_userId.text = @"";
}


#pragma mark - Navigation

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([identifier isEqualToString:Segue_Authorization]) {
        if ([UserDefaults getBoolForToKey:User_isInVideoView]) {
            [self performSegueWithIdentifier:Segue_PushTo_ConferenceVC sender:nil];
            return NO;
        }
    }
    return YES;
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.

    if ([segue.identifier isEqualToString:Segue_Authorization]) {
        AuthorizationLoaderVc *authoVC = segue.destinationViewController;
        authoVC.delegate = self;
    }
}

#pragma mark - Authorization Delegate

- (void)AuthorizationDelegate_DidAuthorized {

    [UIView animateWithDuration:1
                     animations:^{

                       //        self.viewAuthorization_Container.y=-self.viewAuthorization_Container.height;
                       self.viewAuthorization_Container.alpha = 0;

                     }];
}

#pragma mark - IBAction

- (IBAction)act_LogIn:(id)sender {
    
    if ([self isUserIdEmpty])
        return;
    [UserDefaults setObject:_txt_userId.text ForKey:UserDefault_UserId];
    
    [sender setEnabled:false];
    [spinner startAnimating];
    
    [self.sdk.Account login:self.txt_userId.text
                 completion:^(SdkResult *result) {
                     NSLog(@"result code=%d result description %@", result.Result, result.description);
                     [spinner stopAnimating];
                     if (result.Result){
                         [[[UIAlertView alloc] initWithTitle:@"Login Error" message:result.description delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
                          [self.loginButton setEnabled:true];
                     }
                     else
                         [self onLogin:result.Result];
                 }];
}


#pragma mark - private methods

- (BOOL)isUserIdEmpty {

    // removing white space from start and end
    if ([[self.txt_userId.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"UserId Missing" message:@"Please enter userId " delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];

        self.txt_userId.text = @"";

        return true;
    }

    if (self.txt_userId.text.length < 6) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Characters Missing" message:@"UserId Must contain at least 6 characters " delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];

        return true;
    }

    return false;
}


- (void)onLogin:(BOOL)error {
    if (!error) {
        [ActiveUserManager activeUser].userId = self.txt_userId.text;
        [self performSegueWithIdentifier:Segue_PushTo_ConferenceVC sender:nil];
    }else{
        [self.loginButton setEnabled:true];
    }

    //
    //    [self.sdk.AVChat.VideoController bindVideoRender:self.userId render:self.videoView];
    //
    //    [self.sdk.AVChat.VideoController openCamera];
    //    self.btn_JoinConference.hidden   = NO ;
    //    self.txt_userId.text = @"" ;
}

- (NSString *)randomUser {
    
    if ([UserDefaults getObjectforKey:UserDefault_UserId]) {
        return [UserDefaults getObjectforKey:UserDefault_UserId];
    }
    
//    
//    uint32_t num = 6;
//    NSMutableString *string = [NSMutableString stringWithCapacity:num];
//
//    [string appendFormat:@"%@_", [[UIDevice currentDevice] name]];
//    for (int i = 0; i < num; i++) {
//        [string appendFormat:@"%C", (unichar)('a' + arc4random_uniform(25))];
//    }
    return @"";
}

#pragma mark - ooVoo Account delegate

- (void)didAccountLogIn:(id<ooVooAccount>)account {
    
}
- (void)didAccountLogOut:(id<ooVooAccount>)account {
    
}


@end
