//
//  KeyboardTextField.m
//  chat
//
//  Created by Jeff Miller on 06/07/2009.
//  Copyright 2009 Greycourt Software. All rights reserved.
//

#import "KeyboardTextField.h"


@implementation KeyboardTextField

- (CGRect)editingRectForBounds:(CGRect)bounds {
   return CGRectMake(15, 5, 275, 20); 
}

- (void)dealloc {
    [super dealloc];
}


@end
