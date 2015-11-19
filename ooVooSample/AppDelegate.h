//
//  AppDelegate.h
//  ooVooSdkSampleShow
//
//  Created by Alexander Balasanov on 2/25/15.
//  Copyright (c) 2015 ooVoo LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoConferenceVC.h"

 

@interface AppDelegate : UIResponder <UIApplicationDelegate >
{
    UINavigationController *navigationController ;
    UIStoryboard *mainStoryboard ;
    VideoConferenceVC *viewVideoControler ;

  //  VideoConferenceVCWithRender *viewVideoControllerRender;
    

}

@property (strong, nonatomic) UIWindow *window;
    @property (retain, nonatomic) ooVooClient *sdk;

@end
