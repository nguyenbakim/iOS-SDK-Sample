//
//  ConferenceToolbar.m
//  ooVooSample
//
//  Created by Clement Barry on 12/12/13.
//  Copyright (c) 2013 ooVoo. All rights reserved.
//

#import "ConferenceToolbar.h"
#import "ooVooController.h"

@interface ConferenceToolbar () <UIActionSheetDelegate>

@property (nonatomic, strong) UIBarButtonItem *microphoneBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *speakerBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *cameraBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *resolutionBarButtonItem;
@property (nonatomic, strong) NSMutableArray  *toolbarButtonItems;
@property (nonatomic, strong) UIBarButtonItem *routingBaseBarButtonItem;
@property (nonatomic, strong) UIActionSheet *cameraActionSheet;
@property (nonatomic, strong) UIActionSheet *resolutionActionSheet;
@property (nonatomic) NSUInteger numberOfCameras;


@end

@implementation ConferenceToolbar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setupNotifications];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self setupNotifications];
    }
    return self;
}

- (void)setupNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoDidStop:) name:OOVOOPreviewDidStopNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoDidStart:) name:OOVOOPreviewDidStartNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(microphoneDidChange:) name:OOVOOUserDidMuteMicrophoneNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(microphoneDidChange:) name:OOVOOUserDidUnmuteMicrophoneNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(speakerDidChange:) name:OOVOOUserDidMuteSpeakerNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(speakerDidChange:) name:OOVOOUserDidUnmuteSpeakerNotification object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    if (!self.items)
    {
        self.numberOfCameras = [ooVooController sharedController].availableCameras.count;
        
        self.microphoneBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[self imageForMicrophone:![ooVooController sharedController].isRecorderMuted]
                                                                        style:UIBarButtonItemStylePlain
                                                                       target:self
                                                                       action:@selector(muteMicPressed:)];
        
        self.speakerBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[self imageForSpeaker:![ooVooController sharedController].isPlaybackMuted]
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(muteSpeakerPressed:)];
        
        self.cameraBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[self imageForCamera:FRONT_CAMERA]
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(cameraPressed:)];
        
        self.resolutionBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:[self stringForResolution:[[ooVooController sharedController] cameraResolutionLevel]]
                                                                        style:UIBarButtonItemStylePlain
                                                                       target:self
                                                                       action:@selector(resButtonPressed:)];
        
        if (self.filtersEnabled)
        {
            self.filtersBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Filters"
                                                                         style:UIBarButtonItemStylePlain
                                                                        target:nil
                                                                        action:nil];
        }
    
        MPVolumeView* _routingView         = [[MPVolumeView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        _routingView.showsVolumeSlider     = NO ;
        self.routingBaseBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[self imageForSpeaker:![ooVooController sharedController].isPlaybackMuted]
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:nil
                                                                 action:nil];
    
        self.routingBaseBarButtonItem.customView = _routingView;

        
        
        UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        NSMutableArray *items = [NSMutableArray arrayWithObjects:self.microphoneBarButtonItem, flexibleSpace, self.speakerBarButtonItem, flexibleSpace,self.routingBaseBarButtonItem,flexibleSpace, nil];
        
        [items addObjectsFromArray:@[self.cameraBarButtonItem, flexibleSpace]];
        
        [items addObjectsFromArray:@[self.resolutionBarButtonItem, flexibleSpace]];
        
        if (self.filtersEnabled)
        {
            [items addObject:self.filtersBarButtonItem];
        }
        
        self.items = [NSArray arrayWithArray:items];
    }

}

#pragma - Actions
- (void)muteMicPressed:(id)sender
{
    [[ooVooController sharedController] setRecorderMuted:![ooVooController sharedController].isRecorderMuted];
}

- (void)muteSpeakerPressed:(id)sender
{
    [[ooVooController sharedController] setPlaybackMuted:![ooVooController sharedController].isPlaybackMuted];
}

