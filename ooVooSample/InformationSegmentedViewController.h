//
//  InformationSegmentedViewController.h
//  ooVooSample
//
//  Created by Clement Barry on 12/10/13.
//  Copyright (c) 2013 ooVoo. All rights reserved.
//

#import "ParticipantsController.h"
#import "LogsController.h"

@interface InformationSegmentedViewController : UIViewController

@property (nonatomic, strong) ParticipantsController *participantsController;
@property (nonatomic, strong) LogsController *logsController;
@property (nonatomic, copy) NSString *conferenceId;

@property (nonatomic, weak) IBOutlet UISegmentedControl *segmentedControl;

- (IBAction)segmentChanged:(UISegmentedControl *)sender;
- (IBAction)done:(id)sender;

@end
