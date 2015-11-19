//
//  MessageManager.m
//  ooVooSample
//
//  Created by Udi on 7/29/15.
//  Copyright (c) 2015 ooVoo LLC. All rights reserved.
//

#import "MessageManager.h"
#import "ActiveUserManager.h"
#import "VideoConferenceVC.h"


@implementation MessageManager
{
    AVAudioPlayer *_audioPlayer;
}

static MessageManager *message = nil;
+ (MessageManager *)sharedMessage {
    if (message == nil) {
        message = [[MessageManager alloc] init];
        //   [MessageManager initSdkMessage];
        
    }
    return message;
}


-(void)initSdkMessage{
    
    self.sdk = [ooVooClient sharedInstance];
    self.sdk.Messaging.delegate=self;
    
}

-(void)messageOtherUser:(NSString*)userName WithMessageType:(CNMessageType)type WithConfID:(NSString*)strConfId Compelition:(sendCompelition)compelition{
    NSLog(@"Send message %d to %@",type,userName);
    
    
    
    self.messageController =[[CNMessage alloc]initMessageWithParams:type confId:strConfId to:userName name:[ActiveUserManager activeUser].userId userData:nil];
    
    
    __block  bool isRemoteUserIsOnLine= false;
    
    [self.sdk.Messaging sendMessage:self.messageController completion:^(SdkResult *result) {
        // did the message sent well ?
        NSLog(@"Response send message %d ",result.Result);
        NSLog(@"Response send message %@ ",  result.userInfo);
        NSDictionary *dic =result.userInfo[@"kUsersState"];
        
        isRemoteUserIsOnLine=[dic[userName]boolValue];
        
        if (result.Result !=0 && type==Calling) // bad send message result
        {
            UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"Call Error" message:[NSString stringWithFormat:@"Couldn't send message %@",[VideoConferenceVC getErrorDescription:result.Result]] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
            compelition(false);
        }
        
        if (result.Result == 0 && type==Calling && !isRemoteUserIsOnLine) // good send message but user not on line
        {
            UIAlertView *alert =[[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"User %@ Is Off Line",userName] message:[NSString stringWithFormat:@"Couldn't send message %@",[VideoConferenceVC getErrorDescription:result.Result]] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
            compelition(false);
        }
        
        
        else
        {
            
            if (type == Calling)
            {
                [self playSystemLineSound];
                compelition(true);
            }
            else
            {
                [self stopCallSound];
                compelition(true);
            }
            
        }
    }];
    
    
    
    
}

-(void)messageOtherUsers:(NSArray*)arrUsers WithMessageType:(CNMessageType)type WithConfID:(NSString*)strConfId Compelition:(sendCompelition)compelition{
    self.messageController =[[CNMessage alloc]initMessageWithParams:type confId:strConfId to:arrUsers name:[ActiveUserManager activeUser].userId userData:nil];
    [self.sdk.Messaging sendMessage:self.messageController completion:^(SdkResult *result) {
        // did the message sent well ?
        NSLog(@"Response send message %d ",result.Result);
        NSLog(@"Response send message %@ ",  result.userInfo);
        
        if (result.Result !=0 && type==Calling) // bad send message result
        {
            UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"Call Error" message:[NSString stringWithFormat:@"Couldn't send message %@",[VideoConferenceVC getErrorDescription:result.Result]] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
            compelition(false);
            return ;
        }
        
        [self stopCallSound];
        compelition(true);
    }];
    
    
}




#pragma mark - Messaging Delegate

-(void) didConnectivityStateChange:(ooVooMessagingConnectivityState)state error:(sdk_error)code description:(NSString *)description
{
    NSLog(@"didConnectivityStateChange %d", (int)state);
}

- (void)didMessageReceiveAcknowledgement:(ooVooMessageAcknowledgeState)state  forMessageId:(NSString *)messageId{
    NSLog(@"received acknowledgement for message id %@", messageId);
}

- (void)didMessageReceive:(ooVooMessage *)message{
    CNMessage *messageLocal  =[[CNMessage alloc]initMessageWithResponse:message];
    NSLog(@"message %d recieved from %@",messageLocal.type,messageLocal.fromUseriD);
    
    /*
     Calling,
     AnswerAccept,
     AnswerDecline,
     Cancel,
     Busy,
     EndCall,
     Unknown
     */
    
    switch (messageLocal.type) {
        case 0: // calling
            [[NSNotificationCenter defaultCenter]postNotificationName:@"incomingCall" object:messageLocal];
            [self playSystemSound];
            break;
            
        case 1: // AnswerAccept
            [[NSNotificationCenter defaultCenter]postNotificationName:@"AnswerAccept" object:messageLocal];
            [self stopCallSound];
            break;
            
        case 2: // AnswerDecline - rejected
            [[NSNotificationCenter defaultCenter]postNotificationName:@"AnswerDecline" object:messageLocal];
            //            [self stopCallSound];
            break;
            
        case 3: // Cancel call
            [[NSNotificationCenter defaultCenter]postNotificationName:@"callCancel" object:messageLocal];
            [self stopCallSound];
            break;
            
        case 4: // busy
            [[NSNotificationCenter defaultCenter]postNotificationName:@"Busy" object:messageLocal];
            [self stopCallSound];
            
            break;
            
        case 5: // endCall
            
            break;
            
        case 6: // Unknown
            
            break;
            
        default:
            break;
    }
    [self.sdk.Messaging sendAcknowledgement:Delivered forMessage:message handler:^(SdkResult *result) {
        // did the message sent well ?
        NSLog(@"Response sendAcknowledgementsendAcknowledgement message %d ",result.Result);
        
        if (result.Result !=0 ) // bad send message result
        {
            //UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"Call Error" message:[NSString stringWithFormat:@"Couldn't send message %@",[VideoConferenceVC getErrorDescription:result.Result]] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            // [alert show];
            
        }
        
    }];
    
}

-(void)loadAudioFileList{
    //    audioFileList = [[NSMutableArray alloc] init];
    //
    //    NSFileManager *fileManager = [[NSFileManager alloc] init];
    //    NSURL *directoryURL = [NSURL URLWithString:@"/System/Library/Audio/UISounds"];
    //    NSArray *keys = [NSArray arrayWithObject:NSURLIsDirectoryKey];
    //
    //    NSDirectoryEnumerator *enumerator = [fileManager
    //                                         enumeratorAtURL:directoryURL
    //                                         includingPropertiesForKeys:keys
    //                                         options:0
    //                                         errorHandler:^(NSURL *url, NSError *error) {
    //                                             // Handle the error.
    //                                             // Return YES if the enumeration should continue after the error.
    //                                             return YES;
    //                                         }];
    //
    //    for (NSURL *url in enumerator) {
    //        NSError *error;
    //        NSNumber *isDirectory = nil;
    //        if (! [url getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:&error]) {
    //            // handle error
    //        }
    //        else if (! [isDirectory boolValue]) {
    //            [audioFileList addObject:url];
    //        }
    //    }
}

-(void)playSystemSound{
    
    NSString *path = [NSString stringWithFormat:@"%@/video incoming call rev.mp3", [[NSBundle mainBundle] resourcePath]];
    NSURL *soundUrl = [NSURL fileURLWithPath:path];
    
    // Create audio player object and initialize with URL to sound
    
    [self initAudioSoundWith:soundUrl];
    
    [_audioPlayer play];
    
}

-(void)initAudioSoundWith:(NSURL*)url{
    
    if (_audioPlayer) {
        _audioPlayer.delegate=nil;
        _audioPlayer=nil;
    }
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    _audioPlayer.delegate=self;
}

-(void)playSystemLineSound{
    
    NSString *path = [NSString stringWithFormat:@"%@/CallLine.mp3", [[NSBundle mainBundle] resourcePath]];
    NSURL *soundUrl = [NSURL fileURLWithPath:path];
    
    [self initAudioSoundWith:soundUrl];
    [_audioPlayer play];
    
}

#pragma mark - AVAudioFoundation Delegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    [player play];
}

-(void)stopCallSound{
    [_audioPlayer stop];
    _audioPlayer.delegate=nil;
    _audioPlayer=nil;
    
}

@end
