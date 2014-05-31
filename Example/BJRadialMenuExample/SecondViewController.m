//
//  SecondViewController.m
//  BJRadialMenuExample
//
//  Created by Brad Jasper on 5/31/14.
//  Copyright (c) 2014 Brad Jasper. All rights reserved.
//

#import "SecondViewController.h"

// helpful but not required for BJRadialMenu
#import <Tweaks/FBTweakInline.h>
#import "POP+MCAnimate.h"

@interface SecondViewController ()

@property (nonatomic) NSArray *radialSubLayers;
@property (nonatomic) UIButton *addButton;
@property (nonatomic) BJRadialMenu *radialMenu;

@end

@implementation SecondViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setup];
}

- (void)setup
{
    // Setup the menu with numbers
    self.radialMenu = [[BJRadialMenu alloc] initWithLayers:self.radialSubLayers];
    self.radialMenu.delegate = self;
    
    // All of these are configurable by shaking the device
    FBTweakBind(self.radialMenu, minAngle, @"menu2", @"angle", @"min", 180);
    FBTweakBind(self.radialMenu, maxAngle, @"menu2", @"angle", @"max", 540);
    FBTweakBind(self.radialMenu, openDelayStep, @"menu2", @"open", @"delayStep", 0.055);
    FBTweakBind(self.radialMenu, closeDelayStep, @"menu2", @"close", @"delayStep", 0.045);
    FBTweakBind(self.radialMenu, selectedDelay, @"menu2", @"selected", @"delay", 1.0);
    FBTweakBind(self.radialMenu, radius, @"menu2", @"submenu", @"radius", 100);
    
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

- (NSArray *)radialSubLayers
{
    if (_radialSubLayers == nil) {
        NSUInteger numMenuItems = FBTweakValue(@"menu2", @"submenu", @"count", 4);
        
        NSMutableArray *items = [[NSMutableArray alloc] init];
        for (int i = 1; i <= numMenuItems; i++)
        {
            CALayer *circle = [CALayer layer];
            circle.backgroundColor = [UIColor redColor].CGColor;
            circle.frame = CGRectMake(0, 0, 100, 100);
            circle.cornerRadius = 50;
            [items addObject:circle];
        }
        
        _radialSubLayers = items;
    }
        
    return _radialSubLayers;
}

// Button to display menu
- (UIButton *)addButton
{
    NSUInteger radius = FBTweakValue(@"view1", @"button", @"radius", 30);
    NSUInteger borderWidth = FBTweakValue(@"view1", @"button", @"borderWidth", 2);
    
    if (!_addButton) {
        NSLog(@"creating add button");
        float edgeMultiplier = FBTweakValue(@"view1", @"button", @"edgeMultiplier", 0.5);
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
    NSLog(@"Radial menu closed");
}

- (void)radialSubMenuHasSelected:(BJRadialSubMenu *)subMenu
{
    NSLog(@"Selected subMenu = %@", [self.radialSubLayers objectAtIndex:subMenu.tag]);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
