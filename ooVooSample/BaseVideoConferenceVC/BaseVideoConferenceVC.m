//
//  BaseVideoConferenceVC.m
//  ooVooSample
//
//  Created by Udi on 9/8/15.
//  Copyright (c) 2015 ooVoo LLC. All rights reserved.
//

#import "BaseVideoConferenceVC.h"

#include <sys/sysctl.h>
#import <ooVooSDK/ooVooSDK.h>

//#import <AffdexPlugin/AffdexPlugin.h>
//#import "ViewController.h"
#import "UIView-Extensions.h"
#import "ActiveUserManager.h"
#import "UserDefaults.h"
//#import "EffectSampleFactoryIOS.h"
#import "UIActionSheet+Extensions.h"
#import "TableListVC.h"
#import "FileLogger.h"

#define kUserId @"kUserId"
#define Segue_ToCustomToolBar @"ToCustomToolBar"
#define UserDefaults_ConferenceId @"ConferenceID"
#define Segue_Info @"Segue_Info"
#define Segue_EffectList @"Segue_EffectList"
#define User_isInVideoView @"User_isInVideoView"
#define String_Empty @""
#define space 4


@interface BaseVideoConferenceVC ()<CustomToolBarVC_DELEGATE, UIActionSheetDelegate,UserVideoPanelDELEGATE,InfoViewController_DELEGATE,TableList_DELEGATE,UIScrollViewDelegate/*, AffdexDetectorDelegate*/>
@end

@implementation BaseVideoConferenceVC


#pragma  mark - VIEW CYCLE

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initFirstInitialize];     // UI and first settings ....
    [self initSDKInitializer];      // SDK init and settings
    [self initConferenceTextField]; // set the conference id if was set by the user before .
    [self setBackButton];           // set the back button selector.
    [self setNavigationBarProfileButtonShow:NO]; // shows the join Button .
    self.defaultCameraId = [self.sdk.AVChat.VideoController getConfig:ooVooVideoControllerConfigKeyCaptureDeviceId];
    currentRes = defaultRes = [self.sdk.AVChat.VideoController getConfig:ooVooVideoControllerConfigKeyResolution];
    lastDeviceOrientation=[[UIDevice currentDevice]orientation];
    
    if (_isCommingFromCall)
    {
        _viewCover.hidden=false;
        [self.view bringSubviewToFront:_viewCover];
        [self.viewCustomTollbar_container setHidden:false];
        [self.view bringSubviewToFront:spinner];
    }
    
    if (_isCommingFromCall) {
        [self act_joinConference:nil];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (void)viewDidDisappear:(BOOL)animated {
    [UserDefaults setBool:NO ToKey:User_isInVideoView];
    _pageControl.hidden=true;
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationItem.title = @"Conference";
    
    if (_pageControl.numberOfPages>1 && [self isIpad]) {
        _pageControl.hidden=false;
    }
}

-(void)viewDidLayoutSubviews{
    if (lastDeviceOrientation != [[UIDevice currentDevice] orientation] &&  [self isIpad]) {
        [self fixOrientationLayout:[[UIDevice currentDevice] orientation]];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    
    [UserDefaults setBool:YES ToKey:User_isInVideoView];
    [self saveMaxFrameSize];
    infoVC=nil;
    [self saveDefaultFrameSize];
    
//    if (_isCommingFromCall) {
//        [self act_joinConference:nil];
//    }
    
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)dealloc {

    [self onLog:LogLevelSample log:@"Dealloc Video Conference "];
    
    if ([self isIpad])
        [[NSNotificationCenter defaultCenter]removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    
    arrDefultConstrain = nil;
    arrBackupConstrain = nil;
    spinner=nil;
    toolBar=nil;
    currentRes=nil;
    arrTakenSlot=nil;
    ParticipentState=nil;
    infoVC=nil;
    InternetActivityView=nil;
    arrEffectList=nil;
    currentFullScreenPanel=nil;
    _videoPanels=nil;
    _ParticipentShowOrHide=nil;
    _conferenceId=nil;
    _isCommingFromCall=NO;

}

-(void)removeDelegates{
    self.sdk.AVChat.delegate = nil;
    self.sdk.AVChat.VideoController.delegate = nil;
    infoVC.delegate=nil;
    toolBar.delgate = nil;
}

#pragma mark - Orientation

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)orientation
{//2
    if ([self isIpad])
    {
        [self saveDefaultFrameSize];
        [self saveMaxFrameSize];
        [self checkOrientationAndFixIfNeeded:orientation];
    }
}

-(void)checkOrientationAndFixIfNeeded:(UIInterfaceOrientation)orientation{//3
    if ([self shouldPerformfixOrientation])
    {
        NSLog(@"EXCEPTION FIXING VIEW LAYOUT !!!!!!!!!");
        [self fixOrientationLayout:orientation];
    }
}

-(BOOL)shouldPerformfixOrientation{//4
    
    
    NSLog(@"viewForVideoSizeAdjest.size.width1 %f",_viewForVideoSizeAdjest.width);
  NSLog(@"rectMaxSize.size.width %f",rectMaxSize.size.width);

    
    
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft || [[UIDevice currentDevice] orientation ]== UIDeviceOrientationLandscapeRight)
    {
        NSLog(@"Lanscapse");
        NSLog(@"window %@",NSStringFromCGRect([UIScreen mainScreen].applicationFrame));
        if (rectMaxSize.size.width < _viewForVideoSizeAdjest.size.width) {
            return YES;
        }
        
    }
    if([[UIDevice currentDevice] orientation] == UIDeviceOrientationPortrait || [[UIDevice currentDevice] orientation] == UIDeviceOrientationPortraitUpsideDown )
    {
        NSLog(@"UIDeviceOrientationPortrait");
        NSLog(@"window %@",NSStringFromCGRect([UIScreen mainScreen].applicationFrame));
        NSLog(@"viewForVideoSizeAdjest.size.width %f",_viewForVideoSizeAdjest.width);
        NSLog(@"rectMaxSize.size.width %f",rectMaxSize.size.width);
        if (rectMaxSize.size.width > _viewForVideoSizeAdjest.size.width) {
            return YES;
        }
        
    }
    return NO;
}


-(void)fixOrientationLayout:(UIDeviceOrientation)orientation
{
    if (!_isViewInTransmitMode) {
        lastDeviceOrientation=orientation;
        return;
    }
    
    if ( (orientation == UIDeviceOrientationFaceDown) || (orientation == UIDeviceOrientationFaceUp) ) {
        return;
    }
    
    if (lastDeviceOrientation == orientation) {
        return;
    }
    
    
    NSLock  *theLock=[NSLock new] ;
    
    [theLock lock];
    
    lastDeviceOrientation=orientation;
    
    NSLog(@"Enter lock ");
    
    [self animateViewsForState:true];
    [self animateViewsForState:false];
    
    [self saveDefaultFrameSize];
    [self saveMaxFrameSize];
  
    if ([self checkPanelSize:currentFullScreenPanel]) {
    //    [self UserMainPanel_Touched:[self videoPanel]];
    }
    
    // fix the panels in place
    for (int i=1 ; i<[arrTakenSlot count]; i++) {
        if (![arrTakenSlot[i]isEqualToString:String_Empty]) // if the place is taken
        {
            id panel = self.videoPanels[arrTakenSlot[i]];
            [self setPanel:panel inPosition:i Animated:NO];
            
            if (panel==currentFullScreenPanel) // if there is a full screen panel
            {
                [self UserVideoPanel_Touched:panel];
            }
        }
    }
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        dispatch_async(dispatch_get_main_queue(), ^(void){
            if (self.navigationItem.rightBarButtonItems) {
                [self setNavigationBarProfileButtonShow:YES];
            }
        });
    });

    NSLog(@"end lock ");
    [self setScrollViewToXPosition:scrollLastposition];
    [theLock unlock];
}

-(BOOL)checkPanelSize:(id )currentFullScreenPanel{
    
    return NO;
}

-(void)printOrientationType{
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    switch (orientation)
    {
        case UIDeviceOrientationUnknown:
            NSLog(@"UIDeviceOrientationUnknown");
            break;
            
        case UIDeviceOrientationPortrait:
            NSLog(@"UIDeviceOrientationPortrait");
            break;
            
        case UIDeviceOrientationPortraitUpsideDown:
            NSLog(@"UIDeviceOrientationPortraitUpsideDown");
            break;
            
        case UIDeviceOrientationLandscapeLeft:
            NSLog(@"UIDeviceOrientationLandscapeLeft");
            break;
            
            
        case UIDeviceOrientationLandscapeRight:
            NSLog(@"UIDeviceOrientationLandscapeRight");
            break;
            
        case UIDeviceOrientationFaceUp:
            NSLog(@"UIDeviceOrientationFaceUp");
            break;
            
            
        case UIDeviceOrientationFaceDown:
            NSLog(@"UIDeviceOrientationFaceDown");
            break;
            
    }
}

// Works on ipad only !
- (void)orientationChanged:(NSNotification *)notification{
    
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    switch (orientation)
    {
        case UIDeviceOrientationUnknown:
            NSLog(@"UIDeviceOrientationUnknown");
            break;
            
        case UIDeviceOrientationPortrait:
            NSLog(@"UIDeviceOrientationPortrait");
            break;
            
        case UIDeviceOrientationPortraitUpsideDown:
            NSLog(@"UIDeviceOrientationPortraitUpsideDown");
            break;
            
        case UIDeviceOrientationLandscapeLeft:
            NSLog(@"UIDeviceOrientationLandscapeLeft");
            break;
            
            
        case UIDeviceOrientationLandscapeRight:
            NSLog(@"UIDeviceOrientationLandscapeRight");
            break;
            
        case UIDeviceOrientationFaceUp:
            NSLog(@"UIDeviceOrientationFaceUp");
            break;
            
            
        case UIDeviceOrientationFaceDown:
            NSLog(@"UIDeviceOrientationFaceDown");
            break;
    }
    
}


- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration NS_DEPRECATED_IOS(2_0,8_0, "Implement viewWillTransitionToSize:withTransitionCoordinator: instead"){
    scrollLastposition = self.viewScroll.contentOffset.x;
    
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)orientation duration:(NSTimeInterval)duration NS_DEPRECATED_IOS(3_0,8_0, "Implement viewWillTransitionToSize:withTransitionCoordinator: instead"){
    NSLog(@"Orientation change");
    [self printOrientationType];
    NSLog(@"rect default size %@",NSStringFromCGRect(_viewForVideoSizeAdjest.frame));
    NSLog(@" %s %s", __PRETTY_FUNCTION__, __FUNCTION__);

    [self fixOrientationLayout:orientation];

}

#pragma mark - scroll view

-(void)setScrollViewToXPosition:(int)xPosition{
    
    [self.viewScroll scrollRectToVisible:CGRectMake(xPosition, 0, self.viewScroll.frame.size.width, self.viewScroll.frame.size.height) animated:NO];
    
}

-(void)setScrollViewToYPosition:(int)yPosition{
    
    [self.viewScroll scrollRectToVisible:CGRectMake(0, yPosition, self.viewScroll.frame.size.width, self.viewScroll.frame.size.height) animated:NO];
    
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    
    if (currentFullScreenPanel) {
        scrollView.scrollEnabled=false;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    // Switch the indicator when more than 50% of the previous/next page is visible
    
    CGFloat pageWidth = self.viewScroll.frame.size.width;
    int page = floor((self.viewScroll.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = page;
    
}

-(void)refreshScrollViewContentSize{
    
    int numberOfViews =([arrTakenSlot count]-1)/4;
    
    if ([self isIpad])
    {
        self.viewScroll.contentSize=CGSizeMake(_viewForVideoSizeAdjest.width * (numberOfViews +1) , _viewScroll.height);
    }
    else // is iphone
    {
        self.viewScroll.contentSize=CGSizeMake(_viewScroll.width , _viewForVideoSizeAdjest.height * (numberOfViews +1));
    }
    
    if ([self isIpad]) {
        _pageControl.numberOfPages=numberOfViews +1;
        _pageControl.hidden= numberOfViews?false:true;
        NSLog(@"view width size = %f",(numberOfViews+1)*_viewForVideoSizeAdjest.width);
        
    }
    
}

#pragma mark - Private Methods

- (void)initFirstInitialize {
    
    participants = [NSMutableDictionary new];
    
    [self initResolutionHeaders];
    [self resetArraySlots];
    
    _isViewInTransmitMode = NO;
    isCameraStateOn = NO;
    self.isLoggedIn = NO;

    self.videoPanels = [NSMutableDictionary new];
    [self.videoPanels setObject:[self videoPanel] forKey:[ActiveUserManager activeUser].userId];
    
    self.ParticipentShowOrHide=[NSMutableDictionary new];
    ParticipentState=[NSMutableDictionary new];

    [self setVideoPanelName];
    
    self.viewCustomTollbar_container.hidden = true;
    
    _lblSdkVersion.text =    [ooVooClient getSdkVersion];
    
    _pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(0, 0, 200, 37)];
    _pageControl.pageIndicatorTintColor=[UIColor blackColor];
    _pageControl.currentPageIndicatorTintColor=[UIColor orangeColor];
    _pageControl.center=self.navigationController.navigationBar.center ;
    _pageControl.y=20;
    _pageControl.hidden=true;
    self.navigationController.navigationBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.navigationController.navigationBar addSubview:_pageControl];
    
    if ([self isIpad])
        [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(orientationChanged:)name:UIDeviceOrientationDidChangeNotification  object:nil];
    
    scrollLastposition=0;
    
}

-(UserVideoPanel*)videoPanel{
    return nil;
}

-(void)setVideoPanelName{
  // will get in the sun method
}

- (void)initSDKInitializer {
    
    self.sdk = [ooVooClient sharedInstance];
    self.sdk.AVChat.delegate = self;
    self.sdk.AVChat.VideoController.delegate = self;
    currentRes = [self.sdk.AVChat.VideoController getConfig:ooVooVideoControllerConfigKeyResolution];

//    AffdexPluginSettings* afffdexSettings  = [AffdexPluginSettings new];
//    afffdexSettings.allExpressions     = YES;
//    afffdexSettings.allEmotions        = YES;
//    afffdexSettings.smile              = YES;
//    afffdexSettings.browFurrow         = YES;
//    afffdexSettings.browRaise          = YES;
//    afffdexSettings.browFurrow         = YES;
//    afffdexSettings.lipCornerDepressor = YES;
//    afffdexSettings.valence            = YES;
//    afffdexSettings.engagement         = YES;
//    
//    [afffdexSettings setClassifierPath:[[NSBundle mainBundle] pathForResource:@"data" ofType:nil]];
//    
//    AffdexPluginFactory* affdexPluginFactory = [[AffdexPluginFactory alloc] initWithSettings:afffdexSettings delegate:self];
//    [self.sdk.AVChat registerPlugin:affdexPluginFactory];

    [self setVideoPanel];
    [self.sdk.AVChat.VideoController openCamera];
    arrEffectList = [self.sdk.AVChat.VideoController getEffectsList];
}

- (void)initResolutionHeaders {
    resolutionsHeaders = [NSMutableDictionary new];
    [resolutionsHeaders setObject:@"Not Specified" forKey:[NSNumber numberWithInt:0]];
    [resolutionsHeaders setObject:@"Low" forKey:[NSNumber numberWithInt:1]];
    [resolutionsHeaders setObject:@"Medium" forKey:[NSNumber numberWithInt:2]];
    [resolutionsHeaders setObject:@"High" forKey:[NSNumber numberWithInt:3]];
    [resolutionsHeaders setObject:@"HD" forKey:[NSNumber numberWithInt:4]];
}

-(void)setVideoPanel{
// will get in the sun method
}

- (void)setBackButton {
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(checkAndGoBack)];
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.leftBarButtonItem = item;
}

- (void)checkAndGoBack {
//    _isCommingFromCall?[self onHangUp:nil]:[self closeViewAndGoBack];
    if ([self.navigationItem.leftBarButtonItem.title isEqualToString:@"Back"])
    {
        [self closeViewAndGoBack];
    }
    else
    {
        [self onHangUp:nil];
    }
   
}

- (void)onHangUp:(id)sender {
    
    if (isCameraStateOn) {
       [self.sdk.AVChat.VideoController openCamera];
         id <ooVooEffect> effect = arrEffectList[0];
          [self handleEffectSelection:nil effectId:effect.effectID];
        
      

    }
    
    [self leaveSession];
    [self.navigationItem.leftBarButtonItem setTitle:@"Back"];
}

-(void)leaveSession{
    
    if (_isCommingFromCall) {
        [self closeViewAndGoBack];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"killVideoController" object:nil];
        return;
    }
    
    [self.sdk.AVChat.VideoController unbindVideoRender:nil render:[self videoPanel]];
    [self.sdk.AVChat leave];
    [self.sdk.AVChat.AudioController unInitAudio:^(SdkResult *result) {
        NSLog(@"unInit Resoult %d",result.Result);
    }];
    
    
}
-(void)closeViewAndGoBack{
    
    [self.sdk.AVChat.VideoController closeCamera];
    [self removeDelegates];
    [self.navigationController popViewControllerAnimated:YES];
    [self.sdk.AVChat leave];
     [self.sdk.AVChat.AudioController unInitAudio:^(SdkResult *result) {
        NSLog(@"unInit Resoult %d",result.Result);
    }];
}

- (void)setNavigationBarProfileButtonShow:(BOOL)show {
    
    if (!show) {
        self.navigationItem.rightBarButtonItems=nil ;
        
        UIBarButtonItem *btnJoin = [[UIBarButtonItem alloc] initWithTitle:@"Join" style:UIBarButtonItemStylePlain target:self action:@selector(act_joinConference:)];
        
        self.navigationItem.rightBarButtonItem=btnJoin;
        return;
    }
    
    // want's to show
    
    UIBarButtonItem *btnEditUserInfo = [[UIBarButtonItem alloc] initWithTitle:@"Info" style:UIBarButtonItemStylePlain target:self action:@selector(pushToEditUserInfo)];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    int score=-1;
    if (InternetActivityView) {
        score = InternetActivityView.score;
    }
    
    InternetActivityView=nil;
    InternetActivityView = [storyboard instantiateViewControllerWithIdentifier:@"InternetActivityVC"];
    InternetActivityView.view.frame=CGRectMake(0, 0, 26, 25);
    InternetActivityView.view.backgroundColor=[UIColor clearColor];
    
    if (score>0)
        [InternetActivityView setInternetActivityLevel:[NSNumber numberWithInt:score]];
    
    UIBarButtonItem *btnInternetConnection = [[UIBarButtonItem alloc] initWithCustomView:InternetActivityView.view];
    
    UIBarButtonItem *btnSecurity = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Lock"] style:UIBarButtonItemStyleDone target:self action:nil];
    btnSecurity.tag=200;
    
    // [btnSecurity setTintColor: [UIColor clearColor]];
    self.navigationItem.rightBarButtonItems = @[ btnEditUserInfo, /* fixedSpaceBarButtonItem,  */ btnInternetConnection,btnSecurity];
    
    
//    disable navigation bar translucent.
    self.navigationController.navigationBar.translucent = NO;
    
}

