//
//  AppDelegate.m
//  ooVooSdkSampleShow
//
//  Created by Alexander Balasanov on 2/25/15.
//  Copyright (c) 2015 ooVoo LLC. All rights reserved.
//

#import <ooVooSDK/ooVooSDK.h>
#import "AppDelegate.h"
#import "FileLogger.h"

#import "UserDefaults.h"
#import "SettingBundle.h"




#define User_isInVideoView @"User_isInVideoView"


 

#define APP_TOKEN_SETTINGS_KEY    @"APP_TOKEN_SETTINGS_KEY"
#define LOG_LEVEL_SETTINGS_KEY    @"LOG_LEVEL_SETTINGS_KEY"

@interface AppDelegate ()<UIAlertViewDelegate>

@end

@implementation AppDelegate



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

 
 
 
    [UserDefaults setBool:NO ToKey:User_isInVideoView];
    
    [self setupConnectionParameters];
    
    
    return YES;
}



- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    ooVooClient *sdk = [ooVooClient sharedInstance];
    [sdk.AVChat.VideoController stopTransmitVideo];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    //    if ([UserDefaults getBoolForToKey:User_isInVideoView]) {
    //        <#statements#>
    //    }
    ooVooClient *sdk = [ooVooClient sharedInstance];
    [sdk.AVChat.VideoController startTransmitVideo];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Configuration
- (void)setupConnectionParameters
{
    NSDictionary *curParameters =
  @{
    APP_TOKEN_SETTINGS_KEY   : [[SettingBundle sharedSetting] getSettingForKey:@"settingBundle_AppToken"],
    LOG_LEVEL_SETTINGS_KEY   : [[SettingBundle sharedSetting] getSettingForKey:@"settingBundle_SDK_LogLevel"]
    };
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:curParameters];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSString *curAppToken = [[NSUserDefaults standardUserDefaults] stringForKey:APP_TOKEN_SETTINGS_KEY];
    int curLogLevel = [[NSUserDefaults standardUserDefaults]  integerForKey:LOG_LEVEL_SETTINGS_KEY];
    
    NSString *appToken = curAppToken;
    NSNumber *logLevel = [NSNumber numberWithInt:curLogLevel];
    
    [[SettingBundle sharedSetting] setSettingKey:@"settingBundle_AppToken" WithValue:appToken];
    [[SettingBundle sharedSetting] setSettingKey:@"settingBundle_SDK_LogLevel" WithValue:logLevel];
    
    [[NSUserDefaults standardUserDefaults] setValue:appToken forKey:APP_TOKEN_SETTINGS_KEY];
    [[NSUserDefaults standardUserDefaults] setValue:logLevel forKey:LOG_LEVEL_SETTINGS_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];

    
 
}

 

 
 
 
 
 
 
 
 
 
 
 
 

// orientation

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    if ([self isIpad]) {
        return UIInterfaceOrientationMaskAll;
    }
    
    return ( UIInterfaceOrientationMaskPortraitUpsideDown | UIInterfaceOrientationMaskPortrait);
}
-(BOOL)shouldAutorotate
{
    return YES;
}


-(BOOL)isIpad{
#define IDIOM    UI_USER_INTERFACE_IDIOM()
#define IPAD     UIUserInterfaceIdiomPad
    
    if ( IDIOM == IPAD ) {
        return true;
    } else {
        return  false;
    }
}

@end
