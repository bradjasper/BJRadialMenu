//
//  BJRadialMenu.m
//  BJRadialMenuDemo
//
//  Created by Brad Jasper on 5/23/14.
//  Copyright (c) 2014 Brad Jasper. All rights reserved.
//

#import "BJRadialMenu.h"

@interface BJRadialMenu ()
// TODO: Move to non-property
@property (nonatomic) NSUInteger numMenusOpening;
@property (nonatomic) NSUInteger numMenusOpened;
@end

@implementation BJRadialMenu

#pragma mark - Init

- (id)initWithSubMenus:(NSArray *)subMenus
{
    self = [super init];
    if (self)
    {
        NSMutableArray *preparedSubMenus = [NSMutableArray array];
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
    NSMutableArray *preparedSubMenus = [NSMutableArray array];
    for (UIView *view in views) {
        
        BJRadialSubMenu *subMenu = [[BJRadialSubMenu alloc] initWithView:view];
        [preparedSubMenus addObject:subMenu];
    }
    
    return [self initWithSubMenus:preparedSubMenus];
}

- (id)initWithText:(NSArray *)textItems
{
    NSMutableArray *preparedSubMenus = [NSMutableArray array];
    for (NSString *text in textItems) {
        BJRadialSubMenu *subMenu = [[BJRadialSubMenu alloc] initWithText:text];
        [preparedSubMenus addObject:subMenu];
    }
    
    return [self initWithSubMenus:preparedSubMenus];
}

- (id)initWithLayers:(NSArray *)layers
{
    NSMutableArray *preparedSubMenus = [NSMutableArray array];
    for (CALayer *layer in layers) {
        BJRadialSubMenu *subMenu = [[BJRadialSubMenu alloc] initWithLayer:layer];
        [preparedSubMenus addObject:subMenu];
    }
    
    return [self initWithSubMenus:preparedSubMenus];
}

- (void)resetToDefaults
{
    position = CGPointZero;
    _menuState = kBJRadialMenuStateClosed;
    _numMenusOpened = 0;
    _numMenusOpening = 0;
    _radiusStep = 0.0;
    _openDelayStep = 0.045;
    _closeDelayStep = 0.035;
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
        NSLog(@"Menu isn't closed...can't open");
        return;
    }
    
    [self opening];
    
    position = aPosition;
    
    BJRadialMenuType menuType = [self menuTypeFromCurrentAngles];
    NSUInteger numSubMenus = [_subMenus count];
    
    [_subMenus enumerateObjectsUsingBlock:^(BJRadialSubMenu *subMenu, NSUInteger idx, BOOL *stop) {
        
        CGPoint absPos = [self getAbsolutePositionForSubMenuWithIndex:idx
                                                                outOf:numSubMenus
                                                          andMenuType:menuType];
        CGFloat delay = _openDelayStep * (idx + 1);
        _numMenusOpening++;
        [self openRadialSubMenu:subMenu atPosition:absPos withDelay:delay];
    }];
}


- (void)close
{
    if (_menuState == kBJRadialMenuStateClosed) {
        NSLog(@"Menu is already closed");
        return;
    }
    
    [self closing];
    
    [_subMenus enumerateObjectsUsingBlock:^(BJRadialSubMenu *subMenu, NSUInteger zeroIdx, BOOL *stop) {
        NSUInteger oneIdx = zeroIdx + 1;
        CGFloat delay = _closeDelayStep * oneIdx;
        
        if (subMenu.menuState == kBJRadialSubMenuStateHighlighted) {
            [self selectRadialSubMenu:subMenu withDelay:delay];
        } else {
            [self closeRadialSubMenu:subMenu withDelay:delay];
        }
    }];
}

- (void)moveAtPosition:(CGPoint)aPosition
{
    if (_menuState != kBJRadialMenuStateOpened &&
        _menuState != kBJRadialMenuStateHighlighted &&
        _menuState != kBJRadialMenuStateUnhighlighted) {
        return;
    }
    
    // Otherwise figure out where we are
    [_subMenus enumerateObjectsUsingBlock:^(BJRadialSubMenu *subMenu, NSUInteger idx, BOOL *stop) {
        
        BOOL isHighlighted = [subMenu isHighlightedAtPosition:aPosition];
        
        if (subMenu.menuState == kBJRadialSubMenuStateHighlighted) {
            if (!isHighlighted) {
                [self unhiglightRadialSubMenu:subMenu];
            }
        } else {
            if (isHighlighted) {
                [self higlightRadialSubMenu:subMenu];
            }
        }
        
        
    }];
}

#pragma mark - SubMenu helpers

- (BJRadialMenuType)menuTypeFromCurrentAngles
{
    float angleDiff = _maxAngle - _minAngle;
    if (angleDiff == 360.0) {
        return kBJRadialMenuTypeFullCircle;
    }
    
    return kBJRadialMenuTypeSemiCircle;
}

- (CGPoint)getAbsolutePositionForSubMenuWithIndex:(NSUInteger)idx outOf:(NSUInteger)max andMenuType:(BJRadialMenuType)menuType
{
    // If it's a full circle we don't want the edges to overlap
    // but if it's a semicircle, we do
    if (menuType == kBJRadialMenuTypeSemiCircle) {
        max--;
    }
    
    CGFloat absRadius = _radius + (_radiusStep * idx);
    
    CGPoint relPos = [BJRadialUtilities getPointAlongCircleForItem:idx
                                                             outOf:max
                                                           between:_minAngle
                                                               and:_maxAngle
                                                        withRadius:absRadius];
    
    return CGPointMake(position.x + relPos.x, position.y + relPos.y);
}

#pragma mark - SubMenu Actions

- (void)openRadialSubMenu:(BJRadialSubMenu *)subMenu atPosition:(CGPoint)aPosition withDelay:(CGFloat)delay
{
    [subMenu openToPosition:aPosition basePosition:position withDelay:delay];
}

- (void)closeRadialSubMenu:(BJRadialSubMenu *)subMenu withDelay:(CGFloat)delay
{
    [subMenu closeWithDelay:delay];
}

- (void)higlightRadialSubMenu:(BJRadialSubMenu *)subMenu
{
    [subMenu highlight];
}

- (void)unhiglightRadialSubMenu:(BJRadialSubMenu *)subMenu
{
    [subMenu unhighlight];
}

- (void)selectRadialSubMenu:(BJRadialSubMenu *)subMenu withDelay:(CGFloat)origDelay
{
    [subMenu selectWithDelay:origDelay + _selectedDelay];
}

#pragma mark - SubMenu Delegate Callbacks

- (void)radialSubMenuHasOpened:(BJRadialSubMenu *)subMenu
{
    if (++_numMenusOpened == [_subMenus count]) {
        [self opened];
    }
}

- (void)radialSubMenuHasClosed:(BJRadialSubMenu *)subMenu
{
    if (--_numMenusOpening == 0) {
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

# pragma mark - States

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
    _numMenusOpened = 0;
    _numMenusOpening = 0;
    
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
