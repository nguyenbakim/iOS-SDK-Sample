//
//  MenuConferenceVC.m
//  ooVooSample
//
//  Created by Udi on 7/26/15.
//  Copyright (c) 2015 ooVoo LLC. All rights reserved.
//

#define Segue_PushTo_ConferenceVC @"ConferenceVC"

#import "MenuConferenceVC.h"

@interface MenuConferenceVC ()

@end

@implementation MenuConferenceVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setBackButton];
    self.navigationItem.title=@"Menu";
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setBackButton {
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStyleBordered target:self action:@selector(actLogOut)];
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.leftBarButtonItem = item;
}

-(void)actLogOut{
    [self.navigationController popViewControllerAnimated:YES];
     [self.sdk.Account logout];
}

@end
