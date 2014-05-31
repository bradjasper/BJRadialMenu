//
//  BJRadialMenu.m
//  BJRadialMenuDemo
//
//  Created by Brad Jasper on 5/23/14.
//  Copyright (c) 2014 Brad Jasper. All rights reserved.
//

#import "BJRadialMenu.h"

@interface BJRadialMenu ()
@property (strong, nonatomic) NSArray *subMenus;
@end

@implementation BJRadialMenu

#pragma mark - Init

- (id)initWithSubMenus:(NSArray *)subMenus
{
    self = [super init];
    if (self)
    {
        NSMutableArray *preparedSubMenus = [[NSMutableArray alloc] init];
        [subMenus enumerateObjectsUsingBlock:^(BJRadialSubMenu *subMenu, NSUInteger idx, BOOL *stop) {
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
        
        BJRadialSubMenu *subMenu = [[BJRadialSubMenu alloc] initWithView:view];
        [preparedSubMenus addObject:subMenu];
    }
    
    return [self initWithSubMenus:preparedSubMenus];
}

- (id)initWithText:(NSArray *)textItems
{
    NSMutableArray *preparedSubMenus = [[NSMutableArray alloc] init];
    for (NSString *text in textItems) {
        BJRadialSubMenu *subMenu = [[BJRadialSubMenu alloc] initWithText:text];
        [preparedSubMenus addObject:subMenu];
    }
    
    return [self initWithSubMenus:preparedSubMenus];
}

- (void)resetToDefaults
{
    position = CGPointZero;
    activeSubMenuIndex = kBJRadialMenuNoActiveSubMenu;
    _menuState = kBJRadialMenuStateClosed;
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
    
    if (_menuState != kBJRadialMenuStateClosed) {
        NSLog(@"Menu isn't closed or closing...can't open");
        return;
    }
    
    [self opening];
    
    position = aPosition;
    
    BJRadialMenuType menuType = [self menuTypeFromCurrentAngles];
    NSUInteger numSubMenus = [_subMenus count];
    
    [_subMenus enumerateObjectsUsingBlock:^(BJRadialSubMenu *subMenu, NSUInteger zeroIdx, BOOL *stop) {

        NSUInteger idx = zeroIdx + 1;
        NSUInteger max = numSubMenus;
        if (menuType == kBJRadialMenuTypeSemiCircle) {
            max--;
        }
        
        CGPoint relPos = [BJRadialUtilities getPointAlongCircleForItem:zeroIdx
                                                                 outOf:max
                                                               between:_minAngle
                                                                   and:_maxAngle
                                                            withRadius:_radius];
        CGPoint absPos = CGPointMake(aPosition.x + relPos.x, aPosition.y + relPos.y);
        CGFloat delay = _openDelayStep * idx;
        
        [self openBJRadialSubMenu:subMenu atPosition:absPos withDelay:delay];
    }];
}

- (void)close
{
    if (_menuState == kBJRadialMenuStateClosed) {
        NSLog(@"Menu is already closed");
        return;
    }
    
    [self closing];
    
    activeSubMenuIndex = kBJRadialMenuNoActiveSubMenu;
    
    [_subMenus enumerateObjectsUsingBlock:^(BJRadialSubMenu *subMenu, NSUInteger zeroIdx, BOOL *stop) {
        NSUInteger oneIdx = zeroIdx + 1;
        CGFloat delay = _closeDelayStep * oneIdx;
        
        if (subMenu.menuState == kBJRadialSubMenuStateHighlighted) {
            [self selectBJRadialSubMenu:subMenu withDelay:delay];
        } else {
            [self closeBJRadialSubMenu:subMenu withDelay:delay];
        }
    }];
}

- (BJRadialMenuType)menuTypeFromCurrentAngles
{
    float angleDiff = _maxAngle - _minAngle;
    if (angleDiff == 360.0) {
        return kBJRadialMenuTypeFullCircle;
    }
    
    return kBJRadialMenuTypeSemiCircle;
}

- (void)moveAtPosition:(CGPoint)aPosition
{
    if (_menuState != kBJRadialMenuStateOpened &&
        _menuState != kBJRadialMenuStateHighlighted &&
        _menuState != kBJRadialMenuStateUnhighlighted) {
        return;
    }
    
    // Check if we moved off active sub menu
    if (activeSubMenuIndex != kBJRadialMenuNoActiveSubMenu) {
        BJRadialSubMenu *subMenu = [_subMenus objectAtIndex:activeSubMenuIndex];
        
        if (![subMenu isHighlightedAtPosition:aPosition]) {
            [self unhiglightBJRadialSubMenu:subMenu];
        }
        return;
    }
    
    if (activeSubMenuIndex != kBJRadialMenuNoActiveSubMenu) return;
    
    // Otherwise figure out where we are
    [_subMenus enumerateObjectsUsingBlock:^(BJRadialSubMenu *subMenu, NSUInteger idx, BOOL *stop) {
        if (activeSubMenuIndex == idx) return;
        
        if ([subMenu isHighlightedAtPosition:aPosition]) {
            
            if (activeSubMenuIndex != kBJRadialMenuNoActiveSubMenu) {
                [self unhiglightBJRadialSubMenu:subMenu];
            }
            
            [self higlightBJRadialSubMenu:subMenu];
        }
    }];
}

#pragma mark - SubMenu Actions

- (void)openBJRadialSubMenu:(BJRadialSubMenu *)subMenu atPosition:(CGPoint)aPosition withDelay:(CGFloat)delay
{
    [subMenu openToPosition:aPosition basePosition:position withDelay:delay];
}

- (void)closeBJRadialSubMenu:(BJRadialSubMenu *)subMenu withDelay:(CGFloat)delay
{
    [subMenu closeWithDelay:delay];
}

- (void)higlightBJRadialSubMenu:(BJRadialSubMenu *)subMenu
{
    activeSubMenuIndex = [_subMenus indexOfObject:subMenu];
    [subMenu highlight];
}

- (void)unhiglightBJRadialSubMenu:(BJRadialSubMenu *)subMenu
{
    activeSubMenuIndex = kBJRadialMenuNoActiveSubMenu;
    [subMenu unhighlight];
}

- (void)selectBJRadialSubMenu:(BJRadialSubMenu *)subMenu withDelay:(CGFloat)origDelay
{
    [subMenu selectWithDelay:origDelay + _selectedDelay];
}

#pragma mark - SubMenu Delegate Callbacks

- (void)radialSubMenuHasOpened:(BJRadialSubMenu *)subMenu
{
    NSUInteger numOpenedMenus = 0;
    
    for (BJRadialSubMenu *aSubMenu in _subMenus) {
        if (aSubMenu.menuState == kBJRadialSubMenuStateOpened) {
            numOpenedMenus++;
        }
    }
    
    if (numOpenedMenus == [_subMenus count]) {
        [self opened];
    }
}

- (void)radialSubMenuHasClosed:(BJRadialSubMenu *)subMenu
{
    NSUInteger numClosedMenus = 0;
    
    for (BJRadialSubMenu *aSubMenu in _subMenus) {
        if (aSubMenu.menuState == kBJRadialSubMenuStateClosed) {
            numClosedMenus++;
        }
    }
    
    if (numClosedMenus == [_subMenus count]) {
        [self closed];
    }
}

- (void)radialSubMenuHasHighlighted:(BJRadialSubMenu *)subMenu
{
    [self highlighted:subMenu];
}

- (void)radialSubMenuHasUnhighlighted:(BJRadialSubMenu *)subMenu
{
    [self unhighlighted:subMenu];
}

- (void)radialSubMenuHasSelected:(BJRadialSubMenu *)subMenu
{
    [self selected:subMenu];
}

# pragma mark - Delegate Callbacks

- (void)opened
{
    _menuState = kBJRadialMenuStateOpened;
    if([[self delegate] respondsToSelector:@selector(radialMenuHasOpened)]) {
        [[self delegate] radialMenuHasOpened];
    }
}

- (void)closed
{
    _menuState = kBJRadialMenuStateClosed;
    if([[self delegate] respondsToSelector:@selector(radialMenuHasClosed)]) {
        [[self delegate] radialMenuHasClosed];
    }
}

- (void)highlighted:(BJRadialSubMenu *)subMenu
{
    _menuState = kBJRadialMenuStateHighlighted;
    if([[self delegate] respondsToSelector:@selector(radialSubMenuHasHighlighted:)]) {
        [[self delegate] radialSubMenuHasHighlighted:subMenu];
    }
}

- (void)unhighlighted:(BJRadialSubMenu *)subMenu
{
    _menuState = kBJRadialMenuStateUnhighlighted;
    if([[self delegate] respondsToSelector:@selector(radialSubMenuHasUnhighlighted:)]) {
        [[self delegate] radialSubMenuHasUnhighlighted:subMenu];
    }
}

- (void)selected:(BJRadialSubMenu *)subMenu
{
    _menuState = kBJRadialMenuStateSelected;
    if([[self delegate] respondsToSelector:@selector(radialSubMenuHasSelected:)]) {
        [[self delegate] radialSubMenuHasSelected:subMenu];
    }
}

- (void)opening
{
    _menuState = kBJRadialMenuStateOpening;
    if([[self delegate] respondsToSelector:@selector(radialMenuIsOpening)]) {
        [[self delegate] radialMenuIsOpening];
    }
}

- (void)closing
{
    _menuState = kBJRadialMenuStateClosing;
    if([[self delegate] respondsToSelector:@selector(radialMenuIsClosing)]) {
        [[self delegate] radialMenuIsClosing];
    }
}

@end
