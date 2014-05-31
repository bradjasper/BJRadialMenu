//
//  RadialMenu.m
//  RadialMenuDemo
//
//  Created by Brad Jasper on 5/23/14.
//  Copyright (c) 2014 Brad Jasper. All rights reserved.
//

#import "RadialMenu.h"

@interface RadialMenu ()
@property (strong, nonatomic) NSArray *subMenus;
@end

@implementation RadialMenu

#pragma mark - Init

- (id)initWithSubMenus:(NSArray *)subMenus
{
    self = [super init];
    if (self)
    {
        NSMutableArray *preparedSubMenus = [[NSMutableArray alloc] init];
        [subMenus enumerateObjectsUsingBlock:^(RadialSubMenu *subMenu, NSUInteger idx, BOOL *stop) {
            subMenu.delegate = self;
            subMenu.tag = idx;
            [self addSubview:subMenu];
            [preparedSubMenus addObject:subMenu];
        }];
        
        _subMenus = preparedSubMenus;
        
        [self resetToDefaults];
        
    }
    
    return self;
}

- (id)initWithViews:(NSArray *)views
{
    NSMutableArray *preparedSubMenus = [[NSMutableArray alloc] init];
    for (UIView *view in views) {
        
        RadialSubMenu *subMenu = [[RadialSubMenu alloc] initWithView:view];
        [preparedSubMenus addObject:subMenu];
    }
    
    return [self initWithSubMenus:preparedSubMenus];
}

- (id)initWithText:(NSArray *)textItems
{
    NSMutableArray *preparedSubMenus = [[NSMutableArray alloc] init];
    for (NSString *text in textItems) {
        RadialSubMenu *subMenu = [[RadialSubMenu alloc] initWithText:text];
        [preparedSubMenus addObject:subMenu];
    }
    
    return [self initWithSubMenus:preparedSubMenus];
}

- (void)resetToDefaults
{
    position = CGPointZero;
    activeSubMenuIndex = kRadialMenuNoActiveSubMenu;
    _menuState = kRadialMenuStateClosed;
    _openDelayStep = 0.055;
    _closeDelayStep = 0.045;
    _selectedDelay = 1;
    _minAngle = 195;
    _maxAngle = 345;
    _radius = 100;
}

#pragma mark - Actions

- (void)openAtPosition:(CGPoint)aPosition
{
    if ([_subMenus count] == 0) {
        NSLog(@"No submenus to open");
        return;
    }
    
    if (_menuState != kRadialMenuStateClosed) {
        NSLog(@"Menu isn't closed or closing...can't open");
        return;
    }
    
    [self opening];
    
    position = aPosition;
    
    RadialMenuType menuType;
    
    float angleDiff = _maxAngle - _minAngle;
    if (angleDiff == 360.0) {
        menuType = kRadialMenuTypeFullCircle;
    } else {
        menuType = kRadialMenuTypeSemiCircle;
    }
    
    
    NSUInteger numSubMenus = [_subMenus count];
    [_subMenus enumerateObjectsUsingBlock:^(RadialSubMenu *subMenu, NSUInteger zeroIdx, BOOL *stop) {

        NSUInteger idx = zeroIdx + 1;
        CGFloat delay = _openDelayStep * idx;

        NSUInteger max = numSubMenus;
        if (menuType == kRadialMenuTypeSemiCircle) {
            max--;
        }

        CGPoint relPos = [RadialUtilities getPointAlongCircleForItem:idx
                                                               outOf:max
                                                             between:_minAngle
                                                                 and:_maxAngle
                                                          withRadius:_radius];
        CGPoint absPos = CGPointMake(aPosition.x + relPos.x, aPosition.y + relPos.y);
        
        [self openRadialSubMenu:subMenu atPosition:absPos withDelay:delay];
    }];
}

- (void)close
{
    if (_menuState == kRadialMenuStateClosed) {
        NSLog(@"Menu is already closed");
        return;
    }
    
    [self closing];
    
    activeSubMenuIndex = kRadialMenuNoActiveSubMenu;
    
    [_subMenus enumerateObjectsUsingBlock:^(RadialSubMenu *subMenu, NSUInteger zeroIdx, BOOL *stop) {
        NSUInteger oneIdx = zeroIdx + 1;
        CGFloat delay = _closeDelayStep * oneIdx;
        
        if (subMenu.menuState == kRadialSubMenuStateHighlighted) {
            [self selectRadialSubMenu:subMenu withDelay:delay];
        } else {
            [self closeRadialSubMenu:subMenu withDelay:delay];
        }
    }];
}

