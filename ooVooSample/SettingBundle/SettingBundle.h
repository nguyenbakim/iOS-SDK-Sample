//
//  ActiveUserManager.h

#import <Foundation/Foundation.h>

@interface SettingBundle : NSObject {
}

+ (SettingBundle *)sharedSetting;
- (NSString *)getSettingForKey:(NSString *)key;
- (void)setSettingKey:(NSString *)key WithValue:(NSString *)value;
@end
