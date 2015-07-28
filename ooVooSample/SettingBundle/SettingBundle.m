
#import "SettingBundle.h"
#import <ooVooSDK/ooVooSDK.h>

#define TOKEN "Put here your application token"


@implementation SettingBundle {
    NSUserDefaults *def;
}

static SettingBundle *settings = nil;

+ (SettingBundle *)sharedSetting {
    if (settings == nil) {
        settings = [[SettingBundle alloc] init];
        [self regDefaults];
    }
    return settings;
}

- (NSString *)getSettingForKey:(NSString *)key {

    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];

    return [def valueForKey:key];
}

- (void)setSettingKey:(NSString *)key WithValue:(NSString *)value {

    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];

    [def setObject:value forKey:key];

    [def synchronize];
}

+ (void)regDefaults {

    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];

    NSDictionary *dicAppToken = [NSDictionary dictionaryWithObject:@TOKEN forKey:@"settingBundle_AppToken"];
    NSDictionary *dicAppLogLevl = [NSDictionary dictionaryWithObject:@6 forKey:@"settingBundle_SDK_LogLevel"];
    NSString *appVersion =  [ooVooClient getSdkVersion];
    NSDictionary *dicAppVersion = [NSDictionary dictionaryWithObject:appVersion forKey:@"settingBundle_SDK_Version"];

    [def registerDefaults:dicAppToken];
    [def registerDefaults:dicAppVersion];
    [def registerDefaults:dicAppLogLevl];
    
    [def synchronize];
};

@end
