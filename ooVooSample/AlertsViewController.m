//
// AlertsViewController.h
// 
// Created by ooVoo on July 22, 2013
//
// © 2013 ooVoo, LLC.  Used under license. 
//

#import "AlertsViewController.h"

@implementation AlertsViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (!self.logsController.textViewLogger.textView)
    {
        self.alertsTextView.text = @"\n";
        self.logsController.textViewLogger.textView = self.alertsTextView;
    }
    [self.alertsTextView flashScrollIndicators];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.logsController.textViewLogger.textView = nil;
}

@end
