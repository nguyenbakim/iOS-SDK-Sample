//
//  AppVideoPanel.h
//  ooVooSample
//
//  Created by Noam Segal on 7/29/15.
//  Copyright (c) 2015 ooVoo LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ooVooSDK/ooVooSDK.h>

@protocol UserVideoPanelDELEGATE;

@interface AppVideoPanel : UIView <ooVooVideoRender>{
    UILabel *lblUserName;
    UIImageView *imgView;
    UILabel *lblVideoAlert;
    
}

@property (nonatomic, strong) NSString *strUserId;
@property (nonatomic,weak)id<UserVideoPanelDELEGATE>delegate;
@property (assign) bool isAllowedToChangeImage;

- (instancetype)initWithFrame:(CGRect)frame WithName:(NSString *)strUserName;
-(void)showAvatar:(bool)show;
-(void)showVideoAlert:(bool)show;
-(void)animateImageFrame:(CGRect)frame;


@end


@protocol UserVideoPanelDELEGATE <NSObject>

-(void)UserVideoPanel_Touched:(AppVideoPanel*)videoPanel;


@end