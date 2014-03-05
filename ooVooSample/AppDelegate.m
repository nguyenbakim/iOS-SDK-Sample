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

#define APP_ID_SETTINGS_KEY       @"APP_ID_SETTINGS_KEY"
#define APP_TOKEN_SETTINGS_KEY    @"APP_TOKEN_SETTINGS_KEY"
#define BACKEND_URL_SETTINGS_KEY  @"BACKEND_URL_SETTINGS_KEY"

static NSString *kDefaultAppId      = @DEFAULT_APP_ID;
static NSString *kDefaultAppToken   = @DEFAULT_APP_TOKEN;
static NSString *kDefaultBackEndURL = @DEFAULT_BACK_END_URL;

@interface AppDelegate ()
{
    BOOL cameraWasStoppedByResignActive;
}

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self setupConnectionParameters];
    
    ooVooInitResult result = [[ooVooController sharedController] initSdk:[[NSUserDefaults standardUserDefaults] stringForKey:APP_ID_SETTINGS_KEY]
                                                        applicationToken:[[NSUserDefaults standardUserDefaults] stringForKey:APP_TOKEN_SETTINGS_KEY]
                                                                 baseUrl:[[NSUserDefaults standardUserDefaults] stringForKey:BACKEND_URL_SETTINGS_KEY]];
    if (result != ooVooInitResultOk)
    {
        NSLog(@"ooVoo SDK initialization failed with result %d", result);
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application;
{
    if ([ooVooController sharedController].cameraEnabled)
    {
        // sends "Turned off camera" to other participants so they don't just see a frozen video
        [ooVooController sharedController].cameraEnabled = NO;
        cameraWasStoppedByResignActive = YES;
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    if (cameraWasStoppedByResignActive)
    {
        // sends "Turned on camera" to other participants so they can resume displaying our video
        [ooVooController sharedController].cameraEnabled = YES;
        cameraWasStoppedByResignActive = NO;
    }
}

#pragma mark - Configuration
- (void)setupConnectionParameters
{
    NSDictionary *defaultParameters = @{ APP_ID_SETTINGS_KEY      : kDefaultAppId,
                                         APP_TOKEN_SETTINGS_KEY   : kDefaultAppToken,
                                         BACKEND_URL_SETTINGS_KEY : kDefaultBackEndURL };
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultParameters];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSString *defaultAppId = [[NSUserDefaults standardUserDefaults] stringForKey:APP_ID_SETTINGS_KEY];
    NSString *defaultAppToken = [[NSUserDefaults standardUserDefaults] stringForKey:APP_TOKEN_SETTINGS_KEY];
    NSString *defaultBackendURL = [[NSUserDefaults standardUserDefaults] stringForKey:BACKEND_URL_SETTINGS_KEY];
    
    NSString *appId = [defaultAppId length]? defaultAppId : defaultParameters[APP_ID_SETTINGS_KEY];
    NSString *appToken = [defaultAppToken length] ? defaultAppToken : defaultParameters[APP_TOKEN_SETTINGS_KEY];
    NSString *backendURL = [defaultBackendURL length] ? defaultBackendURL : defaultParameters[BACKEND_URL_SETTINGS_KEY];
    
    [[NSUserDefaults standardUserDefaults] setValue:appId forKey:APP_ID_SETTINGS_KEY];
    [[NSUserDefaults standardUserDefaults] setValue:appToken forKey:APP_TOKEN_SETTINGS_KEY];
    [[NSUserDefaults standardUserDefaults] setValue:backendURL forKey:BACKEND_URL_SETTINGS_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
@end
