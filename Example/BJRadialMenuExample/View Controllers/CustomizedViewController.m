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

@interface CustomizedViewController ()

@property (nonatomic) NSArray *radialSubMenus;
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
    // Create long-press gesture and assign to button
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(pressedAddButton:)];
    FBTweakBind(longPress, minimumPressDuration, @"view2", @"button", @"pressDuration", 0.4);

    [self.addButton addGestureRecognizer:longPress];
    
    self.addButton.center = self.view.center;
    
    [self.view addSubview:self.addButton];
    [self.view addSubview:self.radialMenu];
}

// Handle long press gesture & feed info to submenu
- (void)pressedAddButton:(UILongPressGestureRecognizer *)gesture
{
    switch(gesture.state) {
        case UIGestureRecognizerStateBegan:
            [self.radialMenu openAtPosition:_addButton.center];
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
        NSUInteger numMenuItems = FBTweakValue(@"menu2", @"submenu", @"count", 25);
        
        NSMutableArray *items = [NSMutableArray array];
        for (int i = 1; i <= numMenuItems; i++) {
            [items addObject:[self createRadialSubMenu]];
        }
        
        _radialSubMenus = items;
    }
        
    return _radialSubMenus;
}

- (BJRadialMenu *)radialMenu
{
    if (_radialMenu == nil) {
        _radialMenu = [[BJRadialMenu alloc] initWithSubMenus:self.radialSubMenus];
        _radialMenu.delegate = self;
        
        // All of these are configurable by shaking the device
        FBTweakBind(_radialMenu, minAngle, @"menu2", @"angle", @"min", 180);
        FBTweakBind(_radialMenu, maxAngle, @"menu2", @"angle", @"max", 540);
        FBTweakBind(_radialMenu, openDelayStep, @"menu2", @"open", @"delayStep", 0.035);
        FBTweakBind(_radialMenu, closeDelayStep, @"menu2", @"close", @"delayStep", 0.025);
        FBTweakBind(_radialMenu, selectedDelay, @"menu2", @"selected", @"delay", 2.5);
        FBTweakBind(_radialMenu, radius, @"menu2", @"submenu", @"radius", 100);
        FBTweakBind(_radialMenu, radiusStep, @"menu2", @"open", @"radiusStep", 0.25);
    }
    
    return _radialMenu;
    
}
- (BJRadialSubMenu *)createRadialSubMenu
{
    NSUInteger radius = FBTweakValue(@"menu2", @"submenu", @"size", 15);
    NSInteger diameter = radius * 2;
    
    BJRadialSubMenu *subMenu = [[BJRadialSubMenu alloc] init];
    subMenu.layer.backgroundColor = [UIColor randomFlatDarkColor].CGColor;
    subMenu.layer.frame = CGRectMake(0, 0, diameter, diameter);
    subMenu.layer.cornerRadius = radius;
    return subMenu;
}

// Button to display menu
- (UIButton *)addButton
{
    NSUInteger radius = FBTweakValue(@"view2", @"button", @"size", 30);
    NSUInteger borderWidth = FBTweakValue(@"view2", @"button", @"borderWidth", 2);
    
    if (!_addButton) {
        NSLog(@"creating add button");
        float edgeMultiplier = FBTweakValue(@"view2", @"button", @"edgeMultiplier", 0.5);
        float edgeAmount = radius * edgeMultiplier;
        
        UIImage *addImage = [UIImage imageNamed:@"plus"];
        _addButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _addButton.layer.backgroundColor = [UIColor whiteColor].CGColor;
        _addButton.layer.borderWidth = borderWidth;
        _addButton.layer.borderColor = [UIColor darkGrayColor].CGColor;
        _addButton.layer.cornerRadius = radius;
        _addButton.bounds = CGRectMake(0, 0, radius*2, radius*2);
        _addButton.layer.zPosition = 1.0;
        [_addButton setImage:addImage forState:UIControlStateNormal];
        [_addButton setImageEdgeInsets:UIEdgeInsetsMake(edgeAmount, edgeAmount, edgeAmount, edgeAmount)];
        
        
        return _addButton;
    }
    
    return _addButton;
}

- (void)radialMenuHasOpened
{
    NSLog(@"Radial menu open");
}

- (void)radialMenuHasClosed
{
    for (BJRadialSubMenu *subMenu in self.radialMenu.subMenus) {
        [self resetLayer:subMenu.layer];
    }
}

- (void)resetLayer:(CALayer *)layer
{
    layer.spring.scaleXY = CGPointMake(1.0, 1.0);
    layer.backgroundColor = [UIColor randomFlatDarkColor].CGColor;
}

- (void)radialSubMenuHasSelected:(BJRadialSubMenu *)subMenu
{
    NSLog(@"Selected subMenu = %@", [self.radialSubMenus objectAtIndex:subMenu.tag]);
}

- (void)radialSubMenuHasHighlighted:(BJRadialSubMenu *)subMenu
{
    NSLog(@"Highlighting");
    
    CGFloat scale = FBTweakValue(@"menu2", @"submenu", @"scale", 2.5, 0, 10);
    subMenu.layer.spring.scaleXY = CGPointMake(scale, scale);
}

- (void)radialSubMenuHasUnhighlighted:(BJRadialSubMenu *)subMenu
{
    NSLog(@"Unhighlighting");
    [self resetLayer:subMenu.layer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