- (void)initConferenceTextField {
    if ([UserDefaults getObjectforKey:UserDefaults_ConferenceId]) {
        _txt_conferenceId.text = [UserDefaults getObjectforKey:UserDefaults_ConferenceId];
    }
}


-(NSString *)currentEffect{
    NSLog(@"current effect %@",[self.sdk.AVChat.VideoController getConfig:ooVooVideoControllerConfigKeyEffectId]);
    return [self.sdk.AVChat.VideoController getConfig:ooVooVideoControllerConfigKeyEffectId];
}

#pragma mark Panel Slots

-(int)getSelectedUidIndex:(NSString*)uid{
    for (int i=0; i<[arrTakenSlot count]; i++) {
        if ([arrTakenSlot[i]isEqualToString:uid]) {
            return i;
        }
        
    }
    return 0; // will not reach here
}

-(int)getFirstemptySlot{
    for (int i=0; i<[arrTakenSlot count]; i++) {
        if ([arrTakenSlot[i]isEqualToString:String_Empty]) {
            return i;
        }
        
    }
    return 0; // will not reach here
}

-(void)resetArraySlots{
    arrTakenSlot=[[NSMutableArray alloc]initWithObjects:[ActiveUserManager activeUser].userId,nil];
}


#pragma mark spinner

- (void)showAndRunSpinner:(BOOL)wait {
    if (wait) {
        [spinner startAnimating];
        [self setJoinButtonEnable:false];
        
    } else {
        [spinner stopAnimating];
      //  [self setJoinButtonEnable:true];
        
    }
}


#pragma mark - Navigation

-(void)infoVCSetData{
    infoVC.participants = participants;
    infoVC.arrParticipants = [self getParticipantsNameList];
    infoVC.strConferenceId = _txt_conferenceId.text;
    [infoVC.table reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqual:Segue_ToCustomToolBar]) {
        toolBar = segue.destinationViewController;
        toolBar.delgate = self;
    }
    
    if ([segue.identifier isEqual:Segue_Info]) {
        infoVC = segue.destinationViewController;
        if (!infoVC.delegate) {
            infoVC.delegate=self;
        }
        [self infoVCSetData];
    }
    
    if ([segue.identifier isEqual:Segue_EffectList]) {
        TableListVC *tableVC=segue.destinationViewController;
        tableVC.delegate=self;
        tableVC.arrList=(NSArray*)sender;
        
        for (int i=0; i<[arrEffectList count]; i++) {
            id<ooVooEffect> effect = arrEffectList[i];
            if ([effect.effectID isEqualToString:[self currentEffect]]) {
                tableVC.selectedIndex=i;
                return;
            }
        } //for
        tableVC.selectedIndex=0;
    }
}

- (void)pushToEditUserInfo {
    
    [self performSegueWithIdentifier:Segue_Info sender:nil]; // add participants
}

#pragma mark - IBAction

-(void)setJoinButtonEnable:(BOOL)enable{
    UIBarButtonItem *btn=self.navigationItem.rightBarButtonItem;
    btn.enabled=enable;
    
}

- (IBAction)act_joinConference:(id)sender {
    
    [self.view endEditing:YES];
    [self showAndRunSpinner:YES];
    NSLog(@"conference id %@",_txt_conferenceId.text);
    
    [UserDefaults setObject:_txt_conferenceId.text ForKey:UserDefaults_ConferenceId];
    [self setJoinButtonEnable:false];
    
    [self.sdk.AVChat.AudioController initAudio:^(SdkResult *result) {
        [self.sdk.AVChat.VideoController setConfig:currentRes forKey:ooVooVideoControllerConfigKeyResolution];
        
        if([self currentEffect])
            [self.sdk.AVChat.VideoController setConfig:[self currentEffect] forKey:ooVooVideoControllerConfigKeyEffectId];
        
        NSLog(@"result %d description ", result.Result, result.description);
        
        //[self.sdk updateConfig:^(SdkResult *result){
            NSString *displayName = [[ActiveUserManager activeUser].displayName length] > 0 ? [ActiveUserManager activeUser].displayName : [ActiveUserManager activeUser].userId;
            [self.sdk.AVChat.VideoController startTransmitVideo];
            if (_isCommingFromCall)
            {
                [self.sdk.AVChat join:_conferenceId user_data:displayName];
            }
            else
            {
                [self.sdk.AVChat join:self.txt_conferenceId.text user_data:displayName];
            }
        }];
    //}];
}

#pragma mark - VideoControllerDelegate

- (void)didRemoteVideoStateChange:(NSString *)uid state:(ooVooAVChatRemoteVideoState)state width:(const int)width height:(const int)height error:(sdk_error)code
{
    [self onLog:LogLevelSample log:[NSString stringWithFormat:@"State %d And code %@",state,[BaseVideoConferenceVC getErrorDescription:code]]];
    
    if (state == (ooVooAVChatRemoteVideoStateStopped /* || ooVooAVChatRemoteVideoStatePaused */))
    {
        [ParticipentState setObject:[NSNumber numberWithBool:false] forKey:uid];
        
        UserVideoPanel *panel = _videoPanels[uid];
        if (panel==currentFullScreenPanel) {
            [self animate:panel ToFrame:rectLast];
            currentFullScreenPanel = NULL;
            [self refreshScrollViewContentSize];
        }

    }
    
    else if (state == ooVooAVChatRemoteVideoStatePaused )
    {
        UserVideoPanel *panel = _videoPanels[uid];
        //  [panel showAvatar:true];
    }
    
    else
    {
        [self saveDefaultFrameSize];
        [self saveMaxFrameSize];
        
        [ParticipentState setObject:[NSNumber numberWithBool:true] forKey:uid];
        if ([_ParticipentShowOrHide[uid] integerValue]==0)
        {
            UserVideoPanel *panel = _videoPanels[uid];
            // panel.isAllowedToChangeImage=false;
            
            [panel showAvatar:true];
            
        }
        
    }
    
    UserVideoPanel* panel = [self.videoPanels objectForKey:uid];
    
    if(state == ooVooAVChatRemoteVideoStatePaused && panel){
        [panel showVideoAlert:YES] ;
    }
    
    if(state == ooVooAVChatRemoteVideoStateResumed && panel){
        [panel showVideoAlert:NO] ;
    }
    
    if (infoVC)
    {
        [self infoVCSetData];

    }
}

- (void)didCameraStateChange:(ooVooDeviceState)state devId:(NSString *)devId width:(const int)width height:(const int)height fps:(const int)fps error:(sdk_error)code;
{
    //NSLog(@"didCameraStateChange -> state [%@], code = [%d]", state ? @"Opened" : @"Fail", code);
    [self onLog:LogLevelSample log:[NSString stringWithFormat:@"State %@ And code %@",[BaseVideoConferenceVC getStateDescription:state],[BaseVideoConferenceVC getErrorDescription:code]]];
    if (state) {
        //[self.sdk.AVChat.VideoController startTransmitVideo];
        //[self.sdk.AVChat.VideoController openPreview];
    }
}

- (void)didVideoTransmitStateChange:(BOOL)state devId:(NSString *)devId error:(sdk_error)code {
    //   NSLog(@"didVideoTransmitStateChanged -> state [%@], code = [%d]", state ? @"Opened" : @"Fail", code);
    [self onLog:LogLevelSample log:[NSString stringWithFormat:@"State %d And code %@",state,[BaseVideoConferenceVC getErrorDescription:code]]];
    
    [self showAndRunSpinner:NO];
}

- (void)didVideoPreviewStateChange:(BOOL)state devId:(NSString *)devId error:(sdk_error)code {
    //  NSLog(@"didVideoPreviewStateChange -> state [%@], code = [%d]", state ? @"Opened" : @"Fail", code);
    [self onLog:LogLevelSample log:[NSString stringWithFormat:@"State %d And code %@",state,[BaseVideoConferenceVC getErrorDescription:code]]];
    
    isCameraStateOn = state;
    
}

#pragma mark - ANIMATION  Video view Proccess


- (void)restoreVideoConstrains {
    // text box constrain
    self.contrainTopViewText.constant = [arrDefultConstrain[0] integerValue];
    [self animateConstraints];

    if ([self isCustomRenderView])
    {
        self.constrainRightViewVideoRender.constant = [arrDefultConstrain[1] integerValue];
        self.constrainBottomViewVideoRender.constant = [arrDefultConstrain[2] integerValue];
        self.constrainLeftViewVideoRender.constant = [arrDefultConstrain[3] integerValue];
        self.constrainTopViewVideoRender.constant = [arrDefultConstrain[4] integerValue];
    }
    else
    {
    // video constrain
    self.constrainRightViewVideo.constant = [arrDefultConstrain[1] integerValue];
    self.constrainBottomViewVideo.constant = [arrDefultConstrain[2] integerValue];
    self.constrainLeftViewVideo.constant = [arrDefultConstrain[3] integerValue];
    self.constrainTopViewVideo.constant = [arrDefultConstrain[4] integerValue];
    }
    [self animateConstraints];
    
}

