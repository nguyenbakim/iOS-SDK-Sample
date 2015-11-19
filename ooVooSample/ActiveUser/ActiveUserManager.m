//
//  ActiveUserManager.m
//  TCDashboard
//
//  Created by ykm dev on 6/17/13.
//  Copyright (c) 2013 ykm dev. All rights reserved.
//

#import "ActiveUserManager.h"

@implementation ActiveUserManager

static ActiveUserManager *user = nil;
+ (ActiveUserManager *)activeUser {
    if (user == nil) {
        user = [[ActiveUserManager alloc] init];
        //  user.storage=[StorageData new];
        
    }
    return user;
}

-(instancetype)init{
    _isSubscribed=false;
    return self;
}

-(NSString *)randomConference
{
    if (!_randomConference) {
        NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
        NSMutableString *randomString = [NSMutableString stringWithCapacity:8];
        
        for (int i = 0; i < 8; i++) {
            [randomString appendFormat:@"%C", [letters characterAtIndex:arc4random() % [letters length]]];
            _randomConference=randomString;
        }
    }

    
    return _randomConference;
}


@end
