//
//  BJRadialMenu.h
//  BJRadialMenuDemo
//
//  Created by Brad Jasper on 5/23/14.
//  Copyright (c) 2014 Brad Jasper. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <POP/POP.h>

#import "BJRadialUtilities.h"
#import "BJRadialSubMenu.h"

#pragma mark - BJRadialMenuDelegate definition

@class BJRadialMenu;
@protocol BJRadialMenuDelegate <NSObject>
@optional
- (void)radialMenuIsOpening:(BJRadialMenu *)menu;
- (void)radialMenuIsClosing:(BJRadialMenu *)menu;
- (void)radialMenuHasOpened:(BJRadialMenu *)menu;
- (void)radialMenuHasClosed:(BJRadialMenu *)menu;
- (void)radialMenuHasHighlighted:(BJRadialMenu *)menu subMenu:(BJRadialSubMenu *)subMenu;
- (void)radialMenuHasUnhighlighted:(BJRadialMenu *)menu subMenu:(BJRadialSubMenu *)subMenu;
- (void)radialMenuHasSelected:(BJRadialMenu *)menu subMenu:(BJRadialSubMenu *)subMenu;
@end

#pragma mark - BJRadialMenu definition

typedef NS_ENUM(NSUInteger, BJRadialMenuState) {
    kBJRadialMenuStateClosed,
    kBJRadialMenuStateClosing,
    kBJRadialMenuStateOpened,
    kBJRadialMenuStateOpening,
    kBJRadialMenuStateHighlighted,
    kBJRadialMenuStateUnhighlighted = kBJRadialMenuStateOpened,
    kBJRadialMenuStateSelected,
};

@interface BJRadialMenu : UIView <BJRadialSubMenuDelegate> {
    CGPoint position;
}

@property (nonatomic, readonly) NSArray *subMenus;
@property (nonatomic) BJRadialMenuState menuState;
@property (nonatomic) CGFloat radiusStep;
@property (nonatomic) CGFloat openDelayStep;
@property (nonatomic) CGFloat closeDelayStep;
@property (nonatomic) CGFloat selectedDelay;
@property (nonatomic) CGFloat minAngle;
@property (nonatomic) CGFloat maxAngle;
@property (nonatomic) CGFloat radius;
@property (nonatomic) BOOL allowMultipleHighlights;
@property (weak, nonatomic) id <BJRadialMenuDelegate> delegate;

- (id)initWithSubMenus:(NSArray *)subMenus;
- (id)initWithViews:(NSArray *)views;
- (id)initWithLayers:(NSArray *)layers;
- (id)initWithText:(NSArray *)textItems;

- (void)openAtPosition:(CGPoint)aPosition;
- (void)close;

- (void)moveAtPosition:(CGPoint)aPosition;

@end