- (void)cameraPressed:(id)sender
{
    self.cameraActionSheet = [[UIActionSheet alloc] initWithTitle:@"Change camera" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];

    NSArray *cameraTitles = [self cameraTitles];
    for (NSString *title in cameraTitles) [self.cameraActionSheet addButtonWithTitle:title];
    [self.cameraActionSheet addButtonWithTitle:@"Cancel"];
    self.cameraActionSheet.cancelButtonIndex = [cameraTitles count];
    
    [self.cameraActionSheet showFromToolbar:self];

    self.resolutionBarButtonItem.enabled = NO;
    self.cameraBarButtonItem.enabled = NO;
}

- (void)resButtonPressed:(id)sender
{
    self.resolutionActionSheet = [[UIActionSheet alloc] initWithTitle:@"Change resolution" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    
    NSArray *resolutionNames = [[ooVooController sharedController] availableCameraResolutionLevelNames];
    for (NSString *title in resolutionNames) [self.resolutionActionSheet addButtonWithTitle:title];
    [self.resolutionActionSheet addButtonWithTitle:@"Cancel"];
    self.resolutionActionSheet.cancelButtonIndex = [resolutionNames count];
    self.resolutionActionSheet.destructiveButtonIndex = [[[ooVooController sharedController] availableCameraResolutionLevels] indexOfObject:@([[ooVooController sharedController] cameraResolutionLevel])];
    
    [self.resolutionActionSheet showFromToolbar:self];
    
    self.cameraBarButtonItem.enabled = NO;
    self.resolutionBarButtonItem.enabled = NO;
}

#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet == self.cameraActionSheet) {
        if (buttonIndex != actionSheet.cancelButtonIndex)
        {
            CameraState cameraState = [self cameraStateForIndex:buttonIndex];
            
            NSDictionary *userInfo = @{ kCameraNotificationKey : [NSNumber numberWithInt:cameraState]};
            [[NSNotificationCenter defaultCenter] postNotificationName:kCameraDidChangeNotification
                                                                object:nil userInfo:userInfo];
            
            switch (cameraState) {
                case FRONT_CAMERA:
                    [[ooVooController sharedController] selectCamera:ooVooFrontCamera];
                    self.cameraBarButtonItem.image = [self imageForCamera:FRONT_CAMERA];
                    break;
                    
                case BACK_CAMERA:
                    [[ooVooController sharedController] selectCamera:ooVooRearCamera];
                    self.cameraBarButtonItem.image = [self imageForCamera:BACK_CAMERA];
                    break;
                    
                case MUTE_CAMERA:
                    self.cameraBarButtonItem.image = [self imageForCamera:MUTE_CAMERA];
                    break;
                    
                default:
                    break;
            }
        }
    } else if (actionSheet == self.resolutionActionSheet) {
        if (buttonIndex != actionSheet.cancelButtonIndex)
        {
            ooVooCameraResolutionLevel level = (ooVooCameraResolutionLevel)[([[ooVooController sharedController] availableCameraResolutionLevels])[buttonIndex] integerValue];
            
            if (level != [[ooVooController sharedController] cameraResolutionLevel]) {
                [[ooVooController sharedController] setCameraResolutionLevel:level];
                
                return;
            }
        }
    }

    self.resolutionBarButtonItem.enabled = YES;
    self.cameraBarButtonItem.enabled = YES;
}

#pragma mark - Notifications
- (void)microphoneDidChange:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        BOOL isMicrophoneEnabled = ![ooVooController sharedController].isRecorderMuted;
        self.microphoneBarButtonItem.image = [self imageForMicrophone:isMicrophoneEnabled];
        
    });
}

- (void)speakerDidChange:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        BOOL isSpeakerEnabled = ![ooVooController sharedController].isPlaybackMuted;
        self.speakerBarButtonItem.image = [self imageForSpeaker:isSpeakerEnabled];
        
        //[self.routingBarButtonItem setRouteButtonImage:[self imageForSpeaker:[ooVooController sharedController].speakerEnabled] forState:UIControlStateNormal];
        
    });
}

