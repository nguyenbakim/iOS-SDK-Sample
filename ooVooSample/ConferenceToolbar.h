//
//  ConferenceToolbar.h
//  ooVooSample
//
//  Created by Clement Barry on 12/12/13.
//  Copyright (c) 2013 ooVoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

typedef enum
{
    BACK_CAMERA    = 0,
    FRONT_CAMERA   = 1,
    MUTE_CAMERA    = 2
} CameraState;

static NSString *const kCameraDidChangeNotification = @"CameraDidChangeNotification";
static NSString *const kCameraNotificationKey = @"CameraNotificationKey";

@interface ConferenceToolbar : UIToolbar

@property (nonatomic, strong) UIBarButtonItem *filtersBarButtonItem;
@property (nonatomic, assign) BOOL filtersEnabled;

@end
