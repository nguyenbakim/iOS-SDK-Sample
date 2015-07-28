//
//  FriendCell.m
//  ooVooSdkSampleShow
//
//  Created by Udi on 4/14/15.
//  Copyright (c) 2015 ooVoo LLC. All rights reserved.
//

#import "FriendCell.h"

@implementation FriendCell

- (void)awakeFromNib {
    // Initialization code
    
    
//    self.imageView
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(void)lbl_presenceFixForPresence:(NSString*)presence{
   
    _lblPresence.layer.borderColor=[UIColor blackColor].CGColor;
    _lblPresence.layer.borderWidth=0.5;
    _lblPresence.layer.cornerRadius=5;
    _lblPresence.backgroundColor=[UIColor redColor]; // off line
    [self.imgFriend addSubview:_lblPresence];

}

@end
