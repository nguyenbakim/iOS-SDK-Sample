//
//  UserInfoVc.h
//  ooVooSdkSampleShow
//
//  Created by Udi on 4/14/15.
//  Copyright (c) 2015 ooVoo LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ooVooFamily/ooVooFamily.h>

@interface UserInfoVc : UIViewController

@property (nonatomic, strong) id<ooVooFriend> friendOfMine;
@property (nonatomic, weak) IBOutlet UILabel *lblName;
@property (nonatomic, weak) IBOutlet UILabel *lblStatus;
@property (nonatomic, weak) IBOutlet UIImageView *imgFriend;

@end
