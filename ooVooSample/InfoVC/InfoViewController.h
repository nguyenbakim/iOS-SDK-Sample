//
//  InfoViewController.h
//  ooVooSample
//
//  Created by Udi on 6/3/15.
//  Copyright (c) 2015 ooVoo LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ooVooSDK/ooVooSDK.h>


@protocol InfoViewController_DELEGATE <NSObject>

-(void)InfoViewController_DidChangeVisualToUid:(NSString*)strUid;
-(NSNumber*)InfoViewController_GetVisualListForId:(NSString*)strID;
-(NSNumber*)isAllowedToChangeUserStateForId:(NSString*)strID;

@end


@interface InfoViewController : UIViewController
@property (retain, nonatomic) ooVooClient *sdk;
@property(nonatomic,weak)id<InfoViewController_DELEGATE>delegate;

@property (retain, nonatomic) NSArray *arrParticipants;
@property (nonatomic, strong) NSString *strConferenceId;
@property (weak, nonatomic) IBOutlet UILabel *lblConferenceID;
//@property (weak, nonatomic) IBOutlet UILabel *lblSdkVersion;

@property (weak, nonatomic) IBOutlet UITableView *table;


@end
