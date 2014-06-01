//
//  BJRadialSubMenu.m
//  BJRadialMenuDemo
//
//  Created by Brad Jasper on 5/25/14.
//  Copyright (c) 2014 Brad Jasper. All rights reserved.
//

#import "BJRadialSubMenu.h"

NSString * const kBJRadialSubMenuOpenMoveAnimation = @"kBJRadialSubMenuOpenMoveAnimation";
NSString * const kBJRadialSubMenuCloseMoveAnimation = @"kBJRadialSubMenuCloseMoveAnimation";
NSString * const kBJRadialSubMenuOpenAlphaAnimation = @"kBJRadialSubMenuOpenAlphaAnimation";
NSString * const kBJRadialSubMenuCloseAlphaAnimation = @"kBJRadialSubMenuCloseAlphaAnimation";


@interface BJRadialSubMenu () {
    CGPoint origPosition;
    CGRect  origBounds;
    
    CGFloat openDelay;
    CGFloat closeDelay;
    CGFloat openDuration;
    CGFloat closeDuration;
}

@end

@implementation BJRadialSubMenu

#pragma mark - Init

- (id)init
{
    self = [super init];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithView:(UIView *)aView
{
    self = [self initWithFrame:aView.frame];
    [self addSubview:aView];
    return self;
}

- (id)initWithLayer:(CALayer *)layer
{
    self = [self initWithFrame:layer.bounds];
    [self.layer addSublayer:layer];
    return self;
}

- (id)initWithText:(NSString *)text
{
    NSUInteger radius = 35;
    NSUInteger borderWidth = 2;
    CGColorRef borderColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5].CGColor;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, radius*2, radius*2)];
    label.textAlignment = NSTextAlignmentCenter;
    label.layer.borderColor = borderColor;
    label.layer.borderWidth = borderWidth;
    label.layer.cornerRadius = radius;
    label.text = text;
    
    return [self initWithView:label];
}

- (void)initialize
{
    _menuState = kBJRadialSubMenuStateClosed;
    
    origPosition = self.center;
    origBounds = self.bounds;
    
    currPosition = self.center;
    
    // hide by default (open/close take care of transparency so there are no jumps)
    self.alpha = 0.0;
    
    openDelay = 0.0;
    closeDelay = 0.0;
    openDuration = 0.03125;
    closeDuration = 0.125;
}

#pragma mark - Actions

- (void)openToPosition:(CGPoint)toPosition basePosition:(CGPoint)basePosition withDelay:(CGFloat)delay;
{
    currPosition = toPosition;
    origPosition = basePosition;
    
    self.center = origPosition;
    
    openDelay = delay;
    
    [self opening];
    [self fadeInWithDelay:openDelay];
    [self openAnimation];
}

- (void)openToPosition:(CGPoint)toPosition basePosition:(CGPoint)basePosition;
{
    [self openToPosition:toPosition basePosition:basePosition withDelay:0.0];
}

- (void)close
{
    [self closeWithDelay:0.0];
}

- (BOOL)isHighlightedAtPosition:(CGPoint)aPosition
{
    return CGRectContainsPoint(self.frame, aPosition);
}

- (void)closeWithDelay:(CGFloat)delay
{
    closeDelay = delay;
    [self closing];
    [self closeAnimation];
}

- (void)selectWithDelay:(CGFloat)delay
{
    [self selected];
    [self closeWithDelay:delay];
}

- (void)select
{
    [self selectWithDelay:0.0];
}

- (void)highlight
{
    if (_menuState != kBJRadialSubMenuStateOpened) {
        return;
    }
    
    [self highlighting];
}

- (void)unhighlight;
{
    [self unhighlighting];
}

#pragma mark - Animation Delegates

- (void)pop_animationDidStart:(POPAnimation *)anim
{
    // Start fade as soon as movement starts for close
    if ([anim.name isEqualToString:kBJRadialSubMenuCloseMoveAnimation]) {
        [self fadeOutWithDelay:0.0];
    }
}

- (void)pop_animationDidStop:(POPAnimation *)anim finished:(BOOL)finished
{
    if (!finished) {
        return;
    }
    
    if ([anim.name isEqualToString:kBJRadialSubMenuOpenMoveAnimation]) {
        if (_menuState == kBJRadialSubMenuStateOpening) {
            [self opened];
        } else if (_menuState == kBJRadialSubMenuStateClosing) {
            [self closeAnimation];
        }
    } else if ([anim.name isEqualToString:kBJRadialSubMenuCloseMoveAnimation]) {
        if (_menuState == kBJRadialSubMenuStateOpening) {
            [self openAnimation];
        } else if (_menuState == kBJRadialSubMenuStateClosing) {
            [self closed];
        }
    }
}

#pragma mark - Animations

