//
//  BJRadialUtilities.m
//  BJRadialMenuDemo
//
//  Created by Brad Jasper on 5/25/14.
//  Copyright (c) 2014 Brad Jasper. All rights reserved.
//

#import "BJRadialUtilities.h"

@implementation BJRadialUtilities

CGFloat DegreesToRadians(CGFloat degrees)
{
    return degrees * M_PI / 180;
}

CGFloat RadiansToDegrees(CGFloat radians)
{
    return radians * 180 / M_PI;
}

+ (CGPoint)getPointAlongCircleForItem:(NSUInteger)currItem outOf:(NSUInteger)maxItems between:(NSUInteger)minAngle and:(NSUInteger)maxAngle withRadius:(NSUInteger)radius;
{
    CGFloat spreadAngle = maxAngle - minAngle;
    CGFloat percentage = (CGFloat)currItem / (CGFloat)maxItems;
    CGFloat angle = DegreesToRadians(minAngle + (percentage * spreadAngle));
    
    return CGPointMake(radius * cos(angle), radius * sin(angle));
}

@end
