//
//  CustomToolbarVC.h
//  ooVooSdkSampleShow
//
//  Created by Udi on 4/1/15.
//  Copyright (c) 2015 ooVoo LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    toolbar_mic = 0,
    toolbar_speaker = 1,
    toolbar_camera = 2,
    toolbar_hangUp = 3,
    toolbar_Effects = 4,
    toolbar_resolution = 5,
    toolbar_routingSound = 6,
} toolBarbuttons;

@protocol CustomToolBarVC_DELEGATE <NSObject>
- (void)CustomToolBarVC_didClickOnButtonTag:(int)tagNumber;
@end

@interface CustomToolbarVC : UIViewController

@property (nonatomic, weak) id<CustomToolBarVC_DELEGATE> delgate;
@property (weak, nonatomic) IBOutlet UIButton *routingSoundButton;

-(IBAction)act_ToolbarButtonPressed:(id)sender;
-(void)resetButtons;
-(void)setCameraImageForButtonIsOn:(BOOL)isOn;



@end
