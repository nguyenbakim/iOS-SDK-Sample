//
//  CNMessage.m
//  ooVooSample
//
//  Created by Noam Segal on 7/26/15.
//  Copyright (c) 2015 ooVoo LLC. All rights reserved.
//

#import "CNMessage.h"
#import "NSData+Base64.h"


NSString * const MESSAGE_TYPE = @"type";
NSString * const CONFERENCE_ID     = @"conference id";
NSString * const DISPLAY_NAME      = @"display name";
NSString * const EXTRA_MESSAGE     = @"extra message";
NSString * const UNIQUE_ID         = @"unique id";

NSString * const TYPE_CALLING      = @"calling";
NSString * const TYPE_ANS_ACCEPT   = @"accept";
NSString * const TYPE_ANS_DECLINE  = @"decline";
NSString * const TYPE_CANCEL       = @"cancel";
NSString * const TYPE_BUSY         = @"busy";
NSString * const TYPE_END_CALL     = @"end_call";

/*{"type":"calling","conference id":"2c09ef5d-ece1-472d-b442-ea7d206eeab0","extra message":"","display name":"levy","unique id":"a6205a14-6e3e-44bc-a018-efee37e0f4f8"}*/

@implementation CNMessage

+(NSString*) cnMessageTypeToString:(CNMessageType) type{
    switch(type){
        case Calling:
            return TYPE_CALLING;
        case AnswerAccept:
            return TYPE_ANS_ACCEPT;
        case AnswerDecline:
            return TYPE_ANS_DECLINE;
        case Cancel:
            return TYPE_CANCEL;
        case Busy:
            return TYPE_BUSY;
        case EndCall:
            return TYPE_END_CALL;
        default:
            return nil;
    }
}

+(CNMessageType) cnMessageStringToType:(NSString *) typeStr{
    if([typeStr isEqualToString:TYPE_CALLING])
        return Calling;
    else if([typeStr isEqualToString:TYPE_ANS_ACCEPT])
        return AnswerAccept;
    else if([typeStr isEqualToString:TYPE_ANS_DECLINE])
        return AnswerDecline;
    else if([typeStr isEqualToString:TYPE_CANCEL])
        return Cancel;
    else if([typeStr isEqualToString:TYPE_BUSY])
        return Busy;
    else if([typeStr isEqualToString:TYPE_END_CALL])
        return EndCall;
    else
        return Unknown;
}

+(NSString *) buildMessage:(CNMessageType) type confId:(NSString *) confId to:(NSArray *) to name:(NSString *) name userData:(NSString*) extra{
    NSMutableDictionary * dictionary  = [[NSMutableDictionary alloc] init];
    [dictionary setValue:[CNMessage cnMessageTypeToString:type] forKey:MESSAGE_TYPE];
    [dictionary setValue:confId forKey:CONFERENCE_ID];
    [dictionary setValue:name forKey:DISPLAY_NAME];
    [dictionary setValue:[[NSUUID UUID] UUIDString] forKey:UNIQUE_ID];
  
    if(extra)
        [dictionary setValue:extra forKey:EXTRA_MESSAGE];
    else
        [dictionary setValue:@"" forKey:EXTRA_MESSAGE];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    
    NSString* aStr;
    aStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSLog(@"%@", aStr);
    
    // *base64Encoded = [jsonData base64EncodedStringWithOptions:0];
    return aStr;
}

-(void) decodeMessage:(NSString *)base64Encoded{
    
//    NSData *nsdataFromBase64String = [[NSData alloc ]initWithBase64EncodedString:base64Encoded];
   NSData* data = [base64Encoded dataUsingEncoding:NSUTF8StringEncoding];
    
//    NSString* newStr = [[NSString alloc] initWithData:nsdataFromBase64String encoding:NSUTF8StringEncoding];
    NSError * error;
    NSDictionary * dictionary =[NSJSONSerialization
                              JSONObjectWithData:data
                              options:kNilOptions
                              error:&error];
    self.type = [CNMessage cnMessageStringToType:[dictionary valueForKey:MESSAGE_TYPE]];
    self.confId = [dictionary valueForKey:CONFERENCE_ID];
    self.displayName = [dictionary valueForKey:DISPLAY_NAME];
    
    self.userData = [dictionary valueForKey:EXTRA_MESSAGE];
    self.uniqueId = [dictionary valueForKey:UNIQUE_ID];
}

- (instancetype) initMessageWithParams:(CNMessageType) type confId:(NSString *) confId to:(NSArray*)arrTo name:(NSString *) name userData:(NSString*) extra{
//    self = [super initMessage:to message:[CNMessage buildMessage:type confId:confId to:to name:name userData:extra]];
    self = [super initMessageWithArrayUsers:arrTo message:[CNMessage buildMessage:type confId:confId to:arrTo name:name userData:extra]];

    if(self){
       
    }
    return self;
}

- (instancetype) initMessageWithResponse:(ooVooMessage *) response{
    self = [super initMessage:response.to[0] message:response.body];
    if(self){
        [self decodeMessage:response.body];
        self.fromUseriD=response.from;
    }
    return self;
}

@end
