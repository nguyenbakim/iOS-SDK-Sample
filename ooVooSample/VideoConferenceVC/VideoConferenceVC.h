//
//  VideoConferenceVC.h
//  ooVooSample
//
//  Created by Udi on 8/2/15.
//  Copyright (c) 2015 ooVoo LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit/UIKit.h>
#import <ooVooSDK/ooVooSDK.h>

#import "UserVideoPanel.h"
#import "CustomToolbarVC.h"

#import "BaseVideoConferenceVC.h"
#import "UserVideoPanelRender.h"


//#import "UserVideoPanelRender.h"


@interface VideoConferenceVC : BaseVideoConferenceVC <ooVooAVChatDelegate, ooVooVideoControllerDelegate, UITextFieldDelegate>

@property (retain, nonatomic) IBOutlet UserVideoPanel *videoPanelView;
@property (retain, nonatomic) IBOutlet UserVideoPanelRender *videoPanelViewRender;



@end

