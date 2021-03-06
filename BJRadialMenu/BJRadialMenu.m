//
//  BJRadialMenu.m
//  BJRadialMenuDemo
//
//  Created by Brad Jasper on 5/23/14.
//  Copyright (c) 2014 Brad Jasper. All rights reserved.
//

#import "BJRadialMenu.h"

@interface BJRadialMenu () {
    NSUInteger numSubMenusOpening;
    NSUInteger numSubMenusOpened;
    
}

@property (nonatomic) BJRadialSubMenu *higlightedSubMenu;

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
    numSubMenusOpened = 0;
    numSubMenusOpening = 0;
    _radiusStep = 0.0;
    _openDelayStep = 0.045;
    _closeDelayStep = 0.035;
    _selectedDelay = 1;
    _minAngle = 195;
    _maxAngle = 345;
    _radius = 100;
    _higlightedSubMenu = nil;
    _allowMultipleHighlights = NO;
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
    
    NSUInteger numSubMenus = [_subMenus count];
    BOOL isFullCircle = [self isFullCircle];
    
    [_subMenus enumerateObjectsUsingBlock:^(BJRadialSubMenu *subMenu, NSUInteger idx, BOOL *stop) {
        CGPoint absPos = [self getAbsolutePositionForSubMenuAlongCircleWithIndex:idx outOf:numSubMenus fullCircle:isFullCircle];
        CGFloat delay = _openDelayStep * (idx + 1);
        
        numSubMenusOpening++;
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

- (BOOL)isFullCircle
{
    // TODO: Make more flexible
    return (_maxAngle - _minAngle) == 360.0;
}

- (CGPoint)getAbsolutePositionForSubMenuAlongCircleWithIndex:(NSUInteger)idx outOf:(NSUInteger)max fullCircle:(BOOL)fullCircle
{
    // If it's a full circle we don't want the edges to overlap, but if it's a semicircle, we do
    if (!fullCircle) {
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
    if (++numSubMenusOpened == [_subMenus count]) {
        [self opened];
    }
}

- (void)radialSubMenuHasClosed:(BJRadialSubMenu *)subMenu
{
    if (--numSubMenusOpening == 0) {
        [self closed];
    }
}

- (void)radialSubMenuHasHighlighted:(BJRadialSubMenu *)subMenu
{
    if (_allowMultipleHighlights == NO &&
        self.higlightedSubMenu != nil &&
        [self.higlightedSubMenu isEqual:subMenu] == NO) {
        [self unhiglightRadialSubMenu:self.higlightedSubMenu];
    }
    
    self.higlightedSubMenu = subMenu;
    [self highlighted:subMenu];
}

- (void)radialSubMenuHasUnhighlighted:(BJRadialSubMenu *)subMenu
{
    if ([self.higlightedSubMenu isEqual:subMenu]) {
        self.higlightedSubMenu = nil;
    }
    
    [self unhighlighted:subMenu];
}

- (void)radialSubMenuHasSelected:(BJRadialSubMenu *)subMenu
{
    [self selected:subMenu];
}

# pragma mark - States

- (void)opening
{
    // reset
    numSubMenusOpened = 0;
    numSubMenusOpening = 0;
    
    _menuState = kBJRadialMenuStateOpening;
    if([[self delegate] respondsToSelector:@selector(radialMenuIsOpening:)]) {
        [[self delegate] radialMenuIsOpening:self];
    }
}

- (void)closing
{
    _menuState = kBJRadialMenuStateClosing;
    if([[self delegate] respondsToSelector:@selector(radialMenuIsClosing:)]) {
        [[self delegate] radialMenuIsClosing:self];
    }
}

- (void)opened
{
    _menuState = kBJRadialMenuStateOpened;
    if([[self delegate] respondsToSelector:@selector(radialMenuHasOpened:)]) {
        [[self delegate] radialMenuHasOpened:self];
    }
}

- (void)closed
{
    _menuState = kBJRadialMenuStateClosed;
    if([[self delegate] respondsToSelector:@selector(radialMenuHasClosed:)]) {
        [[self delegate] radialMenuHasClosed:self];
    }
}

- (void)highlighted:(BJRadialSubMenu *)subMenu
{
    _menuState = kBJRadialMenuStateHighlighted;
    if([[self delegate] respondsToSelector:@selector(radialMenuHasHighlighted:subMenu:)]) {
        [[self delegate] radialMenuHasHighlighted:self subMenu:subMenu];
    }
}

- (void)unhighlighted:(BJRadialSubMenu *)subMenu
{
    _menuState = kBJRadialMenuStateUnhighlighted;
    if([[self delegate] respondsToSelector:@selector(radialMenuHasUnhighlighted:subMenu:)]) {
        [[self delegate] radialMenuHasUnhighlighted:self subMenu:subMenu];
    }
}

- (void)selected:(BJRadialSubMenu *)subMenu
{
    _menuState = kBJRadialMenuStateSelected;
    if([[self delegate] respondsToSelector:@selector(radialMenuHasSelected:subMenu:)]) {
        [[self delegate] radialMenuHasSelected:self subMenu:subMenu];
    }
}

@end
