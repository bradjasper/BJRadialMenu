//
//  RadialSubMenu.h
//  RadialMenuDemo
//
//  Created by Brad Jasper on 5/25/14.
//  Copyright (c) 2014 Brad Jasper. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <POP/POP.h>

#pragma mark - Delegate

@class RadialSubMenu;
@protocol RadialSubMenuDelegate <NSObject>
@optional
- (void)radialSubMenuHasOpened:(RadialSubMenu *)subMenu;
- (void)radialSubMenuHasClosed:(RadialSubMenu *)subMenu;
- (void)radialSubMenuHasHighlighted:(RadialSubMenu *)subMenu;
- (void)radialSubMenuHasUnhighlighted:(RadialSubMenu *)subMenu;
- (void)radialSubMenuHasSelected:(RadialSubMenu *)subMenu;
@end

#pragma mark - Interface

typedef NS_ENUM(NSUInteger, RadialSubMenuState) {
    kRadialSubMenuStateClosed,
    kRadialSubMenuStateClosing,
    kRadialSubMenuStateOpened,
    kRadialSubMenuStateOpening,
    kRadialSubMenuStateHighlighted,
    kRadialSubMenuStateHighlighting,
    kRadialSubMenuStateUnhighlighted = kRadialSubMenuStateOpened,
    kRadialSubMenuStateUnhighlighting,
    kRadialSubMenuStateSelected,
};

@interface RadialSubMenu : UIView <POPAnimationDelegate> {
    CGPoint currPosition;
}

@property (weak, nonatomic) id <RadialSubMenuDelegate> delegate;
@property (nonatomic, readonly) RadialSubMenuState menuState;

- (id)initWithView:(UIView *)aView;
- (id)initWithText:(NSString *)text;

- (void)openToPosition:(CGPoint)toPosition basePosition:(CGPoint)basePosition;
- (void)openToPosition:(CGPoint)toPosition basePosition:(CGPoint)basePosition withDelay:(CGFloat)delay;
- (void)close;
- (void)closeWithDelay:(CGFloat)delay;

- (BOOL)isHighlightedAtPosition:(CGPoint)aPosition;
- (void)highlight;
- (void)unhighlight;

- (void)select;
- (void)selectWithDelay:(CGFloat)delay;


// Open/close animations aren't really meant to be subclassed, but technically you can, just be sure to
// 1. Set the delegate to self
// 2. Account for open/close delay
// 3. Assign "open"/"close" names
- (POPAnimation *)openAnimation;
- (POPAnimation *)closeAnimation;

@end
