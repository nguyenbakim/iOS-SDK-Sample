//
//  InformationSegmentedViewController.m
//  ooVooSample
//
//  Created by Clement Barry on 12/10/13.
//  Copyright (c) 2013 ooVoo. All rights reserved.
//

#import "InformationSegmentedViewController.h"
#import "InformationViewController.h"
#import "AlertsViewController.h"

@interface InformationSegmentedViewController ()
@property (nonatomic, strong) UIViewController *currentViewController;
@property (nonatomic, strong) InformationViewController *informationViewController;
@property (nonatomic, strong) AlertsViewController *alertsViewController;
@end

@implementation InformationSegmentedViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self segmentChanged:self.segmentedControl];
}

#pragma mark - Actions
- (IBAction)segmentChanged:(UISegmentedControl *)sender
{
    UIViewController *selectedViewController;
    
    switch (sender.selectedSegmentIndex)
    {
        case 0:
            if (!self.informationViewController)
            {
                self.informationViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Info"];
                self.informationViewController.participantsController = self.participantsController;
                self.informationViewController.conferenceId = self.conferenceId;
            }
            selectedViewController = self.informationViewController;
            break;
            
        case 1:
            if (!self.alertsViewController)
            {
                self.alertsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Alerts"];
                self.alertsViewController.logsController = self.logsController;
            }
            selectedViewController = self.alertsViewController;
            break;

        default:
            break;
    }
    
    [self addChildViewController:selectedViewController];
    selectedViewController.view.frame = self.view.bounds;
    [self.view addSubview:selectedViewController.view];
    [selectedViewController didMoveToParentViewController:self];

    [self.currentViewController.view removeFromSuperview];
    [self.currentViewController willMoveToParentViewController:nil];
    [self.currentViewController removeFromParentViewController];
    
    self.currentViewController = selectedViewController;
}

- (IBAction)done:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