- (void)animateViewsForState:(BOOL)state {
    
    // saving the initial constrain to return it back when needed
    
    if (!arrDefultConstrain)
    {
        arrDefultConstrain = [[NSMutableArray alloc] initWithCapacity:5];
        [arrDefultConstrain addObject:[NSNumber numberWithInt:self.contrainTopViewText.constant]];      // 0
        
        if ([self isCustomRenderView])
        {
            [arrDefultConstrain addObject:[NSNumber numberWithInt:self.constrainRightViewVideoRender.constant]];  // 1
            [arrDefultConstrain addObject:[NSNumber numberWithInt:self.constrainBottomViewVideoRender.constant]]; // 2
            [arrDefultConstrain addObject:[NSNumber numberWithInt:self.constrainLeftViewVideoRender.constant]]; // 3
            [arrDefultConstrain addObject:[NSNumber numberWithInt:self.constrainTopViewVideoRender.constant]]; // 4
        }
        else{
            [arrDefultConstrain addObject:[NSNumber numberWithInt:self.constrainRightViewVideo.constant]];  // 1
            [arrDefultConstrain addObject:[NSNumber numberWithInt:self.constrainBottomViewVideo.constant]]; // 2
            [arrDefultConstrain addObject:[NSNumber numberWithInt:self.constrainLeftViewVideo.constant]]; // 3
            [arrDefultConstrain addObject:[NSNumber numberWithInt:self.constrainTopViewVideo.constant]]; // 4
        }
       
    }
    
    if (!state) // false = take view up for conference
    {
        
        // text box constrain
        self.contrainTopViewText.constant -= self.viewTextBox.frame.size.height;
        [self animateConstraints];
          [arrBackupConstrain addObject:[NSNumber numberWithInt:self.contrainTopViewText.constant]];      // 0
        
        if ([self isCustomRenderView]) {
            // video constrain
            self.constrainRightViewVideoRender.constant += (self.viewForVideoSizeAdjest.width/2)+space;
            self.constrainLeftViewVideoRender.constant =space;
            
            self.constrainBottomViewVideoRender.constant += (self.viewForVideoSizeAdjest.height/2)+space;
            self.constrainBottomViewVideoRender.constant += self.viewCustomTollbar_container.height;
            self.constrainTopViewVideoRender.constant=space;
            _isViewInTransmitMode = true;
            
            // saving the small size video constrains
            // if (!arrBackupConstrain)
            
            arrBackupConstrain=nil;
            arrBackupConstrain = [[NSMutableArray alloc] initWithCapacity:5];
            [arrBackupConstrain addObject:[NSNumber numberWithInt:self.contrainTopViewText.constant]];      // 0
            [arrBackupConstrain addObject:[NSNumber numberWithInt:self.constrainRightViewVideoRender.constant]];  // 1
            [arrBackupConstrain addObject:[NSNumber numberWithInt:self.constrainBottomViewVideoRender.constant]]; // 2
            [arrBackupConstrain addObject:[NSNumber numberWithInt:self.constrainLeftViewVideoRender.constant]]; // 2
            [arrBackupConstrain addObject:[NSNumber numberWithInt:self.constrainTopViewVideoRender.constant]]; // 2

        }
        else
        {
            // video constrain
            self.constrainRightViewVideo.constant += (self.viewForVideoSizeAdjest.width/2)+space;
            self.constrainLeftViewVideo.constant =space;
            
            self.constrainBottomViewVideo.constant += (self.viewForVideoSizeAdjest.height/2)+space;
            self.constrainBottomViewVideo.constant += self.viewCustomTollbar_container.height;
            self.constrainTopViewVideo.constant=space;
            _isViewInTransmitMode = true;
            
            // saving the small size video constrains
            // if (!arrBackupConstrain)
            
            arrBackupConstrain=nil;
            arrBackupConstrain = [[NSMutableArray alloc] initWithCapacity:5];
            [arrBackupConstrain addObject:[NSNumber numberWithInt:self.contrainTopViewText.constant]];      // 0
            [arrBackupConstrain addObject:[NSNumber numberWithInt:self.constrainRightViewVideo.constant]];  // 1
            [arrBackupConstrain addObject:[NSNumber numberWithInt:self.constrainBottomViewVideo.constant]]; // 2
            [arrBackupConstrain addObject:[NSNumber numberWithInt:self.constrainLeftViewVideo.constant]]; // 2
            [arrBackupConstrain addObject:[NSNumber numberWithInt:self.constrainTopViewVideo.constant]]; // 2
        }
    
        
    } else {
        
        
        [self restoreVideoConstrains];
        
        //        _isViewInTransmitMode = false;
        //          [self resetAll];
    }
    
    [self animateConstraints];
//    [self.lbl_error setHidden:!state];
    [self.viewCustomTollbar_container setHidden:state];
}


-(void)animateVideoBack{
    
        self.contrainTopViewText.constant=[arrBackupConstrain[0]integerValue];
    
    if ([self isCustomRenderView]) {
        self.constrainRightViewVideoRender.constant=[arrBackupConstrain[1]integerValue];
        self.constrainBottomViewVideoRender.constant=[arrBackupConstrain[2]integerValue];
        self.constrainLeftViewVideoRender.constant=[arrBackupConstrain[3]integerValue];
        self.constrainTopViewVideoRender.constant=[arrBackupConstrain[4]integerValue];
    }
    else
    {
        self.constrainRightViewVideo.constant=[arrBackupConstrain[1]integerValue];
        self.constrainBottomViewVideo.constant=[arrBackupConstrain[2]integerValue];
        self.constrainLeftViewVideo.constant=[arrBackupConstrain[3]integerValue];
        self.constrainTopViewVideo.constant=[arrBackupConstrain[4]integerValue];
    }

   
    
    [self animateConstraints];
}

-(void)animateVideoToFullSize{
    //self.contrainTopViewText.constant = 0;
   
    // video constrain
    self.contrainTopViewText.constant=0;
     [self animateConstraints];
    
    if ([self isCustomRenderView]) {
        self.constrainRightViewVideoRender.constant = 0;
        self.constrainBottomViewVideoRender.constant = 0;
        self.constrainTopViewVideoRender.constant = 0;
        self.constrainLeftViewVideoRender.constant=0;
    }
    else
    {
        self.constrainRightViewVideo.constant = 0;
        self.constrainBottomViewVideo.constant = 0;
        self.constrainTopViewVideo.constant = 0;
        self.constrainLeftViewVideo.constant=0;
    }
   
    [self animateConstraints];
}

- (void)animateConstraints {
    //    [UIView animateWithDuration:0.1
    //                     animations:^{
    [self.view layoutIfNeeded];
    //                     }];
}


#pragma mark - ConferenceToolbarDelegate

- (NSArray *)getParticipantsNameList {
    
    //    NSMutableArray *arrUidsName = [NSMutableArray new];
    //    // get all panel uid names which are not me !
    //    for (NSString *uid in [participants allKeys]) {
    //        if (![uid isEqualToString:[ActiveUserManager activeUser].userId]) {
    //            NSString* displayName = [participants objectForKey:uid];
    //            [arrUidsName addObject:displayName];
    //        }
    //    }
    //    return [arrUidsName mutableCopy];
    
    return [participants allKeys];
}

- (void)resetAll {
    NSArray *arrUidsName =[participants allKeys];
    
    [self resetArraySlots];
    // remove all of the video panel which are not me .
    for (NSString *uid in arrUidsName) {
        UserVideoPanel *panel = self.videoPanels[uid];
        [self.videoPanels removeObjectForKey:uid];
        [self.ParticipentShowOrHide removeObjectForKey:uid];
        [self.sdk.AVChat.VideoController unbindVideoRender:uid render:panel];
        [self.sdk.AVChat.VideoController unRegisterRemoteVideo:uid];
        panel.hidden = true;
        [self killPanel:panel];
    }
    
    for (UIView *panel in self.view.subviews) {
        if ([panel isKindOfClass:[UserVideoPanel class]] && panel != [self videoPanel]) {
            panel.hidden=true;
            [self killPanel:panel];
            
        }
    }
    
    [participants removeAllObjects];
    
    // reset toolbar
    [toolBar resetButtons];
    // rest internet conectivity
    [self resetAndShowNavigationBarbuttons:NO];
    
    _pageControl.hidden=true;
}



-(void)resetAndShowNavigationBarbuttons:(BOOL)show{
    
    if (show)
    {
        //[InternetActivityView setInternetActivityLevel:0];
        InternetActivityView.view.hidden=false;
        [self setNavigationBarProfileButtonShow:YES];
        
    }
    else
    {
        [InternetActivityView setInternetActivityLevel:0];
        InternetActivityView.view.hidden=true;
        [self setNavigationBarProfileButtonShow:NO];
        
    }
}

#pragma mark - AVChatDelegate

- (void)didParticipantLeave:(id<ooVooParticipant>)participant;
{
    //    NSLog(@"participant %@",participant.participantID);
    [self onLog:LogLevelSample log:[NSString stringWithFormat:@"Participant id %@",participant.participantID]];
    NSLog(@"arr taken slot %@",arrTakenSlot);
    
    [participants removeObjectForKey:participant.participantID];
    
    UserVideoPanel *panel = [self.videoPanels objectForKey:participant.participantID];
    
    if (panel) {
        
        
        if (panel==currentFullScreenPanel) {
            [self animate:panel ToFrame:rectLast];
            currentFullScreenPanel = NULL;
            [self refreshScrollViewContentSize];
        }
        
        
        
        [self.videoPanels removeObjectForKey:participant.participantID];
        [self.ParticipentShowOrHide removeObjectForKey:participant.participantID];
        int newEmptySlot= [self getSelectedUidIndex:participant.participantID];
        
        CGRect rectPanel=panel.frame;
        
        [arrTakenSlot replaceObjectAtIndex:[ self getSelectedUidIndex:participant.participantID] withObject:String_Empty];
        
        panel.hidden = true; // animate instead
        [self.sdk.AVChat.VideoController unbindVideoRender: participant.participantID render:panel];
        [self.sdk.AVChat.VideoController unRegisterRemoteVideo:participant.participantID];
        
        
        
        
        
        
        [self killPanel:panel];
        
        
        
        // remove open panel to the first empty one
        for (int i = newEmptySlot+1; i<[arrTakenSlot count]; i++) {
            
            if (![arrTakenSlot[i] isEqualToString:String_Empty])
            {
                UserVideoPanel *panel =   [self.videoPanels objectForKey:arrTakenSlot[i]];
                CGRect rectInner = panel.frame;
                
                [UIView animateWithDuration:0.1 animations:^{
                    [panel setFrame:rectPanel];
                }];
                
                [arrTakenSlot replaceObjectAtIndex:newEmptySlot withObject:arrTakenSlot[i]];
                [arrTakenSlot replaceObjectAtIndex:i withObject:String_Empty];
                newEmptySlot=i;
                NSLog(@"arr taken slot %@",arrTakenSlot);
                
                if (CGRectEqualToRect(rectMaxSize, rectInner)) {
                    rectInner = rectLast;
                    currentFullScreenPanel = NULL;
                    [self refreshScrollViewContentSize];
                }
                
                rectPanel=rectInner;
                
            }
        }
        
        // remove the last string empty
        
        [self removeLastEmptyObjects];
        
        [self refreshScrollViewContentSize];
        
        if (_isCommingFromCall && [arrTakenSlot count]==1)
        {
            [self leaveSession];
        }
    }
    
    if (infoVC) {
        [self infoVCSetData];
    }
    
}




