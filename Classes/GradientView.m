//
//  GradientView.m
//  ShadowedTableView
//
//  Created by Matt Gallagher on 2009/08/21.
//  Copyright 2009 Matt Gallagher. All rights reserved.
//

#import "GradientView.h"
#import <QuartzCore/QuartzCore.h>

@implementation GradientView

@synthesize light;

- (void) setLight:(BOOL)isLight {
    light = isLight; 
    [self setupGradientLayer];
}

//
// layerClass
//
// returns a CAGradientLayer class as the default layer class for this view
//
+ (Class)layerClass
{
	return [CAGradientLayer class];
}

//
// setupGradientLayer
//
// Construct the gradient for either construction method
//
- (void)setupGradientLayer
{
	if(self.light) {
        [self setupLightGradientLayer];
    } else {
        [self setupDarkGradientLayer];
    }
}

- (void) setupLightGradientLayer {
    CAGradientLayer *gradientLayer = (CAGradientLayer *)self.layer;
	gradientLayer.colors =
    [NSArray arrayWithObjects:
     (id)[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0].CGColor,
     (id)[UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.0].CGColor,
     nil];
    gradientLayer.startPoint = CGPointMake(0, 0.0);
    gradientLayer.endPoint = CGPointMake(0, 1.0);
	self.backgroundColor = [UIColor clearColor];
}

- (void) setupDarkGradientLayer {
    CAGradientLayer *gradientLayer = (CAGradientLayer *)self.layer;
    gradientLayer.colors =
    [NSArray arrayWithObjects:
     (id)[UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1.0].CGColor,
     (id)[UIColor colorWithRed:0.65 green:0.65 blue:0.65 alpha:1.0].CGColor,
     nil];
    gradientLayer.startPoint = CGPointMake(0, 0.0);
    gradientLayer.endPoint = CGPointMake(0, 1.0);
    self.backgroundColor = [UIColor clearColor];
}

//
// initWithFrame:
//
// Initialise the view.
//
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
	if (self)
	{
		CAGradientLayer *gradientLayer = (CAGradientLayer *)self.layer;
		gradientLayer.colors =
        [NSArray arrayWithObjects:
         (id)[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0].CGColor,
         (id)[UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.0].CGColor,
         nil];
        gradientLayer.startPoint = CGPointMake(0, 0.0);
        gradientLayer.endPoint = CGPointMake(0, 1.0);
		self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

@end
