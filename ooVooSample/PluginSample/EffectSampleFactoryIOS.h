//
//  EffectSampleFactory.h
//  ooVooSdkSampleShow
//
//  Created by Weiwei_Dev on 4/20/15.
//  Copyright (c) 2015 ooVoo LLC. All rights reserved.
//

#ifndef ooVooSdkSampleShow_EffectSampleFactory_h
#define ooVooSdkSampleShow_EffectSampleFactory_h

#import <ooVooSDK/ooVooAVChat.h>


@interface PluginWrapper : NSObject <ooVooPluginFactory>
-(void *) getooVooPluginFactoryNative;
@end

#endif
