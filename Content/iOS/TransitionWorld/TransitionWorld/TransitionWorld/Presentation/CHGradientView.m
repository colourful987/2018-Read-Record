//
//  CHGradientView.m
//  TransitionWorld
//
//  Created by pmst on 2018/8/27.
//  Copyright © 2018 pmst. All rights reserved.
//

#import "CHGradientView.h"

@implementation CHGradientView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        self.backgroundColor = UIColor.clearColor;
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        self.backgroundColor = UIColor.clearColor;
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect {
    
    CGFloat components[8] = {0, 0, 0, 0.3, 0, 0, 0, 0.7};
    CGFloat locations[2] = {0, 1};
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, components, locations, 2);
    CGFloat x = CGRectGetMidX(self.bounds);
    CGFloat y = CGRectGetMidY(self.bounds);
    CGPoint point = CGPointMake(x, y);
    CGFloat radius = MAX(x, y);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawRadialGradient(context, gradient, point, 0, point, radius, kCGGradientDrawsAfterEndLocation);
    
    CGGradientRelease(gradient);
    
}


@end
