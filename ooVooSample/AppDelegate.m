//
// AppDelegate.m
// 
// Created by ooVoo on July 22, 2013
//
// © 2013 ooVoo, LLC.  Used under license. 
//

#import "AppDelegate.h"
#import "ooVooController.h"
#import "MainViewController.h"
#import "LoginParameters.h"
#import "FileLogger.h"


#define APP_ID_SETTINGS_KEY       @"APP_ID_SETTINGS_KEY"
#define APP_TOKEN_SETTINGS_KEY    @"APP_TOKEN_SETTINGS_KEY"
#define BACKEND_URL_SETTINGS_KEY  @"BACKEND_URL_SETTINGS_KEY"
#define LOG_LEVEL_SETTINGS_KEY    @"LOG_LEVEL_SETTINGS_KEY"

static NSString *kDefaultAppId      = @DEFAULT_APP_ID;
static NSString *kDefaultAppToken   = @DEFAULT_APP_TOKEN;
static NSString *kDefaultBackEndURL = @DEFAULT_BACK_END_URL;

@interface AppDelegate ()
{
    BOOL cameraWasStoppedByResignActive;
    BOOL transmitWasStoppedByResignActive;
}

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    
    [self setupConnectionParameters];

    [FileLogger sharedInstance];
    
    [ooVooController setLogLevel: [[NSUserDefaults standardUserDefaults] integerForKey:LOG_LEVEL_SETTINGS_KEY]];
    ooVooInitResult result = [[ooVooController sharedController] initSdk:[[NSUserDefaults standardUserDefaults] stringForKey:APP_ID_SETTINGS_KEY]
                                                        applicationToken:[[NSUserDefaults standardUserDefaults] stringForKey:APP_TOKEN_SETTINGS_KEY]
                                                                 baseUrl:[[NSUserDefaults standardUserDefaults] stringForKey:BACKEND_URL_SETTINGS_KEY]];
    if (result != ooVooInitResultOk)
    {
        NSLog(@"ooVoo SDK initialization failed with result %d", result);

        NSString *reason;
        if (result == ooVooInitResultAppIdNotValid) {
            reason = @"AppID invalid, might be empty.\n\nGet your App ID and App Token at http://developer.oovoo.com.\nGo to Settings->ooVooSample screen and set the values, or set @DEFAULT_APP_ID and @DEFAULT_APP_TOKEN constants in code.";
        } else if(result == ooVooInitResultInvalidToken) {
            reason = @"Token invalid, might be empty.\n\nGet your App ID and App Token at http://developer.oovoo.com.\nGo to Settings->ooVooSample screen and set the values, or set @DEFAULT_APP_ID and @DEFAULT_APP_TOKEN constants in code.";
        } else {
            reason = [[ooVooController sharedController] errorMessageForOoVooInitResult:result];
        }

        double delayInSeconds = 0.75;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            
        [[[UIAlertView alloc] initWithTitle:@"Init ooVoo Sdk"
                                message:[NSString stringWithFormat:NSLocalizedString(@"Error: %@", nil), reason]
                                delegate:nil
                                cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                otherButtonTitles:nil] show];
        });
    } else {
        self.isSdkInited = YES;
    }
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application;
{
    if ([ooVooController sharedController].transmitEnabled)
    {
        [ooVooController sharedController].transmitEnabled = NO;
        transmitWasStoppedByResignActive = YES;
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    if (transmitWasStoppedByResignActive && [ooVooController sharedController].cameraEnabled)
    {
        // sends "Turned on camera" to other participants so they can resume displaying our video
        [ooVooController sharedController].transmitEnabled = YES;
        transmitWasStoppedByResignActive = NO;
    }
}

#pragma mark - Configuration
- (void)setupConnectionParameters
{
    NSDictionary *defaultParameters = @{ APP_ID_SETTINGS_KEY      : kDefaultAppId,
                                         APP_TOKEN_SETTINGS_KEY   : kDefaultAppToken,
                                         BACKEND_URL_SETTINGS_KEY : kDefaultBackEndURL,
                                         LOG_LEVEL_SETTINGS_KEY   : [NSNumber numberWithInt:ooVooDebug]};
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultParameters];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSString *defaultAppId = [[NSUserDefaults standardUserDefaults] stringForKey:APP_ID_SETTINGS_KEY];
    NSString *defaultAppToken = [[NSUserDefaults standardUserDefaults] stringForKey:APP_TOKEN_SETTINGS_KEY];
    NSString *defaultBackendURL = [[NSUserDefaults standardUserDefaults] stringForKey:BACKEND_URL_SETTINGS_KEY];
    int defaultLogLevel = [[NSUserDefaults standardUserDefaults]  integerForKey:LOG_LEVEL_SETTINGS_KEY];
    
    NSString *appId = [defaultAppId length]? defaultAppId : defaultParameters[APP_ID_SETTINGS_KEY];
    NSString *appToken = [defaultAppToken length] ? defaultAppToken : defaultParameters[APP_TOKEN_SETTINGS_KEY];
    NSString *backendURL = [defaultBackendURL length] ? defaultBackendURL : defaultParameters[BACKEND_URL_SETTINGS_KEY];
    NSNumber *logLevel = [NSNumber numberWithInt:defaultLogLevel];
    
    [[NSUserDefaults standardUserDefaults] setValue:appId forKey:APP_ID_SETTINGS_KEY];
    [[NSUserDefaults standardUserDefaults] setValue:appToken forKey:APP_TOKEN_SETTINGS_KEY];
    [[NSUserDefaults standardUserDefaults] setValue:backendURL forKey:BACKEND_URL_SETTINGS_KEY];
    [[NSUserDefaults standardUserDefaults] setValue:logLevel forKey:LOG_LEVEL_SETTINGS_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
@end