- (void)moveAtPosition:(CGPoint)aPosition
{
    if (_menuState != kRadialMenuStateOpened &&
        _menuState != kRadialMenuStateHighlighted &&
        _menuState != kRadialMenuStateUnhighlighted) {
        return;
    }
    
    // Check if we moved off active sub menu
    if (activeSubMenuIndex != kRadialMenuNoActiveSubMenu) {
        RadialSubMenu *subMenu = [_subMenus objectAtIndex:activeSubMenuIndex];
        
        if (![subMenu isHighlightedAtPosition:aPosition]) {
            [self unhiglightRadialSubMenu:subMenu];
        }
        return;
    }
    
    if (activeSubMenuIndex != kRadialMenuNoActiveSubMenu) return;
    
    // Otherwise figure out where we are
    [_subMenus enumerateObjectsUsingBlock:^(RadialSubMenu *subMenu, NSUInteger idx, BOOL *stop) {
        if (activeSubMenuIndex == idx) return;
        
        if ([subMenu isHighlightedAtPosition:aPosition]) {
            
            if (activeSubMenuIndex != kRadialMenuNoActiveSubMenu) {
                [self unhiglightRadialSubMenu:subMenu];
            }
            
            [self higlightRadialSubMenu:subMenu];
        }
    }];
}

#pragma mark - SubMenu Actions

- (void)openRadialSubMenu:(RadialSubMenu *)subMenu atPosition:(CGPoint)aPosition withDelay:(CGFloat)delay
{
    [subMenu openToPosition:aPosition basePosition:position withDelay:delay];
}

- (void)closeRadialSubMenu:(RadialSubMenu *)subMenu withDelay:(CGFloat)delay
{
    [subMenu closeWithDelay:delay];
}

- (void)higlightRadialSubMenu:(RadialSubMenu *)subMenu
{
    activeSubMenuIndex = [_subMenus indexOfObject:subMenu];
    [subMenu highlight];
}

- (void)unhiglightRadialSubMenu:(RadialSubMenu *)subMenu
{
    activeSubMenuIndex = kRadialMenuNoActiveSubMenu;
    [subMenu unhighlight];
}

- (void)selectRadialSubMenu:(RadialSubMenu *)subMenu withDelay:(CGFloat)origDelay
{
    [subMenu selectWithDelay:origDelay + _selectedDelay];
}

#pragma mark - SubMenu Delegate Callbacks

- (void)radialSubMenuHasOpened:(RadialSubMenu *)subMenu
{
    NSUInteger numOpenedMenus = 0;
    
    for (RadialSubMenu *aSubMenu in _subMenus) {
        if (aSubMenu.menuState == kRadialSubMenuStateOpened) {
            numOpenedMenus++;
        }
    }
    
    if (numOpenedMenus == [_subMenus count]) {
        [self opened];
    }
}

- (void)radialSubMenuHasClosed:(RadialSubMenu *)subMenu
{
    NSUInteger numClosedMenus = 0;
    
    for (RadialSubMenu *aSubMenu in _subMenus) {
        if (aSubMenu.menuState == kRadialSubMenuStateClosed) {
            numClosedMenus++;
        }
    }
    
    if (numClosedMenus == [_subMenus count]) {
        [self closed];
    }
}

- (void)radialSubMenuHasHighlighted:(RadialSubMenu *)subMenu
{
    [self highlighted:subMenu];
}

- (void)radialSubMenuHasUnhighlighted:(RadialSubMenu *)subMenu
{
    [self unhighlighted:subMenu];
}

- (void)radialSubMenuHasSelected:(RadialSubMenu *)subMenu
{
    [self selected:subMenu];
}

# pragma mark - Delegate Callbacks

- (void)opened
{
    _menuState = kRadialMenuStateOpened;
    if([[self delegate] respondsToSelector:@selector(radialMenuHasOpened)]) {
        [[self delegate] radialMenuHasOpened];
    }
}

- (void)closed
{
    _menuState = kRadialMenuStateClosed;
    if([[self delegate] respondsToSelector:@selector(radialMenuHasClosed)]) {
        [[self delegate] radialMenuHasClosed];
    }
}

- (void)highlighted:(RadialSubMenu *)subMenu
{
    _menuState = kRadialMenuStateHighlighted;
    if([[self delegate] respondsToSelector:@selector(radialSubMenuHasHighlighted:)]) {
        [[self delegate] radialSubMenuHasHighlighted:subMenu];
    }
}

- (void)unhighlighted:(RadialSubMenu *)subMenu
{
    _menuState = kRadialMenuStateUnhighlighted;
    if([[self delegate] respondsToSelector:@selector(radialSubMenuHasUnhighlighted:)]) {
        [[self delegate] radialSubMenuHasUnhighlighted:subMenu];
    }
}

- (void)selected:(RadialSubMenu *)subMenu
{
    _menuState = kRadialMenuStateSelected;
    if([[self delegate] respondsToSelector:@selector(radialSubMenuHasSelected:)]) {
        [[self delegate] radialSubMenuHasSelected:subMenu];
    }
}

- (void)opening
{
    _menuState = kRadialMenuStateOpening;
    if([[self delegate] respondsToSelector:@selector(radialMenuIsOpening)]) {
        [[self delegate] radialMenuIsOpening];
    }
}

- (void)closing
{
    _menuState = kRadialMenuStateClosing;
    if([[self delegate] respondsToSelector:@selector(radialMenuIsClosing)]) {
        [[self delegate] radialMenuIsClosing];
    }
}

@end
