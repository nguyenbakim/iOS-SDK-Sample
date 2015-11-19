//
//  AutorizationLoaderVc.m
//  ooVooSdkSampleShow
//
//  Created by Udi on 3/30/15.
//  Copyright (c) 2015 ooVoo LLC. All rights reserved.
//

#import "AuthorizationLoaderVc.h"
//#import "SettingBundle.h"
#import "FileLogger.h"
#import "UserDefaults.h"


@interface AuthorizationLoaderVc ()
{

}
- (void)autorize;
- (void)onAutorize:(BOOL)error;
@end

@implementation AuthorizationLoaderVc

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.sdk = [ooVooClient sharedInstance];
    self.sdk.AVChat.delegate = self;
    int logLevel =[[UserDefaults getObjectforKey:@"LOG_LEVEL_SETTINGS_KEY"]integerValue];
    [ooVooClient setLogLevel:LogLevelTrace];

    [ooVooClient setLogger:self];
    [self autorize];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Authorization ...

- (void)autorize {
    
    NSString* token =[UserDefaults getObjectforKey:@"APP_TOKEN_SETTINGS_KEY"];
    NSLog(@"Token %@",token);

    [self.sdk authorizeClient:token
                   completion:^(SdkResult *result) {

                       sdk_error err = result.Result;
                       if (err == sdk_error_OK) {
                           NSLog(@"good autorization");
                           sleep(0.5);
                           [_delegate AuthorizationDelegate_DidAuthorized];
                       }
                       else {
                           NSLog(@"fail  autorization");
                           self.btn_Authorizate.hidden = false;
                           self.lbl_Status.font=[UIFont systemFontOfSize:13];
                           self.lbl_Status.text = @"Authorization Failed.";

                           if (err == sdk_error_InvalidToken) {
                               double delayInSeconds = 0.75;
                               dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                               dispatch_after(popTime, dispatch_get_main_queue(), ^(void){

                                   [[[UIAlertView alloc] initWithTitle:@"ooVoo Sdk"
                                                               message:[NSString stringWithFormat:NSLocalizedString(@"Error: %@", nil), @"App Token probably invalid or might be empty.\n\nGet your App Token at http://developer.oovoo.com.\nGo to Settings->ooVooSample screen and set the values, or set @APP_TOKEN constants in code."]
                                                              delegate:nil
                                                     cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                     otherButtonTitles:nil] show];
                               });
                               [_spinner stopAnimating];

                           }
                           else if (err != sdk_error_InvalidToken)
                           {
                               double delayInSeconds = 0.75;
                               dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                               dispatch_after(popTime, dispatch_get_main_queue(), ^(void){

                                   [[[UIAlertView alloc] initWithTitle:@"ooVoo Sdk"
                                                               message:[NSString stringWithFormat:NSLocalizedString(@"Error: %@", nil), [result description]]
                                                              delegate:nil
                                                     cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                     otherButtonTitles:nil] show];
                               });
                               [_spinner stopAnimating];
                           }
                       }

                   }];
}

#pragma mark - IBActions

- (IBAction)act_Authorizate:(id)sender {

    self.lbl_Status.font=[UIFont systemFontOfSize:17];
    _lbl_Status.text = @"Authorization ....  ";
    self.btn_Authorizate.hidden = true;
    [self autorize];
}

- (void)onLog:(LogLevel)level log:(NSString *)log {
    [[FileLogger sharedInstance] log:level message:log];
}

@end
