//
//  VideoFrame.h
//  ooVooSample
//
//  Created by Udi on 8/13/15.
//  Copyright (c) 2015 ooVoo LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ooVooSDK/ooVooSDK.h>
#import <ooVooSDK/ooVooAVChat.h>


//#define WorkWithAdvanced_VideoRenderMode 0

//#if WorkWithAdvanced_VideoRenderMode
@interface VideoFrameUser : UIView<ooVooVideoRender>
//#else
//@interface VideoFrameUser : ooVooVideoPanel
//#endif

@property (nonatomic,strong) UIImageView *img;
@end