-(void)removeLastEmptyObjects{
    
    if ([[arrTakenSlot lastObject]isEqualToString:String_Empty])
    {
        [arrTakenSlot removeLastObject];
        [self removeLastEmptyObjects];
        
    }
    
}

-(NSString*)stringFromSelectedClass{
    // should get to the sun viewcontroller
    return @"";
}


- (void)didParticipantJoin:(id<ooVooParticipant>)participant user_data:(NSString *)user_data;
{
    [self onLog:LogLevelSample log:[NSString stringWithFormat:@"Participant %@ ",participant.participantID]];
    
    
//    UserVideoPanel *panel;
    
    [arrTakenSlot addObject:String_Empty];
    int emptySlot =[self getFirstemptySlot] ;
    
    
    NSString *strName = [self removeWhiteSpacesFromStartAndEnd:user_data];
    if ([strName isEqualToString:String_Empty]||!strName) {
        strName=participant.participantID;
    }
    [participants setValue:strName forKey:participant.participantID];
    
    NSString *panelClassType=[self stringFromSelectedClass];
    id panel = [[NSClassFromString(panelClassType) alloc] initWithFrame:[self videoPanel].frame WithName:strName];


    
    [self setPanel:panel inPosition:emptySlot Animated:YES];
    
    [self.sdk.AVChat.VideoController registerRemoteVideo:participant.participantID];
    [self.sdk.AVChat.VideoController bindVideoRender:participant.participantID render:panel];
    [self.videoPanels setObject:panel forKey:participant.participantID];
    [arrTakenSlot replaceObjectAtIndex:emptySlot withObject:participant.participantID];
    [self.ParticipentShowOrHide setObject:[NSNumber numberWithBool:true] forKey:participant.participantID]; // default should show user video
    
    if (currentFullScreenPanel) {
        [self UserVideoPanel_Touched:currentFullScreenPanel];
    }

    NSLog(@"the resolution before join %@",currentRes);
    currentRes = [self.sdk.AVChat.VideoController getConfig:ooVooVideoControllerConfigKeyResolution];
        NSLog(@"the resolution after join %@",currentRes);

    if (infoVC) {
        [self infoVCSetData];

    }
}


-(void)setPanel:(id)somePanel inPosition:(int)emptySlot Animated:(BOOL)animated{
   
    UserVideoPanel *panel;
    
    if ([somePanel isKindOfClass:[UserVideoPanel class]])
    {
        panel=(UserVideoPanel*)somePanel;
    }
    else
    {
        panel=(UserVideoPanelRender*)somePanel;
    }

    
    
    [self saveDefaultFrameSize];
    [self saveMaxFrameSize];
    
    int viewNumber = emptySlot / 4  ; // 4 videos in a view
    
    NSLog(@"view number %d",viewNumber);
    
    panel.frame=rectDefaultPanelSize;//self.videoPanelView.frame;
    
    int position;
    
    panel.frame=rectDefaultPanelSize;//self.videoPanelView.frame;
    
    emptySlot=  emptySlot%4;
    
    if ([self isIpad]) {
        
        float viewSize= viewNumber*_viewForVideoSizeAdjest.width;
        
        switch (emptySlot) {
                
            case 0: {
                //panel.y=self.videoPanelView.y;
                // panel.x += panel.width + space; // set the x at the end of the first
                position = panel.x +viewSize;                  // save the real location
                panel.x = _viewForVideoSizeAdjest.width +viewSize ; // take the panel to the right for animation
                
            } break;
                
                
                
            case 1: {
                //panel.y=self.videoPanelView.y;
                panel.x += panel.width +viewSize +space; // set the x at the end of the first
                position = panel.x;                  // save the real location
                panel.x = _viewForVideoSizeAdjest.width+viewSize; // take the panel to the right for animation
                
            } break;
                
            case 2: {
                panel.x += viewSize ;
                panel.y += rectDefaultPanelSize.size.height+space;
                position = panel.x;                  // save the real location
                panel.x = -_viewForVideoSizeAdjest.width+viewSize; // take the panel to the Left for animation
                panel.height+=space;
                //      panel.strUserId = participant.participantID;
            } break;
                
            case 3: {
                panel.y += rectDefaultPanelSize.size.height+space;
                panel.x += panel.width+viewSize +space; // set the x at the end of the first
                position = panel.x;                  // save the real location
                panel.x = _viewForVideoSizeAdjest.width+viewSize; // take the panel to the Left for animation
                panel.height+=space;
                //      panel.strUserId = participant.participantID;
            } break;
        }//switch
        
    } // ipad
    else
    {
        
        float viewSize= viewNumber*_viewForVideoSizeAdjest.height;
        
        switch (emptySlot) {
                
            case 0: {
                panel.y+=viewSize;
                position = panel.x;                  // save the real location
                panel.x = _viewForVideoSizeAdjest.width; // take the panel to the right for animation
            } break;
                
            case 1:
            {
                panel.y+= viewSize;
                panel.x += panel.width +viewSize +space; // set the x at the end of the first
                position = panel.x;                  // save the real location
                panel.x = _viewForVideoSizeAdjest.width; // take the panel to the right for animation
                
            } break;
                
            case 2: {
                
                panel.y+= panel.height + viewSize + space ;
                position = panel.x;                  // save the real location
                panel.x = _viewForVideoSizeAdjest.width; // take the panel to the right for animation
                panel.height+=space;
            } break;
                
            case 3: {
                panel.y+= panel.height + viewSize +space ;
                panel.x += panel.width +space; // set the x at the end of the first
                
                position = panel.x;                  // save the real location
                panel.x = _viewForVideoSizeAdjest.width; // take the panel to the right for animation
                panel.height+=space;
            } break;
        }//switch
        
    }
    
    NSLog(@"rect default size %@",NSStringFromCGRect(rectDefaultPanelSize));
  //  NSLog(@"rect self %@",NSStringFromCGRect(self.videoPanelView.frame));
    NSLog(@"rect panel %@",NSStringFromCGRect(panel.frame));
    
    if (!panel.delegate) {
        panel.delegate=self;
        panel.clipsToBounds=YES;
    }
    
    if(currentFullScreenPanel == NULL)
        [self.viewScroll addSubview:panel];
    else
        [self.viewScroll insertSubview:panel belowSubview:currentFullScreenPanel];
    
    if (animated) {
        
        [UIView animateWithDuration:0.1
                         animations:^{
                             panel.x = position;
                         }];
        
    }
    else
    {
        panel.x = position;
    }
    
    [self refreshScrollViewContentSize];
    
   // NSLog(@"the resolution before join %@",currentRes);
    currentRes = [self.sdk.AVChat.VideoController getConfig:ooVooVideoControllerConfigKeyResolution];
   // NSLog(@"the resolution after join %@",currentRes);
    
}


/*
 ooVooNotCreated,
 ooVooTurningOn,
 ooVooTurnedOn,
 ooVooTurningOff,
 ooVooTurnedOff,
 ooVooRestarting,
 ooVooOnHold
 
 */

+(NSString*)getStateDescription:(ooVooDeviceState)code{
    
    switch (code) {
        case ooVooNotCreated:
            return @"ooVooNotCreated";
            break;
            
        case ooVooTurningOn:
            return @"ooVooTurningOn";
            break;
        case ooVooTurnedOn:
            return @"ooVooTurnedOn";
            break;
        case ooVooTurningOff:
            return @"ooVooTurningOff";
            break;
        case ooVooTurnedOff:
            return @"ooVooTurnedOff";
            break;
        case ooVooRestarting:
            return @"ooVooRestarting";
            break;
            
        case ooVooOnHold:
            return @"ooVooOnHold";
            break;
            
            
    }
    
    return  @"Unknown state";
}


