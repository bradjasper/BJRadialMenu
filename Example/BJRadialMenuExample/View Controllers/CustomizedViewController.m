//
//  CustomizedViewController.m
//  BJRadialMenuExample
//
//  Created by Brad Jasper on 5/31/14.
//  Copyright (c) 2014 Brad Jasper. All rights reserved.
//

#import "CustomizedViewController.h"

// helpful but not required for BJRadialMenu
#import <Tweaks/FBTweakInline.h>

#define MCANIMATE_SHORTHAND
#import "POP+MCAnimate.h"
#import "UIColor+MLPFlatColors.h"
#import "UIColor+CrossFade.h"

@interface CustomizedViewController ()

@property (nonatomic) NSArray *radialSubMenus;
@property (nonatomic) NSArray *colorSteps;
@property (nonatomic) UIButton *addButton;
@property (nonatomic) BJRadialMenu *radialMenu;

@end

@implementation CustomizedViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setup];
}

- (void)setup
{
    // Setup the menu with numbers
    self.radialMenu = [[BJRadialMenu alloc] initWithSubMenus:self.radialSubMenus];
    self.radialMenu.delegate = self;
    
    // All of these are configurable by shaking the device
    FBTweakBind(self.radialMenu, minAngle, @"customizedView", @"radialMenu", @"minAngle", 180);
    FBTweakBind(self.radialMenu, maxAngle, @"customizedView", @"radialMenu", @"maxAngle", 540);
    FBTweakBind(self.radialMenu, openDelayStep, @"customizedView", @"radialMenu", @"openDelayStep", 0.035);
    FBTweakBind(self.radialMenu, closeDelayStep, @"customizedView", @"radialMenu", @"closeDelayStep", 0.025);
    FBTweakBind(self.radialMenu, selectedDelay, @"customizedView", @"radialMenu", @"selectedDelay", 1.0);
    FBTweakBind(self.radialMenu, radius, @"customizedView", @"radialMenu", @"openRadius", 100);
    FBTweakBind(self.radialMenu, radiusStep, @"customizedView", @"radialMenu", @"radiusStep", 0.0);
    FBTweakBind(self.radialMenu, allowMultipleHighlights, @"customizedView", @"radialMenu", @"multipleHighlights", NO);
    
    // Create long-press gesture and assign to button
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(pressedAddButton:)];
    FBTweakBind(longPress, minimumPressDuration, @"customizedView", @"addButton", @"pressDuration", 0.4);

    [self.view addGestureRecognizer:longPress];
//    self.addButton.center = self.view.center;
    
//    [self.view addSubview:self.addButton];
    [self.view addSubview:self.radialMenu];
}


// Handle long press gesture & feed info to submenu
- (void)pressedAddButton:(UILongPressGestureRecognizer *)gesture
{
    switch(gesture.state) {
        case UIGestureRecognizerStateBegan:
            [self.radialMenu openAtPosition:[gesture locationInView:self.view]];
            break;
        case UIGestureRecognizerStateChanged:
            [self.radialMenu moveAtPosition:[gesture locationInView:self.view]];
            break;
        case UIGestureRecognizerStateEnded:
            [self.radialMenu close];
            break;
        default:
            break;
    }
}

- (NSArray *)radialSubMenus
{
    if (_radialSubMenus == nil) {
        
        NSUInteger numMenuItems = FBTweakValue(@"customizedView", @"submenu", @"count", 10);
        
        UIColor *startColor = [UIColor flatRedColor];
        UIColor *endColor = [UIColor flatOrangeColor];
        
        self.colorSteps = [UIColor colorsForFadeBetweenFirstColor:startColor lastColor:endColor inSteps:numMenuItems];
        
        NSMutableArray *items = [NSMutableArray array];
        for (int i = 0; i < numMenuItems; i++) {
            [items addObject:[self createRadialSubMenuWithIndex:i]];
        }
        
        _radialSubMenus = items;
    }
        
    return _radialSubMenus;
}

- (BJRadialSubMenu *)createRadialSubMenuWithIndex:(NSUInteger)index
{
    NSUInteger radius = FBTweakValue(@"customizedView", @"submenu", @"size", 30);
    NSInteger diameter = radius * 2;
    UIColor *color = [self.colorSteps objectAtIndex:index];
    
    BJRadialSubMenu *subMenu = [[BJRadialSubMenu alloc] init];
    subMenu.layer.backgroundColor = color.CGColor;
    subMenu.layer.frame = CGRectMake(0, 0, diameter, diameter);
    subMenu.layer.cornerRadius = radius;
    return subMenu;
}

