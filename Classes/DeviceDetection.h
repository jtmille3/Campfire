//
//  DeviceDetection.h
//  sherpa
//
//  written by Max Horváth
//

#import <sys/utsname.h>

enum {
    MODEL_IPHONE_SIMULATOR,
    MODEL_IPOD_TOUCH,
    MODEL_IPHONE,
    MODEL_IPHONE_3G,
    MODEL_IPHONE_3GS
};

@interface DeviceDetection : NSObject

+ (uint) detectDevice;
+ (NSString *) returnDeviceName:(BOOL)ignoreSimulator;

@end
