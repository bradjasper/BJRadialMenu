//
//  RadialMenu.h
//  RadialMenuDemo
//
//  Created by Brad Jasper on 5/23/14.
//  Copyright (c) 2014 Brad Jasper. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <POP/POP.h>
#import "RadialUtilities.h"
#import "RadialSubMenu.h"

#pragma mark - RadialMenuDelegate definition

@class RadialMenu;
@protocol RadialMenuDelegate <NSObject>
@optional
- (void)radialMenuHasOpened;
- (void)radialMenuHasClosed;
- (void)radialMenuIsOpening;
- (void)radialMenuIsClosing;
- (void)radialSubMenuHasHighlighted:(RadialSubMenu *)subMenu;
- (void)radialSubMenuHasUnhighlighted:(RadialSubMenu *)subMenu;
- (void)radialSubMenuHasSelected:(RadialSubMenu *)subMenu;
@end

#pragma mark - RadialMenu definition

static NSUInteger kRadialMenuNoActiveSubMenu = -1;

typedef NS_ENUM(NSUInteger, RadialMenuType) {
    kRadialMenuTypeFullCircle,
    kRadialMenuTypeSemiCircle
};
    
typedef NS_ENUM(NSUInteger, RadialMenuState) {
    kRadialMenuStateClosed,
    kRadialMenuStateClosing,
    kRadialMenuStateOpened,
    kRadialMenuStateOpening,
    kRadialMenuStateHighlighted,
    kRadialMenuStateUnhighlighted = kRadialMenuStateOpened,
    kRadialMenuStateSelected,
};

@interface RadialMenu : UIView <RadialSubMenuDelegate> {
    CGPoint position;
    NSUInteger activeSubMenuIndex;
}

@property (nonatomic) RadialMenuState menuState;
@property (nonatomic) CGFloat openDelayStep;
@property (nonatomic) CGFloat closeDelayStep;
@property (nonatomic) CGFloat selectedDelay;
@property (nonatomic) CGFloat minAngle;
@property (nonatomic) CGFloat maxAngle;
@property (nonatomic) CGFloat radius;
@property (weak, nonatomic) id <RadialMenuDelegate> delegate;

- (id)initWithSubMenus:(NSArray *)subMenus;
- (id)initWithViews:(NSArray *)views;
- (id)initWithText:(NSArray *)textItems;

- (void)openAtPosition:(CGPoint)aPosition;
- (void)close;

- (void)moveAtPosition:(CGPoint)aPosition;

@end
