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
//#import "SettingBundle.h"

#import "MessageManager.h"
#import "AlertView.h"
#import "ActiveUserManager.h"

#define User_isInVideoView @"User_isInVideoView"


 

#define APP_TOKEN_SETTINGS_KEY    @"APP_TOKEN_SETTINGS_KEY"
#define LOG_LEVEL_SETTINGS_KEY    @"LOG_LEVEL_SETTINGS_KEY"
#define APP_VIDEO_RENDER            @"APP_VIDEO_RENDER"
#define APP_MESSAGING            @"APP_MESSAGING"
 

#ifndef TOKEN
#define TOKEN @"Put Your Token Here"
#endif



@interface AppDelegate ()<UIAlertViewDelegate>{
    AlertView *alert ;
}

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
self.sdk = [ooVooClient sharedInstance];
    
#ifdef DEBUG
    NSLog(@"Debug mode no Hockey");
#else
 
 
 

#endif
    
   
    
    [UserDefaults setBool:NO ToKey:User_isInVideoView];
    
    [self setupConnectionParameters];
    
    
    [[MessageManager sharedMessage]initSdkMessage]; // a singeltone for retrieve a message of a incoming call
    
    navigationController = (UINavigationController *)self.window.rootViewController;
    mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    
    
    viewVideoControler = (VideoConferenceVC *)[mainStoryboard instantiateViewControllerWithIdentifier:@"VideoConferenceVC"];
    
    [self SetNotificationObserversForCallMessaging];
    

NSLog(@"%d",[UserDefaults getBoolForToKey:APP_VIDEO_RENDER]);
    return YES;
}



- (void)applicationWillResignActive:(UIApplication *)application {
    [ooVooClient applicationWillResignActive];
    
    bool isMessaging = [[[NSUserDefaults standardUserDefaults] stringForKey:APP_MESSAGING]boolValue];
    if (!isMessaging) {
        ooVooClient *sdk = [ooVooClient sharedInstance];
        [sdk.Messaging disconnect];
    }
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [ooVooClient applicationDidEnterBackground];
    ooVooClient *sdk = [ooVooClient sharedInstance];
    [sdk.AVChat.VideoController stopTransmitVideo];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [ooVooClient applicationWillEnterForeground];
    ooVooClient *sdk = [ooVooClient sharedInstance];
    [sdk.AVChat.VideoController startTransmitVideo];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
   [ooVooClient applicationDidBecomeActive];

    bool isMessaging = [[[NSUserDefaults standardUserDefaults] stringForKey:APP_MESSAGING]boolValue];
    if (!isMessaging) {
        ooVooClient *sdk = [ooVooClient sharedInstance];
        [sdk.Messaging connect];
    }
 }

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Configuration
- (void)setupConnectionParameters
{
 
    // accours only once on first run - set first value
    NSDictionary *dicAppToken = [NSDictionary dictionaryWithObject:TOKEN forKey:APP_TOKEN_SETTINGS_KEY];
    NSDictionary *dicAppLogLevl = [NSDictionary dictionaryWithObject:@6 forKey:LOG_LEVEL_SETTINGS_KEY];
    NSDictionary *dicAppRender = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:false] forKey:APP_VIDEO_RENDER];
    NSDictionary *dictAppMessaging = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:true] forKey:APP_MESSAGING];

    [[NSUserDefaults standardUserDefaults] registerDefaults:dicAppLogLevl];
    [[NSUserDefaults standardUserDefaults] registerDefaults:dicAppToken];
    [[NSUserDefaults standardUserDefaults] registerDefaults:dicAppRender];
    [[NSUserDefaults standardUserDefaults] registerDefaults:dictAppMessaging];
    
    [NSUserDefaults standardUserDefaults].synchronize;
    
    // if something changed by the user in the setting bundle
    NSString *curAppToken = [[NSUserDefaults standardUserDefaults] stringForKey:APP_TOKEN_SETTINGS_KEY];
    bool isVideoRender = [[NSUserDefaults standardUserDefaults] stringForKey:APP_VIDEO_RENDER];

    int curLogLevel = [[NSUserDefaults standardUserDefaults]  integerForKey:LOG_LEVEL_SETTINGS_KEY];
    NSNumber *logLevel = [NSNumber numberWithInt:curLogLevel];

    NSLog(@"value %@", [[NSUserDefaults standardUserDefaults] stringForKey:APP_MESSAGING]);
     bool isMessaging = [[[NSUserDefaults standardUserDefaults] stringForKey:APP_MESSAGING]boolValue];
    
    [[NSUserDefaults standardUserDefaults] setValue:curAppToken forKey:APP_TOKEN_SETTINGS_KEY];
    [[NSUserDefaults standardUserDefaults] setValue:logLevel forKey:LOG_LEVEL_SETTINGS_KEY];
    [[NSUserDefaults standardUserDefaults] setBool:isMessaging forKey:APP_MESSAGING];
    
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

