//
// MainViewController.m
// 
// Created by ooVoo on July 22, 2013
//
// © 2013 ooVoo, LLC.  Used under license. 
//

#import "MainViewController.h"
#import "ConferenceViewController.h"
#import "TextFieldCell.h"

#import "ooVooController.h"
#import "LoginParameters.h"

static NSString *kDefaultConferenceId = @DEFAULT_CONFERENCE_ID;


@interface MainViewController () <UITextFieldDelegate>

@property (nonatomic, copy) NSString *conferenceId;
@property (nonatomic, copy) NSString *participantInfo;
@property (nonatomic, copy) NSString *participantId;
@property (nonatomic, assign) UITextField *currentTextField;

@end

typedef enum
{
    ConferenceIdRow,
    ParticipantIdRow,
    DisplayNameRow,
    NUMBER_OF_LOGIN_ROWS
}
LoginRow;

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];    
    self.conferenceId = kDefaultConferenceId;
    self.participantInfo = [[UIDevice currentDevice] name];
    self.participantId = [NSString stringWithFormat:@"iOS-%i", arc4random()];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
	return NUMBER_OF_LOGIN_ROWS;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TextFieldCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"TextFieldCell"];
    cell.textField.delegate = self;
    cell.textField.tag = indexPath.row;
    
    switch (indexPath.row)
    {
        case ConferenceIdRow:
            cell.textLabel.text = @"Conference ID";
            cell.textField.text = self.conferenceId;
            break;

        case ParticipantIdRow:
            cell.textLabel.text = @"Participant ID";
            cell.textField.text = self.participantId;
            break;
            
        case DisplayNameRow:
            cell.textLabel.text = @"Display Name";
            cell.textField.text = self.participantInfo;
            break;
            
        default:
            break;
    }
    
	return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return [NSString stringWithFormat:NSLocalizedString(@"SDK Version: %@", nil), [ooVooController sharedController].sdkVersion];
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.currentTextField = textField;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    switch (textField.tag)
    {
        case ConferenceIdRow:
            self.conferenceId = textField.text;
            break;
            
        case ParticipantIdRow:
            self.participantId = textField.text;
            break;
        
        case DisplayNameRow:
            self.participantInfo = textField.text;
            break;
            
        default:
            break;
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Actions
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [self.currentTextField resignFirstResponder];

    if ([segue.identifier isEqualToString:@"Join"])
    {
        UINavigationController *conferenceNav = segue.destinationViewController;
        ConferenceViewController *conferenceVC = conferenceNav.viewControllers[0];
        conferenceVC.conferenceId = self.conferenceId;
        conferenceVC.participantId = self.participantId;
        conferenceVC.participantInfo = self.participantInfo;
    }
}

@end
