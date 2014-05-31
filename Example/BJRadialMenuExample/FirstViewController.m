//
//  FirstViewController.m
//  BJRadialMenuExample
//
//  Created by Brad Jasper on 5/31/14.
//  Copyright (c) 2014 Brad Jasper. All rights reserved.
//

#import "FirstViewController.h"

// helpful but not required for BJRadialMenu
#import <Tweaks/FBTweakInline.h>
#import "POP+MCAnimate.h"

@interface FirstViewController ()

@property (nonatomic) NSArray *menuItems;
@property (nonatomic) UIButton *addButton;
@property (nonatomic) BJRadialMenu *radialMenu;

@end

@implementation FirstViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setup];
}

- (void)setup
{
    // Setup the menu with numbers
    self.radialMenu = [[BJRadialMenu alloc] initWithText:self.menuItems];
    self.radialMenu.delegate = self;
    
    // All of these are configurable by shaking the device
    FBTweakBind(self.radialMenu, minAngle, @"menu", @"angle", @"min", 180);
    FBTweakBind(self.radialMenu, maxAngle, @"menu", @"angle", @"max", 360);
    FBTweakBind(self.radialMenu, openDelayStep, @"menu", @"open", @"delayStep", 0.055);
    FBTweakBind(self.radialMenu, closeDelayStep, @"menu", @"close", @"delayStep", 0.045);
    FBTweakBind(self.radialMenu, selectedDelay, @"menu", @"selected", @"delay", 1.0);
    FBTweakBind(self.radialMenu, radius, @"menu", @"submenu", @"radius", 100);
    
    // Create long-press gesture and assign to button
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(pressedAddButton:)];
    FBTweakBind(longPress, minimumPressDuration, @"view", @"button", @"pressDuration", 0.4);

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

- (NSArray *)menuItems
{
    NSUInteger numMenuItems = FBTweakValue(@"menu", @"submenu", @"count", 4);
    
    NSMutableArray *items = [[NSMutableArray alloc] init];
    for (int i = 1; i <= numMenuItems; i++)
    {
        [items addObject:[NSString stringWithFormat:@"%@", @(i)]];
    }
    
    return items;
}

// Button to display menu
- (UIButton *)addButton
{
    NSUInteger radius = FBTweakValue(@"view", @"button", @"radius", 30);
    NSUInteger borderWidth = FBTweakValue(@"view", @"button", @"borderWidth", 2);
    
    if (!_addButton) {
        NSLog(@"creating add button");
        float edgeMultiplier = FBTweakValue(@"view", @"button", @"edgeMultiplier", 0.5);
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

- (void)radialSubMenuHasSelected:(BJRadialSubMenu *)subMenu
{
    NSLog(@"Selected subMenu = %@", [self.menuItems objectAtIndex:subMenu.tag]);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