- (void)videoDidStart:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.cameraBarButtonItem.enabled = YES;
        self.resolutionBarButtonItem.enabled = YES;
        self.resolutionBarButtonItem.title = [self stringForResolution:[[ooVooController sharedController] cameraResolutionLevel]];
        
        if ([ooVooController sharedController].currentCamera == ooVooFrontCamera) {
            self.cameraBarButtonItem.image = [self imageForCamera:FRONT_CAMERA];
        } else if ([ooVooController sharedController].currentCamera == ooVooRearCamera) {
            self.cameraBarButtonItem.image = [self imageForCamera:BACK_CAMERA];
        } else {
            self.cameraBarButtonItem.image = [self imageForCamera:MUTE_CAMERA];
        }
    });
}

- (void)videoDidStop:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{

        self.cameraBarButtonItem.enabled = YES;
        self.resolutionBarButtonItem.enabled = YES;

    });
}

#pragma mark - Resources
- (UIImage *)imageForMicrophone:(BOOL)enabled
{
    return [UIImage imageNamed:(enabled?@"ic_mic":@"ic_mic_off")];
}

- (UIImage *)imageForSpeaker:(BOOL)enabled
{
    return [UIImage imageNamed:(enabled?@"ic_speaker":@"ic_speaker_off")];
}

- (NSString*)stringForResolution:(ooVooCameraResolutionLevel)resolution
{
    switch (resolution) {
        case ooVooCameraResolutionLow:    return NSLocalizedString(@"Low", nil);
        case ooVooCameraResolutionMedium: return NSLocalizedString(@"Med", nil);
        case ooVooCameraResolutionHigh:    return NSLocalizedString(@"High", nil);
        case ooVooCameraResolutionHD: return NSLocalizedString(@"HD", nil);
        default:
            break;
    }
    return nil;
}

- (UIImage*)imageForCamera:(CameraState)cameraState
{
    switch (cameraState) {
        case FRONT_CAMERA: return [UIImage imageNamed:@"ic_camera"];
        case BACK_CAMERA: return [UIImage imageNamed:@"video-camera"];
        case MUTE_CAMERA: return [UIImage imageNamed:@"ic_camera_muted"];
        default:
            break;
    }
    return nil;
}

- (NSString*)stringForCamera:(CameraState)cameraState
{
    switch (cameraState) {
        case FRONT_CAMERA: return NSLocalizedString(@"Front Camera", nil);
        case BACK_CAMERA: return NSLocalizedString(@"Back Camera", nil);
        case MUTE_CAMERA: return NSLocalizedString(@"Mute Camera", nil);
        default:
            break;
    }
    return nil;
}

- (NSArray *)cameraTitles
{
    if (self.numberOfCameras > 1) {
        NSMutableArray *titles = [NSMutableArray arrayWithArray:@[[self stringForCamera:FRONT_CAMERA],
                                                                  [self stringForCamera:BACK_CAMERA],
                                                                  [self stringForCamera:MUTE_CAMERA]]];
        
        return titles;
    }
    
    NSMutableArray *titles = [NSMutableArray arrayWithArray:@[[self stringForCamera:FRONT_CAMERA],
                                                              [self stringForCamera:MUTE_CAMERA]]];
    
    return titles;
}

- (CameraState)cameraStateForIndex:(NSInteger)index
{
    if (self.numberOfCameras > 1) {
        switch (index) {
            case 0: return FRONT_CAMERA;
            case 1: return BACK_CAMERA;
            case 2: return MUTE_CAMERA;
            default:
                break;
        }
    }
    
    switch (index) {
        case 0: return FRONT_CAMERA;
        case 1: return MUTE_CAMERA;
        default:
            break;
    }
    
    return FRONT_CAMERA;
}


@end
