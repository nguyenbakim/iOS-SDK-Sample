//
//  MenuConferenceVC.h
//  ooVooSample
//
//  Created by Udi on 7/26/15.
//  Copyright (c) 2015 ooVoo LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ooVooSDK/ooVooSDK.h>


@interface MenuConferenceVC : UIViewController
@property (retain, nonatomic) ooVooClient *sdk;

- (IBAction)actMakeCallOrSendMessage:(id)sender;
@end
