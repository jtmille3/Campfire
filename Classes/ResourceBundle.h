//
//  ResourcesBundle.h
//  sherpa
//
//  Created by Jeff Miller on 07/01/2009.
//  Copyright 2009 Greycourt Software. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ResourceBundle : NSObject {
}

+ (NSUserDefaults*) defaults;

+ (NSInteger)credentialID;
+ (BOOL)ssl;

+ (BOOL) isResetDatabase;
+ (void) setResetDatabase:(BOOL)resetDatabase;

+ (void)setCredentialID:(NSInteger)thisCredentialID;
+ (void)setSSL:(BOOL)enabled;

@end
