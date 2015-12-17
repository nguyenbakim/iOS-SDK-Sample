
//  CustomToolbarVC.m
//  ooVooSdkSampleShow
//
//  Created by Udi on 4/1/15.
//  Copyright (c) 2015 ooVoo LLC. All rights reserved.
//

#import "CustomToolbarVC.h"
#import <MediaPlayer/MediaPlayer.h>

@interface CustomToolbarVC ()

@end

@implementation CustomToolbarVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self setMPVolumeButton];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)viewWillDisappear:(BOOL)animated{
   [[NSNotificationCenter defaultCenter]removeObserver:self name:@"OOVOOAudioRouteDidChangeNotification" object:nil];

}

-(void)viewWillAppear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(audioChangeNotification:)
                                                 name:@"OOVOOAudioRouteDidChangeNotification"
                                               object:nil];
}




- (void) audioChangeNotification:(NSNotification *) notification
{
    if (notification.userInfo) {
        __block NSNumber* key = [notification.userInfo objectForKey:@"OOVOOAudioRouteTypeKey"];
        if (key)
        {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                //background processing goes here
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    UIImage *btnImage = [UIImage imageNamed:@"bluetooth"];
                    //TODO: Change file names when resources are available.
  
                    if ([key intValue] == 0)  { // ooVooAudioToEarpiece

                        btnImage = [UIImage imageNamed:@"ear"];
                        
                    }
                    if ([key intValue] == 1) { // ooVooAudioRouteToHeadphones
                        btnImage = [UIImage imageNamed:@"phones"];

                    }
                    if ([key intValue] == 2) { // ooVooAudioRouteToBluetooth
                        btnImage = [UIImage imageNamed:@"bluetooth"];

                    }
                    
                    if ([key intValue] == 3) { 
                        btnImage = [UIImage imageNamed:@"speaker"];
                        
                    }
                    
                    [self.routingSoundButton setImage:btnImage forState:UIControlStateNormal];
                });
            });
        }
        
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


-(void)setMPVolumeButton{
    MPVolumeView *volumeView = [[MPVolumeView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    volumeView.showsVolumeSlider = false;
    [volumeView setRouteButtonImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    UIButton *btn = [self.view viewWithTag:6];
    [btn addSubview:volumeView];
}

#pragma mark - IBAction

- (IBAction)act_ToolbarButtonPressed:(id)sender {

    [_delgate CustomToolBarVC_didClickOnButtonTag:[sender tag]];

    [sender setSelected:![sender isSelected]];
}

#pragma mark - Private Methods.

-(void)resetButtons{
    for (UIButton *btn in self.view.subviews) {
        if ([btn isKindOfClass:[UIButton class]]) {
            [btn setSelected:false];
        }
    }
    
    UIButton *btnCamera=[self.view viewWithTag:toolbar_camera];
    [btnCamera setImage:[UIImage imageNamed:@"camera"] forState:UIControlStateNormal];
}

-(void)setCameraImageForButtonIsOn:(BOOL)isOn{
    
    UIButton *btnCamera=[self.view viewWithTag:toolbar_camera];
    NSString *imageName= isOn?@"camera":@"camera disabled";
    [btnCamera setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    btnCamera.imageView.image=[UIImage imageNamed:imageName];
}

@end
