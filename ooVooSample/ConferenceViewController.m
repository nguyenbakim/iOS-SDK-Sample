//
// ConferenceViewController.m
// 
// Created by ooVoo on July 22, 2013
//
// © 2013 ooVoo, LLC.  Used under license. 
//

#import "ConferenceViewController.h"
#import "InformationViewController.h"
#import "ParticipantDetailViewController.h"
#import "VideoCollectionViewCell.h"
#import "ConferenceToolbar.h"
#import "ooVooController.h"
#import <AVFoundation/AVAudioSession.h>

@interface ConferenceViewController ()

@property (nonatomic, strong) ParticipantsController *participantsController;
@property (nonatomic, strong) MessagesController *messagesController;
@property (nonatomic, strong) NSBlockOperation *blockOperation;
@property (nonatomic, weak)   UIPopoverController *infoPopoverController;
@property (nonatomic, strong) ParticipantDetailViewController *participantDetailViewController;


@end

@implementation ConferenceViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.participantsController = [[ParticipantsController alloc] init];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(conferenceDidBegin:)
                                                 name:OOVOOConferenceDidBeginNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(conferenceDidFail:)
                                                 name:OOVOOConferenceDidFailNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(conferenceDidEnd:)
                                                 name:OOVOOConferenceDidEndNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(cameraDidStart:)
                                                 name:OOVOOCameraDidStartNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(cameraDidChange:)
                                                 name:kCameraDidChangeNotification
                                               object:nil];
    
    [[ooVooController sharedController] joinConference:self.conferenceId
                                         participantId:kDefaultParticipantId
                                       participantInfo:self.participantInfo];
}

- (void)cameraDidStart:(NSNotification *)notification
{
    NSNumber *errorNumber = notification.userInfo[OOVOOErrorKey];
    BOOL ok = (errorNumber.intValue == 0);

    [ooVooController sharedController].previewEnabled = ok;
    [ooVooController sharedController].transmitEnabled = ok;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.collectionView reloadData];
    self.participantsController.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.participantsController.delegate = nil;
    [self.infoPopoverController dismissPopoverAnimated:YES];
}

#pragma mark - Notifications
- (void)conferenceDidBegin:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [[ooVooController sharedController] setPlaybackMuted:NO];
        
        if ([[AVAudioSession sharedInstance] respondsToSelector:@selector(requestRecordPermission:)]) // iOS 7 and on
        {
            [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
                if (granted)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[ooVooController sharedController] setRecorderMuted:NO];
                    });
                }
                else
                {
                    UIAlertView	*anAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Microphone permission denied",nil) message:NSLocalizedString(@"Go to your device Settings > Privacy > Microphone and switch this app to ON.", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [anAlert show];
                    });
                    
                }
            }];
        }
        else
        {
            [[ooVooController sharedController] setRecorderMuted:NO];
        }
    });
}

- (void)conferenceDidEnd:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        
    });
}

- (void)conferenceDidFail:(NSNotification *)notification
{
    NSString *reason = [notification.userInfo objectForKey:OOVOOConferenceFailureReasonKey];
    
    double delayInSeconds = 0.75;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        [self.presentingViewController dismissViewControllerAnimated:NO completion:^{
            
            [[[UIAlertView alloc] initWithTitle:self.title
                                        message:[NSString stringWithFormat:NSLocalizedString(@"Error - %@", nil), reason]
                                       delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
                              otherButtonTitles:nil] show];
            
        }];
    });
}

- (void)cameraDidChange:(NSNotification *)notification
{
    Participant *participant = [self.participantsController participantAtIndex:0];
    CameraState cameraState = (CameraState)[notification.userInfo[kCameraNotificationKey] integerValue];
    
    if (cameraState == MUTE_CAMERA) {
        [self.participantDetailViewController zoomOut:nil];
        [[ooVooController sharedController] receiveParticipantVideo:NO forParticipantID:participant.participantID];
    } else {
        [[ooVooController sharedController] receiveParticipantVideo:YES forParticipantID:participant.participantID];
    }
}


#pragma mark - Actions
- (IBAction)leaveConference:(id)sender
{
    [[ooVooController sharedController] leaveConference];
}

- (IBAction)showInformation:(id)sender
{
    if (self.infoPopoverController)
    {
        [self.infoPopoverController dismissPopoverAnimated:YES];
    }
    else
    {
        [self performSegueWithIdentifier:@"NavigateToInfo" sender:self];
    }
}

