//
//  GradientCell.m
//  Bungalow
//
//  Created by Jeff Miller on 07/09/2009.
//  Copyright 2009 Greycourt Software. All rights reserved.
//

#import "GradientCell.h"
#import "GradientView.h"


@implementation GradientCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        // Initialization code
        self.backgroundView = [[[GradientView alloc] initWithFrame:self.frame] autorelease];
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    self.textLabel.backgroundColor = [UIColor clearColor];
    self.detailTextLabel.backgroundColor = [UIColor clearColor];
    
    if (self.accessoryView != nil)   
        self.accessoryView.superview.backgroundColor = self.contentView.backgroundColor;
}


- (void)dealloc {
    [super dealloc];
}


@end