+(NSString*)getErrorDescription:(sdk_error)code
{
    NSString * des;
    switch (code) {
            
        case sdk_error_InvalidParameter:                // Invalid Parameter
            des = @"Invalid Parameter.";
            break;
        case sdk_error_InvalidOperation:               // Invalid Operation
            des = @"Invalid Operation.";
            break;
        case sdk_error_DeviceNotFound:
            des = @"Device not found.";
            break;
        case sdk_error_AlreadyInSession:
            des = @"Already in session.";
            break;
        case sdk_error_DuplicateParticipantId:
            des = @"Duplicate Participant Id.";
            break;
        case sdk_error_ConferenceIdNotValid:
            des = @"Conference id not valid.";
            break;
        case sdk_error_ClientIdNotValid:
            des = @"client id not valid.";
            break;
        case sdk_error_ParticipantIdNotValid:
            des = @"Participant id not valid.";
            break;
        case sdk_error_CameraIdNotValid:
            des = @"Camera ID Not Valid.";
            break;
        case sdk_error_MicrophoneIdNotValid:
            des = @"Mic. ID Not Valid.";
            break;
        case sdk_error_SpeakerIdNotValid:
            des = @"Speaker ID Not Valid.";
            break;
        case sdk_error_VolumeNotValid:
            des = @"Volume Not Valid.";
            break;
        case sdk_error_ServerAddressNotValid:
            des = @"Server Address Not Valid.";
            break;
        case sdk_error_GroupQuotaExceeded:
            des = @"Group Quota Exceeded.";
            break;
        case sdk_error_NotInitialized:
            des = @" Not Initialized.";
            break;
        case sdk_error_Error:
            des = @"Conference Error.";
            break;
        case sdk_error_NotAuthorized:
            des = @"Not Authorized.";
            break;
        case sdk_error_ConnectionTimeout:
            des = @"Connection Timeout.";
            break;
        case sdk_error_DisconnectedByPeer:
            des = @"Disconnected by peer.";
            break;
        case sdk_error_InvalidToken:
            des = @"Invalid Token.";
            break;
        case sdk_error_ExpiredToken:
            des = @"Expired Token.";
            break;
        case sdk_error_PreviousOperationNotCompleted:
            des = @"Previous Operation Not Completed.";
            break;
        case sdk_error_AppIdNotValid:
            des = @"AppId Not Valid.";
            break;
        case sdk_error_NoAvs:
            des = @"No AVS.";
            break;
        case sdk_error_ActionNotPermitted:
            des = @"Action Not Permitted.";
            break;
        case sdk_error_DeviceNotInitialized:
            des = @"Device Not Initialized.";
            break;
        case sdk_error_Reconnecting:
            des = @"Network Is Reconnecting.";
            break;
        case sdk_error_Held:
            des = @"Application on hold.";
            break;
        case sdk_error_SSLCertificateVerificationFailed:
            des = @"SSL Certificates Verification Failed.";
            break;
        case sdk_error_ParameterAlreadySet:
            des = @"Parameter Already Set.";
            break;
        case sdk_error_AccessDenied:
            des = @"Access Denied.";
            break;
        case sdk_error_ConnectionLost:
            des = @"Connection Lost.";
            break;
        case sdk_error_NotEnoughMemory:
            des = @"Not Enough Memory.";
            break;
        case sdk_error_ResolutionNotSupported:
            des = @"Resolution not supported.";
            break;
            
        case sdk_error_OK:
            des = @"OK.";
            break;
            
        default:
            des = [NSString stringWithFormat:@"Error Code %d", code];
            break;
    }
    return des;
}

- (void)didConferenceStateChange:(ooVooAVChatState)state error:(sdk_error)code {
    [self showAndRunSpinner:NO];
    [self onLog:LogLevelSample log:[NSString stringWithFormat:@"State %d And code %@",state,[BaseVideoConferenceVC getErrorDescription:code]]];
    // NSLog(@"state %d code %d", state, code);
    
    
    
    if (state == ooVooAVChatStateJoined && code == sdk_error_OK)
    {
        [UIApplication sharedApplication].idleTimerDisabled = (code == sdk_error_OK);
        [self.sdk.AVChat.AudioController setRecordMuted:NO];
        [self.sdk.AVChat.AudioController setPlaybackMute:NO];
        [self setVisibleOfJoinPage:state != ooVooAVChatStateJoined];
        [self.navigationItem.leftBarButtonItem setTitle:@"Leave"];
        [self resetAndShowNavigationBarbuttons:YES];
        
    }
    else if (state == ooVooAVChatStateJoined || state == ooVooAVChatStateDisconnected)
    {
        if (state == ooVooAVChatStateJoined && code != sdk_error_OK)
        {
            UIAlertView *alert =  [[UIAlertView alloc] initWithTitle:@"Join Error" message:[BaseVideoConferenceVC getErrorDescription:code] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
        }
        
        if (state == ooVooAVChatStateDisconnected)
        {
            currentRes = defaultRes;
            [self animateViewsForState:true]; // return to first view ....
            
            
            _isViewInTransmitMode = false;
            [self resetAll];
            [self refreshScrollViewContentSize];
            
            
            [self.sdk.AVChat.VideoController bindVideoRender:[ActiveUserManager activeUser].userId render:[self videoPanel]];
            [self.sdk.AVChat.VideoController setConfig:self.defaultCameraId forKey:ooVooVideoControllerConfigKeyCaptureDeviceId];
            [self.sdk.AVChat.VideoController openCamera];
        }
        
        [UIApplication sharedApplication].idleTimerDisabled = NO;
        [self resetAndShowNavigationBarbuttons:NO];
        
        
    }
}

- (void)didReceiveData:(NSString *)uid data:(NSData *)data {
}

- (void)didConferenceError:(sdk_error)code {
    [self onLog:LogLevelSample log:[NSString stringWithFormat:@"error code %@",[BaseVideoConferenceVC getErrorDescription:code]]];
    //  [self.sdk.AVChat leave];
    [self.sdk.AVChat.AudioController unInitAudio:^(SdkResult *result) {
        NSLog(@"unInit Resoult %d",result.Result);
    }];
    [self showAndRunSpinner:NO];
}

- (void)didNetworkReliabilityChange:(NSNumber*)score{
    NSLog(@"Reliability = %@",score);
    [InternetActivityView setInternetActivityLevel:score];
}

- (void)didPhonePstnCallStateChange:(NSString *)participant_id state:(ooVooPstnState)state {
}



-(void) didSecurityState:(bool) is_secure{
    for (UIBarButtonItem *btn in self.navigationItem.rightBarButtonItems) {
        if (btn.tag==200) // it's the lock image on navigation bar
        {
            [btn setImage:is_secure?[UIImage imageNamed:@"Lock"]:[UIImage imageNamed:@"Unlock"] ];
            
        }
    }
}

// related methods
-(void)killPanel:(UserVideoPanel*)panel{
    
    [panel removeFromSuperview];
    panel.delegate=nil;
    panel=nil;
    
}


- (void)setVisibleOfJoinPage:(BOOL)state {
    
    
    [self animateViewsForState:state];
    
    if (_isCommingFromCall && !state) {
        [self.view sendSubviewToBack:_viewCover];
        _viewCover.hidden=true;
    }
}



#pragma mark - Private Methods

//- (void)clear_error {
//    self.lbl_error.hidden = YES;
//}
//
//- (void)show_error:(NSString *)error {
//    self.lbl_error.text = error;
//    self.lbl_error.hidden = NO;
//}

-(NSString*)removeWhiteSpacesFromStartAndEnd:(NSString*)str{
    // comes @"    ddd  ddd       "
    //returns@"ddd  ddd"
    return [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}


#pragma mark - CustomToolbarVC DELEGATE

- (void)CustomToolBarVC_didClickOnButtonTag:(int)tagNumber {
    
    switch (tagNumber) {
        case toolbar_mic:
            
            [self.sdk.AVChat.AudioController setRecordMuted:![self.sdk.AVChat.AudioController isRecordMuted]];
            
            NSLog(@"record muted %d", [self.sdk.AVChat.AudioController isRecordMuted]);
            break;
            
        case toolbar_speaker:
            
            [self.sdk.AVChat.AudioController setPlaybackMute:![self.sdk.AVChat.AudioController isPlaybackMuted]];
            
            break;
            
        case toolbar_camera:
            
            // open action sheet
            [self createActionSheetForCamera];
            
            break;
            
        case toolbar_hangUp:
            
            if (_isCommingFromCall) {
                [self leaveSession];
            }
            else{
                [self onHangUp:nil];
            }
            
            break;
            
        case toolbar_Effects:
        {
            [self createActionSheetForEffects];
            
            break;
        }
        case toolbar_resolution:
            [self createActionSheetForResolution];
            break;
            
        case toolbar_routingSound:
            
            break;
            
        default:
            break;
    }
}

-(void)closeCallConversation{
    
    //    if (_isCommingFromCall) {
    //          [self leaveSession];
    //    }
    //    else{
    //    [self leaveSession];
    //    [self closeViewAndGoBack];
    
    
}
#pragma mark - ACTION SHEET

typedef enum {
    actionSheet_camera = 100,
    actionSheet_effects = 200,
    actionSheet_Resolution = 300
} actionSheetType;

- (void)createActionSheetForCamera {
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose Camera:"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:nil];
    
    NSArray *arr_dev = [self.sdk.AVChat.VideoController getDevicesList];
    
    NSLog(@"get device list %@", [self.sdk.AVChat.VideoController getDevicesList]);
    NSLog(@"get current camera device  %@", [self.sdk.AVChat.VideoController getConfig:ooVooVideoControllerConfigKeyCaptureDeviceId]);
    
    for (id<ooVooDevice> device in arr_dev) {
        
        NSString *strDeviceName = [NSString stringWithFormat:@"%@", device];
        
        // adding only camera which is nt the current
        if (![strDeviceName isEqualToString:[self getSelectedDeviceName]]) {
            [actionSheet addButtonWithTitle:strDeviceName];
        }
        
        NSLog(@"\ndevice name:%@,device ID:%@", device.deviceName, device.deviceID);
    }
    
#warning if user mute the camera , we need to change the mute to un mute !!!
    if (isCameraStateOn) {
        [actionSheet addButtonWithTitle:@"Mute"];
    } else {
        [actionSheet addButtonWithTitle:@"Unmute"];
    }
    
    if ([self isIpadMini]) {
        [actionSheet addButtonWithTitle:@""];
    }
    
    
    [actionSheet showInView:self.view];
    actionSheet.tag = actionSheet_camera;
    
    if ([arr_dev count] > 1) {
        SEL selector = NSSelectorFromString(@"_alertController");
        if ([actionSheet respondsToSelector:selector])
        {
            UIAlertController *alertController = [actionSheet valueForKey:@"_alertController"];
            if ([alertController isKindOfClass:[UIAlertController class]])
            {
                UIAlertAction *action = alertController.actions[1];
                isCameraStateOn ? [action setEnabled:YES] : [action setEnabled:NO];
            }
        }
        else
        {
            // use other methods for iOS 7 or older.
            isCameraStateOn ? [actionSheet setButton:1 Enabled:YES] : [actionSheet setButton:1 Enabled:NO];
        }
    }
}

-(void) handleEffectSelection:(UIAlertAction *) action effectId:(NSString *) effectId{
    
    
    [self.sdk.AVChat.VideoController setConfig:effectId forKey:ooVooVideoControllerConfigKeyEffectId];
    //  currentEffect =  effectId;
}

- (void)createActionSheetForEffects {
    
    NSMutableArray *arrListEffectNames=[NSMutableArray new];
    for  (id<ooVooEffect> effect in arrEffectList){
        [arrListEffectNames addObject:effect.effectName];
    }
    
    [self performSegueWithIdentifier:Segue_EffectList sender:arrListEffectNames];
    
}


-(void)handleResSelection:(UIAlertAction *)action withResolution: (NSNumber*) resolution {
    [self onLog:LogLevelSample log:[NSString stringWithFormat:@"Current resolution is %@ Resolution Changed to %@  ",[self.sdk.AVChat.VideoController getConfig:ooVooVideoControllerConfigKeyResolution],[resolution stringValue]]];

    currentRes = [resolution stringValue];
    [self.sdk.AVChat.VideoController setConfig:currentRes forKey:ooVooVideoControllerConfigKeyResolution];
    
    [self performSelector:@selector(printToLog) withObject:nil afterDelay:3];
    
  
    
}
-(void)printToLog{
    [self onLog:LogLevelSample log:[NSString stringWithFormat:@"Resolution Changed a line after setting to new resolution %@",  [self.sdk.AVChat.VideoController getConfig:ooVooVideoControllerConfigKeyResolution]]];

}

- (void)openAlertController:(NSArray*) resolutions {
    currentRes = [self.sdk.AVChat.VideoController getConfig:ooVooVideoControllerConfigKeyResolution];
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Choose Resolution:"
                                          message:nil
                                          preferredStyle:UIAlertControllerStyleActionSheet];
    
    for (NSNumber* resolution in resolutions) {
        NSString* header = [resolutionsHeaders objectForKey:resolution];
        
        UIAlertActionStyle style = UIAlertActionStyleDefault;
        
        if ([currentRes isEqualToString:[resolution stringValue]]) {
            style = UIAlertActionStyleDestructive;
        }
        UIAlertAction *action = [UIAlertAction
                                 actionWithTitle:header
                                 style:style
                                 handler:^(UIAlertAction *action)
                                 {
                                     [self handleResSelection:action withResolution:resolution];
                                 }];
        [alertController addAction:action];
    }
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:@"Cancel"
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                       NSLog(@"Cancel action");
                                   }];
    
    [alertController addAction:cancelAction];
    
    alertController.popoverPresentationController.sourceView = _viewCustomTollbar_container;
    alertController.popoverPresentationController.sourceRect=self.view.bounds;
    [alertController.popoverPresentationController setPermittedArrowDirections:UIPopoverArrowDirectionDown];
    
    [self presentViewController:alertController animated:YES completion:nil];
}
-(void) openActionSheet:(NSArray*) resolutions {
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose Resolution:"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:nil];
    actionSheet.tag = actionSheet_Resolution;
    
    int index = 0 ;
    for (NSNumber* resolution in resolutions) {
        NSString* header = [resolutionsHeaders objectForKey:resolution];
        
        NSLog(@"header is %@",header);
        
        
        
       
        currentRes = [self.sdk.AVChat.VideoController getConfig:ooVooVideoControllerConfigKeyResolution];
       
        
        [actionSheet addButtonWithTitle:header];
        
        if ([currentRes isEqualToString:[resolution stringValue]])
        { // Selected
            
            actionSheet.destructiveButtonIndex=index+1;
            
//            [[[actionSheet valueForKey:@"_buttons"] lastObject] setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        }
        index++;
    }
    if ([self isIpadMini]) {
        [actionSheet addButtonWithTitle:@""];
    }
    
    [actionSheet showInView:self.view];
    //[actionSheet showInView:[UIApplication sharedApplication].keyWindow.rootViewController.view];
    
}

- (void)createActionSheetForResolution {
    
    NSMutableArray *allowedResolutions = [NSMutableArray new];
    NSArray* resolutions = [self.sdk.AVChat.VideoController.activeDevice getAvailableResolutions];
    
    if(resolutions)
    {
        for(NSNumber* resolution in resolutions)
        {
            if ([self.sdk.AVChat isResolutionSuported:[resolution integerValue]]) {
                [allowedResolutions addObject:resolution];
            }
        }
    }
    
    
    
    
    
//    if ([UIAlertController class]) {
//        [self openAlertController:allowedResolutions];
//    }
//    else {
        [self openActionSheet:allowedResolutions];
  //  }
}

-(BOOL)isIpadMini{
    
    
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size + 1);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    machine[size] = 0;
    
    if( (strcmp(machine, "iPad2,5") == 0) || (strcmp(machine, "iPad2,1") == 0))
    {
        return true;
    }
    
    free(machine);
    return false;
    
}

