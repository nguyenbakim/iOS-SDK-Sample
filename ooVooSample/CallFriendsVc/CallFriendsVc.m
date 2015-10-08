//
//  CallFriendsVc.m
//  ooVooSample
//
//  Created by Udi on 7/26/15.
//  Copyright (c) 2015 ooVoo LLC. All rights reserved.
//

#import "CallFriendsVc.h"
#import "CustomToolbarVC.h"



#define Segue_ToCustomToolBar @"ToCustomToolBar"

@interface CallFriendsVc ()<CustomToolBarVC_DELEGATE,UserVideoPanelDELEGATE>
{
    CustomToolbarVC *toolBar;   // Custom tool bar for video conference .
}

@end

@implementation CallFriendsVc

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    
      [self saveMaxFrameSize];

    [self saveDefaultFrameSize];
}


-(void)dealloc{
    
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqual:Segue_ToCustomToolBar]) {
        toolBar = segue.destinationViewController;
        toolBar.delgate = self;
    }
}

- (void)initSDKInitializer {
    
//    self.sdk = [ooVooClient sharedInstance];
//    self.sdk.AVChat.delegate = self;
//    self.sdk.AVChat.VideoController.delegate = self;
//    
//    self.videoPanelView.delegate=self;
//    currentRes = [self.sdk.AVChat.VideoController getConfig:ooVooVideoControllerConfigKeyResolution];
//    
//    PluginWrapper* pl_wrapper = [[PluginWrapper alloc] init ];
//    [self.sdk.AVChat registerPlugin: pl_wrapper];
//    
//    [self.sdk.AVChat.VideoController bindVideoRender:nil/*[ActiveUserManager activeUser].userId*/ render:self.videoPanelView];
//    [self.sdk.AVChat.VideoController openCamera];
//    
//    arrEffectList = [self.sdk.AVChat.VideoController getEffectsList];
}

-(void)removeDelegates{
//    self.sdk.AVChat.delegate = nil;
//    self.sdk.AVChat.VideoController.delegate = nil;
//    self.videoPanelView.delegate=nil;
//    infoVC.delegate=nil;
//    toolBar.delgate = nil;
}
#pragma mark - Private Methods

- (void)initFirstInitialize {
    
//    participants = [NSMutableDictionary new];
//    
//    [self initResolutionHeaders];
//    [self resetArraySlots];
//    
//    isViewInTransmitMode = NO;
//    isCameraStateOn = NO;
//    self.isLoggedIn = NO;
//    
//    self.lbl_error.hidden = YES;
//    
//    self.videoPanels = [NSMutableDictionary new];
//    [self.videoPanels setObject:self.videoPanelView forKey:[ActiveUserManager activeUser].userId];
//    
//    self.ParticipentShowOrHide=[NSMutableDictionary new];
//    ParticipentState=[NSMutableDictionary new];
//    
//    self.videoPanelView.strUserId = @"Me";
//    self.viewCustomTollbar_container.hidden = true;
//    
//    _lblSdkVersion.text =    [ooVooClient getSdkVersion];
//    
    
    
}

//#define TopSpace 10
-(void)saveMaxFrameSize{
    
//    rectMaxSize.origin.x=0;
//    rectMaxSize.origin.y=0;
//    rectMaxSize.size.width=self.view.width;
//    rectMaxSize.size.height=self.view.height-_viewCustomTollbar_container.height;
    
}


//#define TopSpace 10
-(void)saveDefaultFrameSize{
//    NSLog(@"view height %f",_viewForVideoSizeAdjest.size.height);
//    
//    //    rectDefaultPanelSize=self.videoPanelView.frame;
//    rectDefaultPanelSize.origin.x=15;
//    rectDefaultPanelSize.size.width=_viewForVideoSizeAdjest.width-28;
//    rectDefaultPanelSize.size.width/=2;
//    rectDefaultPanelSize.size.width-=space;
//    
//    rectDefaultPanelSize.size.height=(_viewForVideoSizeAdjest.height)/2 -11;
//    
//    if (isViewInTransmitMode) {
//        rectDefaultPanelSize.size.height=rectDefaultPanelSize.size.height -(154/2);
//    }
//    
//    rectDefaultPanelSize.origin.y=13;
//    
//    NSLog(@"rect1: %@", NSStringFromCGRect(rectDefaultPanelSize));
}





@end
