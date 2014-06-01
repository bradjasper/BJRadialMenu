//
//  BJRadialSubMenu.h
//  BJRadialMenuDemo
//
//  Created by Brad Jasper on 5/25/14.
//  Copyright (c) 2014 Brad Jasper. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <POP/POP.h>

#pragma mark - Static definitions

extern NSString * const kBJRadialSubMenuOpenMoveAnimation;
extern NSString * const kBJRadialSubMenuCloseMoveAnimation;
extern NSString * const kBJRadialSubMenuOpenAlphaAnimation;
extern NSString * const kBJRadialSubMenuCloseAlphaAnimation;

#pragma mark - Delegate

@class BJRadialSubMenu;
@protocol BJRadialSubMenuDelegate <NSObject>
@optional
- (void)radialSubMenuHasOpened:(BJRadialSubMenu *)subMenu;
- (void)radialSubMenuHasClosed:(BJRadialSubMenu *)subMenu;
- (void)radialSubMenuHasHighlighted:(BJRadialSubMenu *)subMenu;
- (void)radialSubMenuHasUnhighlighted:(BJRadialSubMenu *)subMenu;
- (void)radialSubMenuHasSelected:(BJRadialSubMenu *)subMenu;
@end

#pragma mark - Interface

typedef NS_ENUM(NSUInteger, BJRadialSubMenuState) {
    kBJRadialSubMenuStateClosed,
    kBJRadialSubMenuStateClosing,
    kBJRadialSubMenuStateOpened,
    kBJRadialSubMenuStateOpening,
    kBJRadialSubMenuStateHighlighted,
    kBJRadialSubMenuStateHighlighting,
    kBJRadialSubMenuStateUnhighlighted = kBJRadialSubMenuStateOpened,
    kBJRadialSubMenuStateUnhighlighting,
    kBJRadialSubMenuStateSelected,
};

@interface BJRadialSubMenu : UIView <POPAnimationDelegate> {
    CGPoint currPosition;
}

@property (weak, nonatomic) id <BJRadialSubMenuDelegate> delegate;
@property (nonatomic, readonly) BJRadialSubMenuState menuState;
@property CGFloat openSpringSpeed;
@property CGFloat openSpringBounciness;

- (id)initWithView:(UIView *)aView;
- (id)initWithLayer:(CALayer *)layer;
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


// You can subclass move animations, just make sure you do the following:
// 1. Set the delegate to self (events like opened/closed are determined by when an animation finishes)
// 2. Account for open/close delays & durations
// 3. Assign kBJRadialSubMenuOpenMoveAnimation & kBJRadialSubMenuCloseMoveAnimation names accordingly
- (POPAnimation *)moveOpenAnimation;
- (POPAnimation *)moveCloseAnimation;

@end
