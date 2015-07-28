//
//  ActiveUserManager.h

#import <Foundation/Foundation.h>

@interface ActiveUserManager : NSObject

@property (nonatomic, copy) NSString *userId;
+ (ActiveUserManager *)activeUser;

@end