// Button to display menu
- (UIButton *)addButton
{
    NSUInteger radius = FBTweakValue(@"customizedView", @"addButton", @"buttonRadius", 30);
    NSUInteger borderWidth = FBTweakValue(@"customizedView", @"addButton", @"borderWidth", 2);
    
    if (!_addButton) {
        NSLog(@"creating add button");
        float edgeMultiplier = FBTweakValue(@"customizedView", @"addButton", @"edgeMultiplier", 0.5);
        float edgeAmount = radius * edgeMultiplier;
        
        UIImage *addImage = [UIImage imageNamed:@"plus"];
        _addButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _addButton.layer.backgroundColor = [UIColor whiteColor].CGColor;
        _addButton.layer.borderWidth = borderWidth;
        _addButton.layer.borderColor = [UIColor darkGrayColor].CGColor;
        _addButton.layer.cornerRadius = radius;
        _addButton.bounds = CGRectMake(0, 0, radius*2, radius*2);
        _addButton.layer.zPosition = 1.0;
        _addButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |  UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        [_addButton setImage:addImage forState:UIControlStateNormal];
        [_addButton setImageEdgeInsets:UIEdgeInsetsMake(edgeAmount, edgeAmount, edgeAmount, edgeAmount)];
        
 
        return _addButton;
    }
    
    return _addButton;
}

- (void)resetLayer:(CALayer *)layer
{
    layer.spring.scaleXY = CGPointMake(1.0, 1.0);
}

#pragma mark - Delegate callbacks

- (void)radialMenuIsOpening:(BJRadialMenu *)menu
{
}

- (void)radialMenuIsClosing:(BJRadialMenu *)menu
{
}

- (void)radialMenuHasOpened:(BJRadialMenu *)menu
{
}

- (void)radialMenuHasClosed:(BJRadialMenu *)menu
{
    for (BJRadialSubMenu *subMenu in self.radialMenu.subMenus) {
        [self resetLayer:subMenu.layer];
    }
}

- (void)radialMenuHasHighlighted:(BJRadialMenu *)menu subMenu:(BJRadialSubMenu *)subMenu
{
    CGFloat scale = FBTweakValue(@"customizedView", @"submenu", @"highlightScale", 1.5, 0, 10);
    subMenu.layer.spring.scaleXY = CGPointMake(scale, scale);
    
    POPSpringAnimation *higlight = [subMenu.layer pop_animationForKey:@"highlight"];
    if (higlight == nil) {
        higlight = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerBackgroundColor];
        higlight.toValue = [UIColor flatRedColor];
        [subMenu.layer pop_addAnimation:higlight forKey:@"highlight"];
    } else {
        higlight.toValue = [UIColor flatRedColor];
    }
}

- (void)radialMenuHasUnhighlighted:(BJRadialMenu *)menu subMenu:(BJRadialSubMenu *)subMenu
{
    subMenu.layer.spring.scaleXY = CGPointMake(1.0, 1.0);
    
    NSUInteger idx = [self.radialSubMenus indexOfObject:subMenu];
    UIColor *color = self.colorSteps[idx];
    
    POPSpringAnimation *higlight = [subMenu.layer pop_animationForKey:@"highlight"];
    if (higlight == nil) {
        higlight = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerBackgroundColor];
        higlight.toValue = color;
        [subMenu.layer pop_addAnimation:higlight forKey:@"highlight"];
    } else {
        higlight.toValue = color;
    }
}

- (void)radialMenuHasSelected:(BJRadialMenu *)menu subMenu:(BJRadialSubMenu *)subMenu
{
    
    NSUInteger idx = [self.radialSubMenus indexOfObject:subMenu];
    UIColor *color = self.colorSteps[idx];
    
    POPSpringAnimation *higlight = [subMenu.layer pop_animationForKey:@"highlight"];
    if (higlight == nil) {
        higlight = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerBackgroundColor];
        higlight.toValue = color;
        [subMenu.layer pop_addAnimation:higlight forKey:@"highlight"];
    } else {
        higlight.toValue = color;
    }
}

@end
