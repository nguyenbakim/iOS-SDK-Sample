//
//  CNMessage.h
//  ooVooSample
//
//  Created by Noam Segal on 7/26/15.
//  Copyright (c) 2015 ooVoo LLC. All rights reserved.
//

#import <ooVooSdk/ooVooSdk.h>

#ifndef NS_ENUM
#import <Foundation/Foundation.h>
#endif

typedef NS_ENUM(int, CNMessageType) {
    Calling,
    AnswerAccept,
    AnswerDecline,
    Cancel,
    Busy,
    EndCall,
    Unknown
};



@interface CNMessage : ooVooMessage
- (instancetype) initMessageWithParams:(CNMessageType) type confId:(NSString *) confId to:(NSArray*)arrTo name:(NSString *) name userData:(NSString*) extra;
//- (instancetype) initMessageWithParams:(CNMessageType) type confId:(NSString *) confId to:(NSString *) to name:(NSString *) name userData:(NSString*) extra;
- (instancetype) initMessageWithResponse:(ooVooMessage *) response;

@property(nonatomic) CNMessageType type;
@property(nonatomic, strong) NSString * displayName;
@property(nonatomic, strong) NSString * confId;
@property(nonatomic, strong) NSString * userData;
@property(nonatomic, strong) NSString * uniqueId;
@property(nonatomic, strong) NSString * fromUseriD;
@end
