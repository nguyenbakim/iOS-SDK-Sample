//
//  BaseVideoConferenceVC.h
//  ooVooSample
//
//  Created by Udi on 9/8/15.
//  Copyright (c) 2015 ooVoo LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIKit.h>
#import <ooVooSDK/ooVooSDK.h>

#import "UserVideoPanel.h"
#import "CustomToolbarVC.h"
#import "InfoViewController.h"
#import "InternetActivityVC.h"


#import "UserVideoPanelRender.h"

@interface BaseVideoConferenceVC : UIViewController<ooVooAVChatDelegate, ooVooVideoControllerDelegate, UITextFieldDelegate>{
    UserVideoPanel *currentFullScreenPanel;     // Saves the panel that is in full screem - tap on the video for full screen.
    CGRect rectLast;
    int scrollLastposition;
    
    
    NSMutableArray *arrDefultConstrain;
    NSMutableArray *arrBackupConstrain;
    
    __weak IBOutlet UIActivityIndicatorView *spinner;
    
    bool isCameraStateOn;       // Flag for camera . On Or Off.
    CustomToolbarVC *toolBar;   // Custom tool bar for video conference .
    NSString * defaultRes;      // Default resolution.
    NSString * currentRes;      // The current resolution.
    NSMutableArray *arrTakenSlot;               // we have 4 slot in sample , 4 places for video transmition
    NSMutableDictionary *ParticipentState;      // Defines the State of the remote video user - can or can't be shown .
    InfoViewController *infoVC;                 // View Controller to display participants .
    InternetActivityVC *InternetActivityView;   // On Top Right Navigation bar - Shows the internet conectivity .
    NSArray *arrEffectList;                     // List of available effect to display on video while transmition.
    NSMutableDictionary *resolutionsHeaders;    // List of resolutions available.
    NSMutableDictionary *participants;          // List of participants name and id's  in session
    
    //    UserVideoPanel *currentFullScreenPanel;     // Saves the panel that is in full screem - tap on the video for full screen.
    CGRect    rectDefaultPanelSize;             // Default small size for video panel.
    CGRect rectMaxSize;                         // max possible size of a panel video
    
    UIDeviceOrientation lastDeviceOrientation;

    
}

@property (retain, nonatomic) ooVooClient *sdk;
@property (weak, nonatomic) IBOutlet UIScrollView *viewScroll;
@property (nonatomic, retain) UIPageControl* pageControl;
@property (weak, nonatomic) IBOutlet UIView *viewTextBox;
@property (weak, nonatomic) IBOutlet UITextField *txt_conferenceId;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constrainTopViewVideo;

// video panel
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constrainRightViewVideo;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constrainBottomViewVideo;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constrainLeftViewVideo;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contrainTopViewText;
//video render
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constrainRightViewVideoRender;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constrainBottomViewVideoRender;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constrainLeftViewVideoRender;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constrainTopViewVideoRender;

@property (weak, nonatomic) IBOutlet UIView *viewForVideoSizeAdjest;
@property (weak, nonatomic) IBOutlet UILabel *lblSdkVersion;

@property (atomic, assign) BOOL isLoggedIn;
@property (atomic, retain) NSMutableDictionary *videoPanels;
@property (atomic, retain) NSMutableDictionary *ParticipentShowOrHide;
@property (nonatomic, retain) NSString *defaultCameraId;

@property (weak, nonatomic) IBOutlet UIView *viewCustomTollbar_container; // container
@property (assign) bool isViewInTransmitMode;  // Flag to know if we are transmiting this user video.

// properties for call conference
@property (assign)bool isCommingFromCall;
@property (nonatomic, retain) NSString *conferenceId;
@property (weak, nonatomic) IBOutlet UIView *viewCover;


+(NSString*)getErrorDescription:(sdk_error)code;
+(NSString*)getStateDescription:(ooVooDeviceState)code;
- (IBAction)act_joinConference:(id)sender;
- (void)animateViewsForState:(BOOL)state;


-(void)removeDelegates;
-(void)animateVideoBack;
-(bool)isIpad;
-(void)refreshScrollViewContentSize;
-(void)setScrollViewToXPosition:(int)xPosition;
-(void)setScrollViewToYPosition:(int)yPosition;
-(void)animateVideoToFullSize;
-(void)somePanelTouched:(id)panel;

@end