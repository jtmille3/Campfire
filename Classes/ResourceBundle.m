//
//  ResourcesBundle.m
//  sherpa
//
//  Created by Jeff Miller on 07/01/2009.
//  Copyright 2009 Greycourt Software. All rights reserved.
//

#import "ResourceBundle.h"

NSString* const kCredentialIDKey = @"credentialID";
NSString* const kSSL = @"ssl";

NSString* const kResetDatabase = @"reset_database";

@implementation ResourceBundle

+ (NSUserDefaults*) defaults {
	return [NSUserDefaults standardUserDefaults];
}

+ (NSInteger)credentialID {
    return [[ResourceBundle defaults] integerForKey:kCredentialIDKey];
}
+ (BOOL)ssl {
	return [[ResourceBundle defaults] boolForKey:kSSL];
}

+ (void)setCredentialID:(NSInteger)thisCredentialID {
	NSUserDefaults* defaults = [ResourceBundle defaults];
	[defaults setInteger:thisCredentialID forKey:kCredentialIDKey];
	[defaults synchronize];
}
+ (void)setSSL:(BOOL)enabled {
	NSUserDefaults* defaults = [ResourceBundle defaults];
	[defaults setBool:enabled forKey:kSSL];
	[defaults synchronize];	
}

+ (BOOL) isResetDatabase {
    return [[ResourceBundle defaults] boolForKey:kResetDatabase];
}

+ (void) setResetDatabase:(BOOL)resetDatabase {
	NSUserDefaults* defaults = [ResourceBundle defaults];
	[defaults setBool:resetDatabase forKey:kResetDatabase];
	[defaults synchronize];	    
}

@end
