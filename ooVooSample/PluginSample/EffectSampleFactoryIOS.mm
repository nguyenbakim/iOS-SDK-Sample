//
//  EffectSampleFactory.m
//  ooVooSdkSampleShow
//
//  Created by Weiwei_Dev on 4/20/15.
//  Copyright (c) 2015 ooVoo LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EffectSampleFactoryIOS.h"
#import "EffectSampleFactory.h"
#ifndef TARGET_OS_IPHONE
#include <objc/objc-runtime.h>
#else
#include <objc/runtime.h>
#endif

#define kFactoryAssociatedObject "kFactoryAssociatedObject"

@interface EffectFactoryStorageWrap : NSObject
{

}
@property (assign) oovoo::sdk::plugin_factory::ptr factory ;
@end

@implementation EffectFactoryStorageWrap
@synthesize factory = _factory ;
@end

//Source file

@implementation PluginWrapper
-(void *) getooVooPluginFactoryNative
{ 
    EffectFactoryStorageWrap* storage = (EffectFactoryStorageWrap*)objc_getAssociatedObject(self, kFactoryAssociatedObject) ;
    if(!storage){
        storage = [[EffectFactoryStorageWrap alloc] init];
        storage.factory = EffectSample::EffectSampleFactory::createPluginFactory();
        objc_setAssociatedObject(self, kFactoryAssociatedObject, storage, OBJC_ASSOCIATION_RETAIN) ;
    }

    return storage.factory.get() ;
}

@end