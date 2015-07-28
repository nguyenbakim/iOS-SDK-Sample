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

@end
