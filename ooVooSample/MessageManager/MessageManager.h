//
//  MessageManager.h
//  ooVooSample
//
//  Created by Udi on 7/29/15.
//  Copyright (c) 2015 ooVoo LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ooVooSDK/ooVooSDK.h>
#import "CNMessage.h"


#import <AVFoundation/AVAudioPlayer.h>

typedef void (^sendCompelition)(BOOL CallSuccess);
@interface MessageManager : NSObject<ooVooMessagingDelegate,AVAudioPlayerDelegate>{
    
}
@property (retain, nonatomic) ooVooClient *sdk;
@property (retain, nonatomic) CNMessage *messageController;


+ (MessageManager *)sharedMessage ;
-(void)initSdkMessage;
//-(void)messageOtherUser:(NSString*)userName WithMessageType:(CNMessageType)type WithConfID:(NSString*)strConfId Compelition:(sendCompelition)compelition;
-(void)messageOtherUsers:(NSArray*)arrUsers WithMessageType:(CNMessageType)type WithConfID:(NSString*)strConfId Compelition:(sendCompelition)compelition;
-(void)stopCallSound;

@end
