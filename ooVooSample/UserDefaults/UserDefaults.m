//
//  UserDefaults.m
//  ooVooSample
//
//  Created by Udi on 6/3/15.
//  Copyright (c) 2015 ooVoo LLC. All rights reserved.
//

#import "UserDefaults.h"

#define User_isInVideoView @"User_isInVideoView"

@implementation UserDefaults


+(void)setBool:(BOOL)boolValue ToKey:(NSString*)strKey{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:boolValue forKey:strKey];
    [defaults synchronize];
    
    
}

+(BOOL)getBoolForToKey:(NSString*)strKey{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return    [defaults boolForKey:strKey];
    
}

+(void)setObject:(NSString *)conferenceID ForKey:(NSString*)key {
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setObject:conferenceID forKey:key];
    [def synchronize];
}

+(NSString *)getObjectforKey:(NSString*)key {
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    return [def objectForKey:key];
}



@end
