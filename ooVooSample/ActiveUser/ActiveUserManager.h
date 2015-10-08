//
//  ActiveUserManager.h

#import <Foundation/Foundation.h>

@interface ActiveUserManager : NSObject

@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *displayName;
@property (nonatomic, copy) NSString *randomConference;
+ (ActiveUserManager *)activeUser;


@end
