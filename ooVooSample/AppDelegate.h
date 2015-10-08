//
//  AppDelegate.h
//  ooVooSdkSampleShow
//
//  Created by Alexander Balasanov on 2/25/15.
//  Copyright (c) 2015 ooVoo LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"
 

@interface AppDelegate : UIResponder <UIApplicationDelegate >
{
    UINavigationController *navigationController ;
    UIStoryboard *mainStoryboard ;
    ViewController *viewVideoControler ;

}

@property (strong, nonatomic) UIWindow *window;


@end
