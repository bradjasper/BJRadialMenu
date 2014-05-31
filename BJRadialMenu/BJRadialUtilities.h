//
//  BJRadialUtilities.h
//  BJRadialMenuDemo
//
//  Created by Brad Jasper on 5/25/14.
//  Copyright (c) 2014 Brad Jasper. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BJRadialUtilities : NSObject

+ (CGPoint)getPointAlongCircleForItem:(NSUInteger)currItem outOf:(NSUInteger)maxItems between:(NSUInteger)minAngle and:(NSUInteger)maxAngle withRadius:(NSUInteger)radius;

@end