- (void)SetNotificationObserversForCallMessaging {
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(incomingCall:) name:@"incomingCall" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(AnswerAccept:) name:@"AnswerAccept" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(killVideoController) name:@"killVideoController" object:nil];
     [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(callCancel) name:@"callCancel" object:nil];
    
}

-(void)incomingCall:(NSNotification*)notif{
    
    
    NSLog(@"notification %@",notif.userInfo);
    CNMessage *message=[notif object];
    
    // if we are in video "ROOM" and i am transmitting video on other session Than i am busy
    if ([navigationController.topViewController isKindOfClass:[VideoConferenceVC class]])
    {
        VideoConferenceVC *viewController = navigationController.topViewController;
        
        if (viewController.isViewInTransmitMode && !viewController.conferenceId)
        {
            [[MessageManager sharedMessage]messageOtherUsers:[NSArray arrayWithObject:message.fromUseriD]  WithMessageType:Busy WithConfID:viewVideoControler.conferenceId Compelition:^(BOOL CallSuccess) {
                
            }];
            return;
        }
        
    }
//    else if ([navigationController.topViewController isKindOfClass:[VideoConferenceVCWithRender class]])
//    {
//        VideoConferenceVCWithRender *viewController = navigationController.topViewController;
//        
//        if (viewController.isViewInTransmitMode && !viewController.conferenceId)
//        {
//            [[MessageManager sharedMessage]messageOtherUser:message.fromUseriD WithMessageType:Busy WithConfID:viewVideoControllerRender.conferenceId];
//            return;
//        }
//        
//    }
    
    alert = [[AlertView alloc]initWithTitle:@"Incoming Call" message:message.fromUseriD delegate:self cancelButtonTitle:@"Reject" otherButtonTitles:@"Answer", nil];
    alert.from=message.fromUseriD;
    alert.conferenceID=message.confId;
    
    [alert show];
}

-(void)AnswerAccept:(NSNotification*)notif // after i called other user HE accepted my call
{
    
    NSLog(@"notification %@",notif.userInfo);
    CNMessage *message=[notif object];
    
    [self passToVideoConferenceWithConferenceId:message.confId fromUserID:message.fromUseriD];
    
}



-(void)killVideoController{
    viewVideoControler=nil;
    viewVideoControler = (VideoConferenceVC *)[mainStoryboard instantiateViewControllerWithIdentifier:@"VideoConferenceVC"];
    
//    viewVideoControllerRender=nil;
//    viewVideoControllerRender = (VideoConferenceVCWithRender*)[mainStoryboard instantiateViewControllerWithIdentifier:@"VideoConferenceVCWithRender"];

    
}

-(void)callCancel{
    // the caller canceled his call than remove alert
    [alert dismissWithClickedButtonIndex:2 animated:YES]; // no real index 2 button , means call canceled
}

#pragma mark - Alertview Delegate

