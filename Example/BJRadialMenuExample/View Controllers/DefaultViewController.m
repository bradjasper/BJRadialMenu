//
//  FirstViewController.m
//  BJRadialMenuExample
//
//  Created by Brad Jasper on 5/31/14.
//  Copyright (c) 2014 Brad Jasper. All rights reserved.
//

#import "DefaultViewController.h"

// helpful but not required for BJRadialMenu
#import <Tweaks/FBTweakInline.h>
#import "POP+MCAnimate.h"
#import "UIColor+MLPFlatColors.h"

@interface DefaultViewController()

@property (nonatomic) UILabel *infoLabel;
@property (nonatomic) NSArray *menuItems;
@property (nonatomic) UIButton *addButton;
@property (nonatomic) BJRadialMenu *radialMenu;

@end

@implementation DefaultViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setup];
}

- (void)setup
{
    
    self.infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 5, self.view.frame.size.width, 50)];
    self.infoLabel.font = [self.infoLabel.font fontWithSize:8.0];
    [self updateInfoLabel:@"Closed"];
    [self.view addSubview:self.infoLabel];
    
    // Setup the menu with numbers
    self.radialMenu = [[BJRadialMenu alloc] initWithText:self.menuItems];
    self.radialMenu.delegate = self;
    
    // All of these are configurable by shaking the device
    FBTweakBind(self.radialMenu, minAngle, @"defaultView", @"radialMenu", @"minAngle", 180);
    FBTweakBind(self.radialMenu, maxAngle, @"defaultView", @"radialMenu", @"maxAngle", 360);
    FBTweakBind(self.radialMenu, openDelayStep, @"defaultView", @"radialMenu", @"openDelayStep", 0.045);
    FBTweakBind(self.radialMenu, closeDelayStep, @"defaultView", @"radialMenu", @"closeDelayStep", 0.035);
    FBTweakBind(self.radialMenu, selectedDelay, @"defaultView", @"radialMenu", @"selectedDelay", 1.0);
    FBTweakBind(self.radialMenu, radius, @"defaultView", @"radialMenu", @"openRadius", 100);
    FBTweakBind(self.radialMenu, radiusStep, @"defaultView", @"radialMenu", @"radiusStep", 0.0);
    
    // Create long-press gesture and assign to button
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(pressedAddButton:)];
    FBTweakBind(longPress, minimumPressDuration, @"defaultView", @"addButton", @"pressDuration", 0.4);

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
    if (_menuItems == nil)
    {
        NSUInteger numMenuItems = FBTweakValue(@"defaultView", @"radialMenu", @"subMenuCount", 4);
        
        NSMutableArray *items = [NSMutableArray array];
        for (int i = 1; i <= numMenuItems; i++) {
            [items addObject:[NSString stringWithFormat:@"%@", @(i)]];
        }
        
        _menuItems = items;
    }
    
    return _menuItems;
}

// Button to display menu
- (UIButton *)addButton
{
    NSUInteger radius = FBTweakValue(@"defaultView", @"addButton", @"buttonRadius", 30);
    NSUInteger borderWidth = FBTweakValue(@"defaultView", @"addButton", @"borderWidth", 2);
    
    if (!_addButton) {
        NSLog(@"creating add button");
        float edgeMultiplier = FBTweakValue(@"defaultView", @"addButton", @"edgeMultiplier", 0.5);
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

- (void)updateInfoLabel:(NSString *)state
{
    self.infoLabel.text = [NSString stringWithFormat:@"state = %@", state];
}

- (void)radialMenuIsOpening:(BJRadialMenu *)menu
{
    [self updateInfoLabel:@"Opening"];
}

- (void)radialMenuIsClosing:(BJRadialMenu *)menu
{
    [self updateInfoLabel:@"Closing"];
}

- (void)radialMenuHasOpened:(BJRadialMenu *)menu
{
    [self updateInfoLabel:@"Opened"];
}

- (void)radialMenuHasClosed:(BJRadialMenu *)menu
{
    [self updateInfoLabel:@"Closed"];
}

- (void)radialMenuHasHighlighted:(BJRadialMenu *)menu subMenu:(BJRadialSubMenu *)subMenu
{
    NSString *item = self.menuItems[subMenu.tag];
    [self updateInfoLabel:[NSString stringWithFormat:@"Highlighted '%@'", item]];
}

- (void)radialMenuHasUnhighlighted:(BJRadialMenu *)menu subMenu:(BJRadialSubMenu *)subMenu
{
    [self updateInfoLabel:@"Opened"];
}

- (void)radialMenuHasSelected:(BJRadialMenu *)menu subMenu:(BJRadialSubMenu *)subMenu
{
    NSString *item = self.menuItems[subMenu.tag];
    [self updateInfoLabel:[NSString stringWithFormat:@"Selected '%@'", item]];
}

@end