-(BOOL)isIpad{
#define IDIOM    UI_USER_INTERFACE_IDIOM()
#define IPAD     UIUserInterfaceIdiomPad
    
    if ( IDIOM == IPAD ) {
        return true;
    } else {
        return  false;
    }
}


#pragma mark -

- (NSString *)getIdForName:(NSString *)strName FromArray:(NSArray *)array {
    
    if ([NSStringFromClass([array[0] class]) isEqualToString:@"ooVooDeviceWrap"]) {
        
        NSLog(@"device wrap");
        
        for (id<ooVooDevice> device in array) {
            
            if ([device.deviceName isEqualToString:strName]) {
                return device.deviceID;
            }
        }
        
    } else {
        NSLog(@"effect wrap");
        
        for (id<ooVooEffect> effect in array) {
            
            if ([effect.effectName isEqualToString:strName]) {
                return effect.effectID;
            }
        }
    }
    
    return nil;
}

- (NSString *)getNameForId:(NSString *)strID FromArray:(NSArray *)array {
    
    if ([NSStringFromClass([array[0] class]) isEqualToString:@"ooVooDeviceWrap"]) {
        
        NSLog(@"device wrap");
        
        for (id<ooVooDevice> device in array) {
            
            if ([device.deviceID isEqualToString:strID]) {
                return device.deviceName;
            }
        }
        
    } else {
        NSLog(@"ooVooeffect wrap");
        
        for (id<ooVooEffect> effect in array) {
            
            if ([effect.effectID isEqualToString:strID]) {
                return effect.effectName;
            }
        }
    }
    
    return nil;
}

- (NSString *)getSelectedDeviceName {
    NSString *iid = [self.sdk.AVChat.VideoController getConfig:ooVooVideoControllerConfigKeyCaptureDeviceId]; // getting the id of the current selected
    NSString *strName = [self getNameForId:iid FromArray:[self.sdk.AVChat.VideoController getDevicesList]];
    return strName;
}

#pragma mark - UIActionSheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    NSLog(@"isvideotransmitted %d", [self.sdk.AVChat.VideoController isVideoTransmitted]);
    NSLog(@"Index = %d - Title = %@", buttonIndex, [actionSheet buttonTitleAtIndex:buttonIndex]);
    
    //check cancel button
    if (buttonIndex == 0) {
        return;
    }
    
    // GET THE ID OF THE SELECTED CAMERA OR EFFECT
    NSString *strID;
    
    if (actionSheet.tag == actionSheet_camera) {
        NSLog(@"Camera action sheet selected");
        
        strID = [self getIdForName:[actionSheet buttonTitleAtIndex:buttonIndex] FromArray:[self.sdk.AVChat.VideoController getDevicesList]];
        
        if (strID) {
            [self.sdk.AVChat.VideoController setConfig:strID forKey:ooVooVideoControllerConfigKeyCaptureDeviceId];
        } else // user want's to mute camera
        {
            if (isCameraStateOn) {
                //  [self.videoPanelView showAvatar:YES];
                //[self.sdk.AVChat.VideoController closePreview];
                [self.sdk.AVChat.VideoController stopTransmitVideo];
                [self.sdk.AVChat.VideoController closeCamera];
                [toolBar setCameraImageForButtonIsOn:false];
                
                // user muted his camera .
                // shrink panel if needed
                
                if (currentFullScreenPanel==[self videoPanel])
                {
                    [self UserVideoPanel_Touched:currentFullScreenPanel];
                }

            } else {
                // remove avatar
                //   [self.videoPanelView showAvatar:false];
                [self.sdk.AVChat.VideoController openCamera];
                [self.sdk.AVChat.VideoController startTransmitVideo];
                [toolBar setCameraImageForButtonIsOn:true];
                //[self.sdk.AVChat.VideoController openPreview];
            }
            
#warning add avatar mhen muted
            NSLog(@"user want's to mute camera");
        }
        
    }
    
    else if (actionSheet.tag == actionSheet_effects){
        id <ooVooEffect> effect = arrEffectList[buttonIndex-1];
        [self handleEffectSelection:nil effectId:effect.effectID];
        
    }
    else // it's resolution action sheet
    {
        currentRes = [NSString stringWithFormat:@"%d", buttonIndex];
        [self.sdk.AVChat.VideoController setConfig:currentRes forKey:ooVooVideoControllerConfigKeyResolution];
    }
}

