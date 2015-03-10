//
// InformationViewController.m
// 
// Created by ooVoo on July 22, 2013
//
// © 2013 ooVoo, LLC.  Used under license. 
//

#import "InformationViewController.h"
#import "ooVooController.h"
#import "SwitchCell.h"

@interface InformationViewController ()

@property (nonatomic, strong) NSArray *remoteParticipants;

@end

@implementation InformationViewController

#pragma mark - UIViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(participantDidJoin:) name:OOVOOParticipantDidJoinNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(participantDidLeave:) name:OOVOOParticipantDidLeaveNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(participantDidChange:) name:OOVOOParticipantVideoStateDidChangeNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoDidStop:) name:OOVOOPreviewDidStopNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoDidStart:) name:OOVOOPreviewDidStartNotification object:nil];
    
    [self reload];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)done:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    return [self.remoteParticipants count];
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    SwitchCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"SwitchCell"];
    
    Participant *participant = [self.remoteParticipants objectAtIndex:indexPath.row];
	cell.textLabel.text = participant.displayName;
    cell.switcher.on = (participant.state == ooVooVideoOn && participant.switchState == ooVooVideoOn);
    cell.switcher.tag = indexPath.row;
    if (![cell.switcher actionsForTarget:self forControlEvent:UIControlEventValueChanged])
    {
        [cell.switcher addTarget:self action:@selector(toggleSwitch:) forControlEvents:UIControlEventValueChanged];
    }
    
	return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return NSLocalizedString(@"Participants", nil);
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return [NSString stringWithFormat:NSLocalizedString(@"Conference ID: %@", nil), self.conferenceId];
}

- (void)reload
{
    NSPredicate *excludeMe = [NSPredicate predicateWithBlock:^BOOL(Participant *participant, NSDictionary *bindings) {
        return participant.isMe == NO;
    }];
    
    self.remoteParticipants = [[self.participantsController allParticipants] filteredArrayUsingPredicate:excludeMe];
    
    [self.tableView reloadData];
}

#pragma mark - Actions
- (IBAction)toggleSwitch:(id)sender
{
    UISwitch *aSwitch = sender;
    
    BOOL enable = aSwitch.isOn;
    NSUInteger index = aSwitch.tag;
    
    Participant *participant = [self.remoteParticipants objectAtIndex:index];
    participant.switchState = enable? ooVooVideoOn : ooVooVideoOff;
    [[ooVooController sharedController] receiveParticipantVideo:enable forParticipantID:participant.participantID];
    if (!enable) participant.state = ooVooVideoOff;
    
    [self reload];
}

#pragma mark - Notifications
- (void)participantDidJoin:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self reload];
        
    });
}

- (void)participantDidLeave:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self reload];
        
    });    
}

- (void)participantDidChange:(NSNotification *)notification
{    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self reload];
        
    });
}

- (void)videoDidStop:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self reload];
        
    });
}

- (void)videoDidStart:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self reload];
        
    });
}

@end
