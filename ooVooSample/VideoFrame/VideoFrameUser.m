//
//  VideoFrame.m
//  ooVooSample
//
//  Created by Udi on 8/13/15.
//  Copyright (c) 2015 ooVoo LLC. All rights reserved.
//

#import "VideoFrameUser.h"
#include "Accelerate/Accelerate.h"


typedef NS_ENUM(int, ooVooVideoType)
{
    ooVooUnDef        = -1,
    ooVooUnCompressed = 0,
    ooVooH264         = 1,
    ooVooVP8          = 11,
};

@implementation VideoFrameUser
{
    uint8_t* _dest_data;   // must be 0 on init
    size_t   _dest_length; // must be 0 on init
    uint8_t* _temp_rgba;   // must be 0 on init
    size_t   _temp_length; // must be 0 on init
    uint8_t* rawImagePixels ;
    
    vImage_Error err ;//= kvImageNoError;
    vImage_Flags flags;// = kvImageNoFlags;
    vImage_YpCbCrPixelRange pixelRange ;//= { 0, 128, 255, 255, 255, 1, 255, 0 };
    vImage_YpCbCrToARGB outInfo;
    
    
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        
        _dest_data=0;
        _dest_length=0;
        _temp_rgba = 0;
        _temp_length = 0;
        rawImagePixels = 0 ;
        err = kvImageNoError;
        flags = kvImageNoFlags;
    }
    return self;
}

- (void)dealloc
{
    if (_dest_data)
        free(_dest_data);
    if(_temp_rgba)
        free(_temp_rgba);
    if (rawImagePixels) {
        free(rawImagePixels);
    }
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    _dest_data=0;
    _dest_length=0;
    _temp_rgba = 0;
    _temp_length = 0;
    rawImagePixels = 0 ;
    err = kvImageNoError;
    flags = kvImageNoFlags;
    
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(orientationChanged:)name:UIDeviceOrientationDidChangeNotification  object:nil];
    [self orientationChanged:nil];
    
}

-(void)onProcessVideoFrame:(id<ooVooVideoFrame>)frame{
    
    
    NSLog(@"%x frame width %d",self, frame.width);
    //    NSLog(@"frame height %d",frame.height);
    //    NSLog(@"frame number %hi",frame.frameNumber);
    //    NSLog(@"frame deviceRotationAngle %d",frame.deviceRotationAngle);
    //    NSLog(@"frame rotationAngle %d",frame.rotationAngle);
    //    NSLog(@"frame color format %d",frame.colorFormat);
    //    NSLog(@"videoData color format %d",frame.videoData.colorFormat);
    
    
    id<ooVooVideoData> d = frame.videoData;
    NSData *data = d.data;
    
    int width = [d width];
    int height = [d height];
    size_t dest_len = width*height*3;
    
    vImage_Buffer src;
    src.height = height;
    src.width = width;
    src.rowBytes = [d getPlanePitch:0];
    src.data = [data bytes];
    
    if (!_dest_data || dest_len != _dest_length)
    {
        if (_dest_data)
            free(_dest_data);
        
        _dest_data = malloc(dest_len); // need call free on dealloc
        _dest_length = dest_len;
    }
    
    
    vImage_Buffer dest;
    dest.height = [d height];
    dest.width = [d width];
    dest.rowBytes = [d width]*3;
    dest.data = _dest_data;
    
    // Swap pixel channels from BGRA to RGBA.
    const uint8_t map[4] = { 2, 1, 0, 3 };
    //    vImagePermuteChannels_ARGB8888(&src, &dest, map, kvImageNoFlags);
    
    if (frame.colorFormat == ooVooColorFormatYUV420)
    {
        NSLog(@"NewFormat");
        
        
        vImage_YpCbCrPixelRange pixelRange = { 0, 128, 255, 255, 255, 1, 255, 0 };
        
        err = vImageConvert_YpCbCrToARGB_GenerateConversion(kvImage_YpCbCrToARGBMatrix_ITU_R_601_4, &pixelRange, &outInfo, kvImage420Yp8_Cb8_Cr8, kvImageARGB8888, flags);
        
        uint8_t* pY = (uint8_t*)data.bytes;
        uint8_t* pU = (uint8_t*)pY+width*height;
        uint8_t* pV = (uint8_t*)pU+width*height/4;
        
        void* pppY = data.bytes;
        
        void* ppY = [d getPlane:0];
        void* ppU = [d getPlane:1];
        void* ppV = [d getPlane:2];
        
        vImage_Buffer srcYp;
        srcYp.data     = [d getPlane:0];
        srcYp.width    = width;
        srcYp.height   = height;
        srcYp.rowBytes = [d getPlanePitch:0];
        
        vImage_Buffer srcCp;
        srcCp.data     = [d getPlane:1];
        srcCp.width    = width/2;
        srcCp.height   = height/2;
        srcCp.rowBytes = [d getPlanePitch:1];
        
        vImage_Buffer srcCr;
        srcCr.data     = [d getPlane:2];
        srcCr.width    = width/2;
        srcCr.height   = height/2;
        srcCr.rowBytes = [d getPlanePitch:2];
        
        size_t temp_len = width*height*4;
        
        if (!_temp_rgba || temp_len != _temp_length)
        {
            if (_temp_rgba)
                free(_temp_rgba);
            
            _temp_rgba = malloc(temp_len); // need call free on dealloc
            _temp_length = temp_len;
        }
        
        vImage_Buffer dstRGBA;
        dstRGBA.data     = _temp_rgba;
        dstRGBA.width    = width;
        dstRGBA.height   = height;
        dstRGBA.rowBytes = width*4;
        
        
        
        err = vImageConvert_420Yp8_Cb8_Cr8ToARGB8888(&srcYp, &srcCp, &srcCr, &dstRGBA, &outInfo, NULL, 255, kvImageNoFlags);
        err = vImageConvert_ARGB8888toRGB888(&dstRGBA, &dest, kvImageNoFlags);
    }
    else if (frame.colorFormat == ooVooColorFormatBGR32){
        
        vImageConvert_BGRA8888toRGB888(&src, &dest, kvImageNoFlags);
    }
    else if (frame.colorFormat == ooVooColorFormatRGB32){
        
        vImageConvert_RGBA8888toRGB888(&src, &dest, kvImageNoFlags);
        
    }
    
    CGImageRef cgImageFromBytes = [self newCGImageFromData:0 width:width height:height data:_dest_data length:dest_len];
    UIImage *finalImage = [UIImage imageWithCGImage:cgImageFromBytes scale:1.0 orientation:UIImageOrientationLeftMirrored];
    
    CGImageRelease(cgImageFromBytes);
    
    NSLog(@"image orientation %d",finalImage.imageOrientation);
    if (finalImage)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            _img.frame=self.bounds;
            _img.image = finalImage;
            _img.contentMode = UIViewContentModeScaleAspectFill;
        });
    }
    
}

