//
//  ParticipentCell.h
//  ooVooSample
//
//  Created by Udi on 6/9/15.
//  Copyright (c) 2015 ooVoo LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ParticipentCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lblParticipentID;
@property (weak, nonatomic) IBOutlet UISwitch *switchShowOrHide;

@end
