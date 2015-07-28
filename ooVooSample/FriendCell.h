//
//  FriendCell.h
//  ooVooSdkSampleShow
//
//  Created by Udi on 4/14/15.
//  Copyright (c) 2015 ooVoo LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FriendCell : UITableViewCell

	@property(weak, nonatomic) IBOutlet UIImageView* imgFriend;
@property(weak, nonatomic) IBOutlet UILabel* lblName;
@property(weak, nonatomic) IBOutlet UILabel* lblStatus;
- (IBAction)actChat:(id)sender;
- (IBAction)actCall:(id)sender;
@property(weak, nonatomic) IBOutlet UIButton* btnTop;
@property(weak, nonatomic) IBOutlet UIButton* btnBottom;
@property(weak, nonatomic) IBOutlet UILabel* lblPresence;

@property(weak, nonatomic) IBOutlet UIButton* btnSelect;

@end