#pragma mark - Text field delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - User Panel Delegate



-(void)UserMainPanel_Touched:(id)panel{
    
}

-(id)panelReturnCorrectPanel:(id)panel{
    UIView *videoPanel;
    
    if ([panel isKindOfClass:[UserVideoPanel class]])
    {
        videoPanel=(UserVideoPanel*)panel;
    }
    else
    {
        videoPanel=(UserVideoPanelRender*)panel;
    }
    return videoPanel;

}
-(void)somePanelTouched:(id)panel{
   
    UIView *videoPanel= [self panelReturnCorrectPanel:panel];
    
//    if ([panel isKindOfClass:[UserVideoPanel class]])
//    {
//        videoPanel=(UserVideoPanel*)panel;
//    }
//    else
//    {
//        videoPanel=(UserVideoPanelRender*)panel;
//    }
    
    NSString *uid = [_videoPanels allKeysForObject:videoPanel][0];
    
    BOOL stateCameraOn = [ParticipentState[uid]boolValue];
    
    if (!stateCameraOn) // if the remote video is on mute than dont change to big size.
    {
        return;
    }
    

    
    // if its other user video
    if (CGRectEqualToRect(rectMaxSize, videoPanel.frame)) {
        NSLog(@"it's on max turn to saved rect");
        [self animate:videoPanel ToFrame:rectLast];
        if ([self isIpad]) {
            [self setScrollViewToXPosition:scrollLastposition];
        } else {
            [self setScrollViewToYPosition:scrollLastposition];
        }
        self.viewScroll.scrollEnabled=true;
        currentFullScreenPanel = NULL;
        [self refreshScrollViewContentSize];
        
    }
    else{
        rectLast=videoPanel.frame;
        [self animate:videoPanel ToFrame:rectMaxSize];
        [self.viewScroll bringSubviewToFront:videoPanel];
        currentFullScreenPanel = videoPanel;
        _pageControl.hidden=true;
        
        if ([self isIpad]) {
            scrollLastposition = self.viewScroll.contentOffset.x;
            [self setScrollViewToXPosition:0];
        } else {
            scrollLastposition = self.viewScroll.contentOffset.y;
            [self setScrollViewToYPosition:0];
        }
        
        self.viewScroll.scrollEnabled=false;
        
    }

}
-(void)UserVideoPanel_Touched:(id)panel{
   
    if (self.isViewInTransmitMode) {
        
        if (currentFullScreenPanel &&  (currentFullScreenPanel != panel))
        {
            return;
        }
        else if  (currentFullScreenPanel &&  (currentFullScreenPanel = panel)){
              [self UserMainPanel_Touched:panel];
        }
        else{
            [self UserMainPanel_Touched:panel];

        }
           }
    
    

    
   }


//#define TopSpace 10
-(void)saveMaxFrameSize{
    NSLog(@"viewForVideoSizeAdjest.size.width2 %f",_viewForVideoSizeAdjest.width);
    NSLog(@"rectMaxSize.size.width %f",rectMaxSize.size.width);


    rectMaxSize.origin.x=0;
    rectMaxSize.origin.y=0;
    rectMaxSize.size.width=self.view.width;
    rectMaxSize.size.height=self.viewScroll.height;  //self.view.height-_viewCustomTollbar_container.height+2;
    NSLog(@"viewForVideoSizeAdjest.size.width3 %f",_viewForVideoSizeAdjest.width);
    NSLog(@"rectMaxSize.size.width %f",rectMaxSize.size.width);

}


//#define TopSpace 10
-(void)saveDefaultFrameSize{
    NSLog(@"in saveDefaultFrameSize");
    
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft || [[UIDevice currentDevice] orientation ]== UIDeviceOrientationLandscapeRight)
    {
        NSLog(@"Lanscapse");
    }
    if([[UIDevice currentDevice] orientation] == UIDeviceOrientationPortrait || [[UIDevice currentDevice] orientation] == UIDeviceOrientationPortraitUpsideDown )
    {
        NSLog(@"UIDeviceOrientationPortrait");
    }
    
    
    rectDefaultPanelSize.origin.x=space;
    rectDefaultPanelSize.size.width=(_viewForVideoSizeAdjest.width/2 )-space*2;
    rectDefaultPanelSize.size.height=(_viewForVideoSizeAdjest.height/2)-space*2 ;
    rectDefaultPanelSize.origin.y=space;
    NSLog(@"rect1: %@", NSStringFromCGRect(rectDefaultPanelSize));
}


-(void)animate:(id)somePanel ToFrame:(CGRect)frame{
    UIView *panel=[self panelReturnCorrectPanel:somePanel];
    
    // [panel animateImageFrame:frame];
    //  [UIView animateWithDuration:0.5 animations:^{
    panel.frame=frame;
    //    view.imgView.frame=frame;
    
    //  }];
    
    
}


#pragma  mark - Info view controller DELEGATE

-(void)InfoViewController_DidChangeVisualToUid:(NSString *)strUid{
    
    BOOL value=[_ParticipentShowOrHide[strUid]boolValue ];
    [_ParticipentShowOrHide setObject:[NSNumber numberWithBool:!value] forKey:strUid]; // setting the opposite value
    
    
    
    if ([_ParticipentShowOrHide[strUid] integerValue]==1) {
        
        id panel = _videoPanels[strUid];
        // panel.isAllowedToChangeImage=true;
        
    }
    
    
    
    // get the selected panel - Un/register put/remove avatar
    id panel = _videoPanels[strUid];
    
    if (value){
        // [self.sdk.AVChat.VideoController unbindVideoRender: strUid render:panel];
        
        [self.sdk.AVChat.VideoController unRegisterRemoteVideo:strUid];
        //        [panel showAvatar:true];
        
    }else{
        //   [self.sdk.AVChat.VideoController bindVideoRender:strUid render:panel];
        [self.sdk.AVChat.VideoController registerRemoteVideo:strUid];
        //  [panel showAvatar:false];
    }
}
-(NSNumber*)InfoViewController_GetVisualListForId:(NSString*)strID{
    NSLog(@"_ParticipentShowOrHide %@",_ParticipentShowOrHide[strID]);
    return _ParticipentShowOrHide[strID];
}
-(NSNumber*)isAllowedToChangeUserStateForId:(NSString *)strID{
    NSLog(@"ParticipentState %@",ParticipentState[strID]);
    return ParticipentState[strID];
}

#pragma mark - TABLE LIST DELEGATE

-(void)tableListDidSelect:(int)index{
    
    id <ooVooEffect> effect = arrEffectList[index];
    [self handleEffectSelection:nil effectId:effect.effectID];
    
    
}

- (void)onLog:(LogLevel)level log:(NSString *)log {
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    [format setTimeZone:[NSTimeZone systemTimeZone]];
    NSDate *now = [[NSDate alloc] init];
    NSString *dateString = [format stringFromDate:now];
    
    // add the correct date and time
    NSString *str =[NSString stringWithFormat:@"%@ %@",dateString,log];
    
    // add the caller method name
    str=[NSString stringWithFormat:@"%@ [%@]",str,[self methodCallName]];
    
    [[FileLogger sharedInstance] log:level message:str];
}

-(NSString*)methodCallName{
    NSString *sourceString = [[NSThread callStackSymbols] objectAtIndex:2];
    // Example: 1   UIKit                               0x00540c89 -[UIApplication _callInitializationDelegatesForURL:payload:suspended:] + 1163
    NSCharacterSet *separatorSet = [NSCharacterSet characterSetWithCharactersInString:@" -[]+?.,"];
    NSMutableArray *array = [NSMutableArray arrayWithArray:[sourceString  componentsSeparatedByCharactersInSet:separatorSet]];
    [array removeObject:@""];
    
    NSLog(@"Stack = %@", [array objectAtIndex:0]);
    NSLog(@"Framework = %@", [array objectAtIndex:1]);
    NSLog(@"Memory address = %@", [array objectAtIndex:2]);
    NSLog(@"Class caller = %@", [array objectAtIndex:3]);
    NSLog(@"Function caller = %@", [array objectAtIndex:4]);
    return [array objectAtIndex:4];
}

-(bool)isCustomRenderView{
     if ([UserDefaults getBoolForToKey:@"APP_VIDEO_RENDER"]) // if true we want the custom
         return YES;
    return NO;
}

//#pragma mark - Affdex detector delgate
//
//- (void)detectorHasResults:(NSArray *)metrics atTime:(NSTimeInterval)time
//{
//    //NSLog(@"Timestamp => %ld", time);
//    
//    for (AffdexPluginMetric *metric in metrics) {
//        NSLog(@"Metric %@ value = %@", [metric name], [[metric value] stringValue]);
//    }
//}
//
//-(void)detectorError:(NSError*)error
//{
//    NSLog(@"error => %@", [error localizedDescription]);
//}
//
//- (void)detectorDidFinishProcessing
//{
//    NSLog(@"detectorDidFinishProcessing");
//}
//
//- (void)detectorDidStartDetectingFace
//{
//    NSLog(@"detectorDidStartDetectingFace");
//}
//
//- (void)detectorDidStopDetectingFace
//{
//    NSLog(@"detectorDidStopDetectingFace");
//}

@end
