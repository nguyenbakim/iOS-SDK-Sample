//
//  UserDefaults.h
//  ooVooSample
//
//  Created by Udi on 6/3/15.
//  Copyright (c) 2015 ooVoo LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserDefaults : NSObject

+(void)setBool:(BOOL)boolValue ToKey:(NSString*)strKey;
+(BOOL)getBoolForToKey:(NSString*)strKey;
+(void)setObject:(NSString *)conferenceID ForKey:(NSString*)key;
+(NSString *)getObjectforKey:(NSString*)key;

@end