- (IBAction)showMessages:(id)sender
{
    [self performSegueWithIdentifier:@"Messages" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"NavigateToInfo"])
    {
        InformationViewController *infoViewController;
        UINavigationController *navigationController = segue.destinationViewController;
        infoViewController = navigationController.viewControllers[0];
        infoViewController.participantsController = self.participantsController;
        infoViewController.conferenceId = self.conferenceId;

        if ([segue isKindOfClass:[UIStoryboardPopoverSegue class]])
        {
            self.infoPopoverController = ((UIStoryboardPopoverSegue *)segue).popoverController;
        }
    }
    else if ([segue.identifier isEqualToString:@"ShowDetail"])
    {
        NSIndexPath *selectedIndexPath = [self.collectionView indexPathsForSelectedItems][0];
        Participant *participant = [self.participantsController participantAtIndex:selectedIndexPath.row];
        self.participantDetailViewController = [segue destinationViewController];
        self.participantDetailViewController.participant = participant;
    }
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString:@"ShowDetail"])
    {
        NSIndexPath *selectedIndexPath = [self.collectionView indexPathsForSelectedItems][0];
        Participant *participant = [self.participantsController participantAtIndex:selectedIndexPath.row];
        if (participant.state != ooVooVideoOn)
        {
            return NO;
        }
    }
    
    return YES;
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section
{
    return [self.participantsController numberOfParticipants];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    VideoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"VIDEO_CELL" forIndexPath:indexPath];
    
    Participant *participant = [self.participantsController participantAtIndex:indexPath.row];
    
    if (participant == nil)
        return cell;
    
    cell.avatarImgView.image = [UIImage imageNamed:@"user.png"];
    cell.userNameLabel.text = participant.displayName;
    
    switch (participant.state)
    {
        case ooVooVideoUninitialized:
            [cell showAvatar];
            [cell hideState];
            [[ooVooController sharedController] receiveParticipantVideo:YES forParticipantID:participant.participantID];
            break;
        case ooVooVideoOn:
            {
                NSUInteger maskUI  = [self supportedInterfaceOrientations];
                NSUInteger maskApp = [[UIApplication sharedApplication] supportedInterfaceOrientationsForWindow:self.view.window];
                NSUInteger mask = maskUI & maskApp;
                BOOL isRotationSupported = !( UIDeviceOrientationIsPortrait(mask) || UIDeviceOrientationIsLandscape(mask));
                BOOL isPreview = (indexPath.row == 0);
                
                cell.videoView.preview  = isPreview;
                cell.videoView.mirrored = (isPreview && [ooVooController sharedController].currentCamera == ooVooFrontCamera);
                cell.videoView.supportOrientation = (isRotationSupported ? isPreview : !isPreview);
                
                [cell.videoView associateToID:participant.participantID];
                [cell hideAvatar];
                [cell hideState];
                [cell.videoView showVideo:YES];
            }
            break;
        case ooVooVideoOff:
            [cell showAvatar];
            [cell.videoView clear];
            [cell hideState];
            break;
        case ooVooVideoPaused:
            [cell showAvatar];
            [cell.videoView clear];
            [cell showState:NSLocalizedString(@"Video cannot be viewed", nil)];
        default:
            break;
    }
    
    return cell;
}

#pragma mark - ParticipantsControllerDelegate
- (void)controllerWillChangeContent:(ParticipantsController *)controller
{
    self.blockOperation = [NSBlockOperation new];
}

- (void)controller:(ParticipantsController *)controller didChangeParticipant:(Participant *)aParticipant atIndexPath:(NSIndexPath *)indexPath forChangeType:(ParticipantChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    __weak UICollectionView *collectionView = self.collectionView;
    
    switch (type)
    {
        case ParticipantChangeInsert:
        {
            [self.blockOperation addExecutionBlock:^{ [collectionView insertItemsAtIndexPaths:@[newIndexPath]]; }];
            break;
        }
            
        case ParticipantChangeDelete:
        {
            if ([self.collectionView cellForItemAtIndexPath:indexPath]) {
                [self.blockOperation addExecutionBlock:^{ [collectionView deleteItemsAtIndexPaths:@[indexPath]]; }];
            } else {
                [self.collectionView reloadData];
            }
            break;
        }
            
        case ParticipantChangeUpdate:
        {
            [self.blockOperation addExecutionBlock:^{ [collectionView reloadItemsAtIndexPaths:@[indexPath]]; }];
            break;
        }
            
        default:
            break;
    }
}

- (void)controllerDidChangeContent:(ParticipantsController *)controller
{
    [self.collectionView performBatchUpdates:^{ [self.blockOperation start]; }
                                  completion:nil];
}

@end