#define CopyMemory(Destination,Source,Length) memcpy((Destination),(Source),(Length))
- (CGImageRef)newCGImageFromData:(ooVooVideoType) videoType width:(int) width height:(int)height data:(void*) data length:(int)length
{
    
    CGImageRef cgImageFromBytes;
    CGDataProviderRef dataProvider;
    
    
    @try {
        
        if (rawImagePixels) {
            free(rawImagePixels);
            rawImagePixels = (GLubyte *)malloc(length);
        }
        else
        {
            rawImagePixels = (GLubyte *)malloc(length);
        }
        CopyMemory(rawImagePixels, data, length);
        //    memcpy(rawImagePixels, data, length);
        dataProvider = CGDataProviderCreateWithData(NULL, rawImagePixels, length, NULL);
        
        CGColorSpaceRef defaultRGBColorSpace = CGColorSpaceCreateDeviceRGB();
        
        cgImageFromBytes = CGImageCreate(width, height, 8, 24, 3 * width, defaultRGBColorSpace, kCGBitmapByteOrderDefault, dataProvider, NULL, NO, kCGRenderingIntentDefault);
        
        // Capture image with current device orientation
        CGDataProviderRelease(dataProvider);
        CGColorSpaceRelease(defaultRGBColorSpace);
        
    }
    @catch (NSException *exception) {
        NSLog(@"Exception %@",exception);
    }
    
    
    return cgImageFromBytes;
}

#pragma mark - Orientation


// Works on ipad only !
- (void)orientationChanged:(NSNotification *)notification{

    
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    switch (orientation)
    {
        case UIDeviceOrientationUnknown:
            NSLog(@"UIDeviceOrientationUnknown");
            break;
            
        case UIDeviceOrientationPortrait:
            
            _img.transform=CGAffineTransformMakeRotation(0);
            
            NSLog(@"UIDeviceOrientationPortrait");//good
            break;
            
        case UIDeviceOrientationPortraitUpsideDown:
            NSLog(@"UIDeviceOrientationPortraitUpsideDown");
            
            _img.transform=CGAffineTransformMakeRotation(0);
            _img.transform=CGAffineTransformMakeRotation(2*(M_PI/2));
            
            break;
            
        case UIDeviceOrientationLandscapeLeft:
            NSLog(@"UIDeviceOrientationLandscapeLeft");
            
            _img.transform=CGAffineTransformMakeRotation(0);
            _img.transform=CGAffineTransformMakeRotation(3*(M_PI/2));
            
            break;
            
            
        case UIDeviceOrientationLandscapeRight:
            NSLog(@"UIDeviceOrientationLandscapeRight");
            
            _img.transform=CGAffineTransformMakeRotation(0);
            _img.transform=CGAffineTransformMakeRotation(M_PI/2);//good
            
            break;
            
        case UIDeviceOrientationFaceUp:
            NSLog(@"UIDeviceOrientationFaceUp");
            break;
            
            
        case UIDeviceOrientationFaceDown:
            NSLog(@"UIDeviceOrientationFaceDown");
            break;
    }
    
}




@end