- (POPAnimation *)openAnimation
{
    
    CGFloat openSpringSpeed = 17.0;
    CGFloat openSpringBounciness = 8.0;
    CFTimeInterval absDelay = CACurrentMediaTime() + openDelay;
    
    POPSpringAnimation *anim = [self pop_animationForKey:kBJRadialSubMenuOpenMoveAnimation];
    
    
    if (anim == NULL)
    {
        anim = [POPSpringAnimation animationWithPropertyNamed:kPOPViewCenter];
        anim.name = kBJRadialSubMenuOpenMoveAnimation;
        anim.beginTime = absDelay;
        anim.toValue = [NSValue valueWithCGPoint:currPosition];
        anim.springSpeed = openSpringSpeed;
        anim.springBounciness = openSpringBounciness;
        anim.delegate = self;
        
        [self pop_addAnimation:anim forKey:kBJRadialSubMenuOpenMoveAnimation];
    }
    
    return anim;
}


- (POPAnimation *)closeAnimation
{
    POPBasicAnimation *anim = [self pop_animationForKey:kBJRadialSubMenuCloseMoveAnimation];
    
    CFTimeInterval absDelay = CACurrentMediaTime() + closeDelay;
    
    if (anim == NULL) {
        anim = [POPBasicAnimation animationWithPropertyNamed:kPOPViewCenter];
        anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        anim.name = kBJRadialSubMenuCloseMoveAnimation;
        anim.beginTime = absDelay;
        anim.toValue = [NSValue valueWithCGPoint:origPosition];
        anim.duration = closeDuration;
        anim.delegate = self;
        
        [self pop_addAnimation:anim forKey:kBJRadialSubMenuCloseMoveAnimation];
    }
    
    return anim;
}

- (POPAnimation *)fadeOutWithDelay:(CGFloat)delay
{
    
    CFTimeInterval absDelay = CACurrentMediaTime() + delay;
    POPBasicAnimation *anim = [self pop_animationForKey:kBJRadialSubMenuCloseAlphaAnimation];
    
    if (anim == NULL) {
        
        anim = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
        anim.name = kBJRadialSubMenuCloseAlphaAnimation;
        anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        anim.duration = closeDuration;
        anim.beginTime = absDelay;
        anim.toValue = @(0.0);
        
        [self pop_addAnimation:anim forKey:kBJRadialSubMenuCloseAlphaAnimation];
    } else {
        anim.toValue = @(0.0);
    }
    
    return anim;
}

- (POPAnimation *)fadeInWithDelay:(CGFloat)delay
{
    
    CFTimeInterval absDelay = CACurrentMediaTime() + delay;
    POPBasicAnimation *anim = [self pop_animationForKey:kBJRadialSubMenuOpenAlphaAnimation];
    
    if (anim == NULL) {
        anim = [POPBasicAnimation animationWithPropertyNamed:kPOPViewAlpha];
        anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        anim.name = kBJRadialSubMenuOpenAlphaAnimation;
        anim.toValue = @(1.0);
        anim.beginTime = absDelay;
        anim.duration = openDuration;
        [self pop_addAnimation:anim forKey:kBJRadialSubMenuOpenAlphaAnimation];
    } else {
        anim.toValue = @(1.0);
    }
    
    return anim;
}

#pragma mark - States

- (void)closed
{
    // When we close, make sure to remove open animations incase any haven't triggered yet
    [self pop_removeAnimationForKey:kBJRadialSubMenuOpenMoveAnimation];
    [self pop_removeAnimationForKey:kBJRadialSubMenuOpenAlphaAnimation];
    
    _menuState = kBJRadialSubMenuStateClosed;
    
    if([[self delegate] respondsToSelector:@selector(radialSubMenuHasClosed:)]) {
        [[self delegate] radialSubMenuHasClosed:self];
    }
}

- (void)opening
{
    _menuState = kBJRadialSubMenuStateOpening;
    
}

- (void)opened
{
    _menuState = kBJRadialSubMenuStateOpened;
    if([[self delegate] respondsToSelector:@selector(radialSubMenuHasOpened:)]) {
        [[self delegate] radialSubMenuHasOpened:self];
    }
}

- (void)highlighting
{
    _menuState = kBJRadialSubMenuStateHighlighting;
    
    // currently no animation so move to next
    [self highlighted];
}

- (void)highlighted
{
    _menuState = kBJRadialSubMenuStateHighlighted;
    if([[self delegate] respondsToSelector:@selector(radialSubMenuHasHighlighted:)]) {
        [[self delegate] radialSubMenuHasHighlighted:self];
    }
}

- (void)unhighlighting
{
    _menuState = kBJRadialSubMenuStateUnhighlighting;
    
    // currently no animation so move to next
    [self unhighlighted];
}

- (void)unhighlighted
{
    _menuState = kBJRadialSubMenuStateUnhighlighted;
    if([[self delegate] respondsToSelector:@selector(radialSubMenuHasUnhighlighted:)]) {
        [[self delegate] radialSubMenuHasUnhighlighted:self];
    }
}

- (void)selected
{
    _menuState = kBJRadialSubMenuStateSelected;
    if([[self delegate] respondsToSelector:@selector(radialSubMenuHasSelected:)]) {
        [[self delegate] radialSubMenuHasSelected:self];
    }
}

- (void)closing
{
    _menuState = kBJRadialSubMenuStateClosing;
}
@end
