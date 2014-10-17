//
//  NSData-Base64.h
//  NewREST
//
//  Created by Jeff Miller on 26/05/2009.
//  Copyright 2009 Greycourt Software. All rights reserved.
//

#import <Foundation/Foundation.h>

/*! Helper category on NSData to let us encode base64.  Used by the RESTRequest class specifically for basic authentication. */
@interface NSData (MBBase64)

+ (id)dataWithBase64EncodedString:(NSString *)string;     //  Padding '=' characters are optional. Whitespace is ignored.
- (NSString *)base64Encoding;
@end
