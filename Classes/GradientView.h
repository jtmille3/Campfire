//
//  GradientView.h
//  ShadowedTableView
//
//  Created by Matt Gallagher on 2009/08/21.
//  Copyright 2009 Matt Gallagher. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GradientView : UIView
{
    BOOL light;
}

@property (nonatomic) BOOL light;

- (void)setupGradientLayer;
- (void)setupLightGradientLayer;
- (void)setupDarkGradientLayer;

@end
