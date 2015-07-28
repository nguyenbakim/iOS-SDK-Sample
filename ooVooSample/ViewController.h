//
//  ViewController.h
//  ooVooSdkSampleShow
//
//  Created by Alexander Balasanov on 2/25/15.
//  Copyright (c) 2015 ooVoo LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ooVooSDK/ooVooSDK.h>

#import "UserVideoPanel.h"

#import "CustomToolbarVC.h"



@interface ViewController : UIViewController <ooVooAVChatDelegate, ooVooVideoControllerDelegate, UITextFieldDelegate>
@property (retain, nonatomic) ooVooClient *sdk;

//@property (weak,nonatomic)  NSString *currentEffect;
@property (weak, nonatomic) IBOutlet UIView *viewTextBox;
@property (weak, nonatomic) IBOutlet UILabel *label_sessionId;
@property (weak, nonatomic) IBOutlet UILabel *label_displayname;
@property (weak, nonatomic) IBOutlet UITextField *txtDisplayName;
@property (weak, nonatomic) IBOutlet UITextField *txt_conferenceId;

@property (weak, nonatomic) IBOutlet UILabel *lbl_error;
//@property (weak, nonatomic) IBOutlet UIButton *btn_JoinConference;

@property (retain, nonatomic) IBOutlet UserVideoPanel *videoPanelView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constrainRightViewVideo;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constrainBottomViewVideo;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constrainLeftViewVideo;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contrainTopViewText;

@property (weak, nonatomic) IBOutlet UIView *viewForVideoSizeAdjest;
@property (weak, nonatomic) IBOutlet UILabel *lblSdkVersion;


@property (atomic, assign) BOOL isLoggedIn;
@property (atomic, retain) NSMutableDictionary *videoPanels;
@property (atomic, retain) NSMutableDictionary *ParticipentShowOrHide;
@property (nonatomic, retain) NSString *defaultCameraId;

@property (weak, nonatomic) IBOutlet UIView *viewCustomTollbar_container; // container


- (IBAction)user_id_touch:(id)sender;

+(NSString*)getErrorDescription:(sdk_error)code;

@end