-(void)alertView:(AlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{

//    call canceled by the caller
    if (buttonIndex==2)
    {
        alertView=nil;
        return;
    }
    if (buttonIndex!=alertView.cancelButtonIndex) // I accepted the call
    {
   //     if (![UserDefaults getBoolForToKey:@"APP_VIDEO_RENDER"]) // if it's oovoo panel render
        {
            if (viewVideoControler.conferenceId)
            { // if there is allready a conference id send it
                [[MessageManager sharedMessage]messageOtherUsers:[NSArray arrayWithObject:alertView.from] WithMessageType:AnswerAccept WithConfID:viewVideoControler.conferenceId Compelition:^(BOOL CallSuccess) {
                    
                }] ;
            }
            else
            { // this a new conference so we take the id from the user that called
                
                
                [[MessageManager sharedMessage]messageOtherUsers:[NSArray arrayWithObject:alertView.from] WithMessageType:AnswerAccept WithConfID:alertView.conferenceID Compelition:^(BOOL CallSuccess) {
                    
                }];
                
                // if i am in the room video but not is a transmited mode then make it be i transmitted mode
                if ([navigationController.topViewController isKindOfClass:[VideoConferenceVC class]])
                {
                    VideoConferenceVC *viewController = navigationController.topViewController;
                    viewController.isCommingFromCall=true;
                    viewController.conferenceId=alertView.conferenceID;
                    viewController.isCommingFromCall=true;
                    [viewController act_joinConference:nil];
                }
                else
                {
                    [self passToVideoConferenceWithConferenceId:alertView.conferenceID fromUserID:alertView.from];
                }
            }

        }
//        else{
//            
//            if (viewVideoControllerRender.conferenceId)
//            { // if there is allready a conference id send it
//                [[MessageManager sharedMessage]messageOtherUser:alertView.from WithMessageType:AnswerAccept WithConfID:viewVideoControler.conferenceId];
//            }
//            else
//            { // this a new conference so we take the id from the user that called
//                
//                
//                [[MessageManager sharedMessage]messageOtherUser:alertView.from WithMessageType:AnswerAccept WithConfID:alertView.conferenceID];
//                
//                // if i am in the room video but not is a transmited mode then make it be i transmitted mode
//                if ([navigationController.topViewController isKindOfClass:[VideoConferenceVCWithRender class]])
//                {
//                    VideoConferenceVCWithRender *viewController = navigationController.topViewController;
//                    viewController.isCommingFromCall=true;
//                    viewController.conferenceId=alertView.conferenceID;
//                    viewController.isCommingFromCall=true;
//                    [viewController act_joinConference:nil];
//                }
//                else
//                {
//                    [self passToVideoConferenceWithConferenceId:alertView.conferenceID fromUserID:alertView.from];
//                }
//            }
//
//        }
        
        
        
    }
    else // I rejected the call
    {
        [[MessageManager sharedMessage]messageOtherUsers:[NSArray arrayWithObject:alertView.message] WithMessageType:AnswerDecline WithConfID:alertView.conferenceID Compelition:^(BOOL CallSuccess) {
            
        }];
    }
    
    alertView=nil;
    
}
 

-(void)passToVideoConferenceWithConferenceId:(NSString*)confID fromUserID:(NSString*)userID{
    
  //  if (![UserDefaults getBoolForToKey:@"APP_VIDEO_RENDER"]) // if it's oovoo panel render
    {
        viewVideoControler.isCommingFromCall=true;
        viewVideoControler.conferenceId=confID;
        
        
        NSLog(@"In Pass to video converence PUSH with conferenceid %@",confID);
        
        
        
        
        if(![navigationController.topViewController isKindOfClass:[VideoConferenceVC class]])
        {// if view controller is not shown yet
            
            @try {
                 [navigationController pushViewController:viewVideoControler animated:NO];
            } @catch (NSException * ex) {
                NSLog(@"Exception: %@", ex);
                //“Pushing the same view controller instance more than once is not supported”
                //NSInvalidArgumentException
                NSLog(@"Exception: [%@]:%@",[ex  class], ex );
                NSLog(@"ex.name:'%@'", ex.name);
                NSLog(@"ex.reason:'%@'", ex.reason);
                //Full error includes class pointer address so only care if it starts with this error
                NSRange range = [ex.reason rangeOfString:@"Pushing the same view controller instance more than once is not supported"];
                
                if ([ex.name isEqualToString:@"NSInvalidArgumentException"] &&
                    range.location != NSNotFound) {
                    //view controller already exists in the stack - just pop back to it
                    [navigationController popToViewController:viewVideoControler animated:NO];
                } else {
                    NSLog(@"ERROR:UNHANDLED EXCEPTION TYPE:%@", ex);
                }
            }
            @finally {
                //NSLog(@"finally");
            }

           
        }
        else // view is allready on
        {
            
        }
        
    }
//    else
//    {
//        viewVideoControllerRender.isCommingFromCall=true;
//        viewVideoControllerRender.conferenceId=confID;
//        
//        
//        NSLog(@"In Pass to video converence PUSH with conferenceid %@",confID);
//        
//        
//        if(![navigationController.topViewController isKindOfClass:[VideoConferenceVCWithRender class]])
//        {// if view controller is not shown yet
//            [navigationController pushViewController:viewVideoControllerRender animated:YES];
//        }
//        else // view is allready on
//        {
//            
//        }
//    }
    
    
    
    
    }

#pragma mark - Push notification

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    NSLog(@"My token is: %@", deviceToken);
    const unsigned *tokenBytes = [deviceToken bytes];
    NSString *hexToken = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",
                          ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]),
                          ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]),
                          ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];
    [ActiveUserManager activeUser].token = hexToken;
    NSLog(@"My token is: %@", [ActiveUserManager activeUser].token);
    
    
    [UserDefaults setObject:[ActiveUserManager activeUser].token ForKey:[ActiveUserManager activeUser].userId];
    
    NSString * uuid = [[NSUUID UUID] UUIDString] ;
    NSString * token = [ActiveUserManager activeUser].token;
    
    if(token && token.length > 0){
        [self.sdk.PushService subscribe:token deviceUid:uuid completion:^(SdkResult *result)
         {
             [ActiveUserManager activeUser].isSubscribed = true;
         }];
        
    }
    
}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    NSLog(@"user info %@",userInfo);
    
}
- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    NSLog(@"Failed to get token, error: %@", error);
    
}

@end
