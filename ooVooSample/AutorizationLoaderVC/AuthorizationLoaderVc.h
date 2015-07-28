//
//  AutorizationLoaderVc.h
//  ooVooSdkSampleShow
//
//  Created by Udi on 3/30/15.
//  Copyright (c) 2015 ooVoo LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ooVooSDK/ooVooSDK.h"

@protocol AuthorizationDelegate <NSObject>

- (void)AuthorizationDelegate_DidAuthorized;

@end

@interface AuthorizationLoaderVc : UIViewController <ooVooClientLogger,ooVooAVChatDelegate>
@property (retain, nonatomic) ooVooClient *sdk;
@property (weak, nonatomic) id<AuthorizationDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UIButton *btn_Authorizate;
@property (weak, nonatomic) IBOutlet UILabel *lbl_Status;
- (IBAction)act_Authorizate:(id)sender;

@end
