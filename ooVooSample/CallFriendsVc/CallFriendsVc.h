//
//  CallFriendsVc.h
//  ooVooSample
//
//  Created by Udi on 7/26/15.
//  Copyright (c) 2015 ooVoo LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserVideoPanel.h"
#import "CustomToolbarVC.h"

@interface CallFriendsVc : UIViewController


@property (retain, nonatomic) ooVooClient *sdk;
@property (retain, nonatomic) IBOutlet UserVideoPanel *videoPanelView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constrainRightViewVideo;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constrainBottomViewVideo;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constrainLeftViewVideo;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contrainTopViewText;

@property (atomic, retain) NSMutableDictionary *videoPanels;

@end
