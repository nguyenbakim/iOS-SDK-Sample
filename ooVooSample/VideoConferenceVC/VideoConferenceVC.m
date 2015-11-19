//
//  VideoConferenceVC.m
//  ooVooSample
//
//  Created by Udi on 8/2/15.
//  Copyright (c) 2015 ooVoo LLC. All rights reserved.
//

#import "ActiveUserManager.h"

#import "VideoConferenceVC.h"

#import "UserDefaults.h"

@interface VideoConferenceVC ()

@end

@implementation VideoConferenceVC

#pragma  mark - VIEW CYCLE

- (void)dealloc {
   // [super dealloc];
    
    [_videoPanelView removeFromSuperview];
  
    
    _videoPanelView=nil;
   
    
    [_videoPanelViewRender removeFromSuperview];
    _videoPanelViewRender=nil;

}

-(NSString*)stringFromSelectedClass{
    if ([UserDefaults getBoolForToKey:@"APP_VIDEO_RENDER"]) {
        return @"UserVideoPanelRender";
    }
return @"UserVideoPanel";
}

-(void)removeDelegates{
     self.videoPanelView.delegate=nil;
    self.videoPanelViewRender.delegate=nil;
    
    [super removeDelegates];
  }

-(void)setVideoPanel{
    // the panel render is on top than remove it
    
    if ([UserDefaults getBoolForToKey:@"APP_VIDEO_RENDER"]) // if true we want the custom
    {
        self.videoPanelViewRender.delegate=self;
    [self.sdk.AVChat.VideoController bindVideoRender:[ActiveUserManager activeUser].userId render:self.videoPanelViewRender];
       
        [self.videoPanelView removeFromSuperview];
        self.videoPanelView = nil ;
    }
    else
    {
       
        self.videoPanelView.delegate=self;
    [self.sdk.AVChat.VideoController bindVideoRender:[ActiveUserManager activeUser].userId render:self.videoPanelView];
        [self.videoPanelViewRender removeFromSuperview];
        self.videoPanelViewRender = nil ;

        
    }
}

-(void)checkPanelSize:(id)currentFullScreenPanel{
 
    if (_videoPanelView  && (_videoPanelView == currentFullScreenPanel)){
         [self UserMainPanel_Touched:_videoPanelView];
    }
    
    if (_videoPanelViewRender && (_videoPanelViewRender == currentFullScreenPanel)) {
        [self UserMainPanel_Touched:_videoPanelViewRender];

    }
}


#pragma mark - Orientation
-(id)videoPanel{
    if (self.videoPanelView)
        return self.videoPanelView;
    else
        return self.videoPanelViewRender;
    
}

-(void)setVideoPanelName{
    self.videoPanelView.strUserId = @"Me";
}

-(void)UserMainPanel_Touched:(id)panel{

    if (!isCameraStateOn && (panel == self.videoPanelViewRender || panel==self.videoPanelView))
    {
        return;
    }
    
    if (panel == self.videoPanelViewRender || panel==self.videoPanelView)
    {
    
            NSLog(@"it's the big view");
            [self.viewScroll bringSubviewToFront:panel];
            
            if ( (self.constrainBottomViewVideo.constant==0 && self.videoPanelView ) || (self.constrainBottomViewVideoRender.constant==0 && self.videoPanelViewRender ) )
            {
                [super animateVideoBack];
                if ([self isIpad])
                {
                    [self setScrollViewToXPosition:scrollLastposition];
                } else {
                    [self setScrollViewToYPosition:scrollLastposition];
                }
                
                self.viewScroll.scrollEnabled=true;
                currentFullScreenPanel = NULL;
                [self refreshScrollViewContentSize];
            }
            else if ((self.constrainBottomViewVideo.constant==-44 && self.videoPanelView ) ||
                 (self.constrainBottomViewVideoRender.constant==-44 && self.videoPanelViewRender ) ) // default size before conference Dont resize
                return;
            else
            {
                [self animateVideoToFullSize];
                [self.viewScroll bringSubviewToFront:panel];
                currentFullScreenPanel = panel;
                //_pageControl.hidden=true;
                self.pageControl.hidden=true;
                
                if ([self isIpad]) {
                    scrollLastposition = self.viewScroll.contentOffset.x;
                    [self setScrollViewToXPosition:0];
                } else {
                    scrollLastposition = self.viewScroll.contentOffset.y;
                    [self setScrollViewToYPosition:0];
                }
                self.viewScroll.scrollEnabled=false;
            }
            return;
    }
    else
    {
        [super somePanelTouched:panel];
    }
        
    }
@end









