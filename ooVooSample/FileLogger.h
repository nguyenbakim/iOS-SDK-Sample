//
//  FileLogger.h
//  ooVooSample
//
//  Created by Anton Ianovski on 7/28/14.
//  Copyright (c) 2014 ooVoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ooVooSDK/ooVooSdk.h>

@class NSFileHandle;

@interface FileLogger : NSObject

+(FileLogger *) sharedInstance;

-(void) log:(LogLevel) level message:(NSString *)log;
- (NSString *) readLastMessages: (NSUInteger)readSize;
@end
