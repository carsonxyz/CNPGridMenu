//
//  ViewController.m
//  CNPGridMenu
//
//  Created by Carson Perrotti on 2014-10-18.
//  Copyright (c) 2014 Carson Perrotti. All rights reserved.
//

#import "ViewController.h"
#import "CNPGridMenu.h"

@interface ViewController () <CNPGridMenuDelegate>

@property (nonatomic, strong) CNPGridMenu *gridMenu;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.showGridButton.layer.cornerRadius = 4;
}

- (IBAction)showGridMenu:(id)sender {
    
    CNPGridMenuItem *laterToday = [[CNPGridMenuItem alloc] init];
    laterToday.icon = [UIImage imageNamed:@"LaterToday"];
    laterToday.title = @"Later Today";
    
    CNPGridMenuItem *thisEvening = [[CNPGridMenuItem alloc] init];
    thisEvening.icon = [UIImage imageNamed:@"ThisEvening"];
    thisEvening.title = @"This Evening";
    
    CNPGridMenuItem *tomorrow = [[CNPGridMenuItem alloc] init];
    tomorrow.icon = [UIImage imageNamed:@"Tomorrow"];
    tomorrow.title = @"Tomorrow";
    
    CNPGridMenuItem *thisWeekend = [[CNPGridMenuItem alloc] init];
    thisWeekend.icon = [UIImage imageNamed:@"ThisWeekend"];
    thisWeekend.title = @"This Weekend";
    
    CNPGridMenuItem *nextWeek = [[CNPGridMenuItem alloc] init];
    nextWeek.icon = [UIImage imageNamed:@"NextWeek"];
    nextWeek.title = @"Next Week";
    
    CNPGridMenuItem *inAMonth = [[CNPGridMenuItem alloc] init];
    inAMonth.icon = [UIImage imageNamed:@"InMonth"];
    inAMonth.title = @"In A Month";
    
    CNPGridMenuItem *someday = [[CNPGridMenuItem alloc] init];
    someday.icon = [UIImage imageNamed:@"Someday"];
    someday.title = @"Someday";
    
    CNPGridMenuItem *desktop = [[CNPGridMenuItem alloc] init];
    desktop.icon = [UIImage imageNamed:@"Desktop"];
    desktop.title = @"Desktop";
    
    CNPGridMenuItem *pickDate = [[CNPGridMenuItem alloc] init];
    pickDate.icon = [UIImage imageNamed:@"PickDate"];
    pickDate.title = @"Pick Date";
    
    CNPGridMenu *gridMenu = [[CNPGridMenu alloc] initWithMenuItems:@[laterToday, thisEvening, tomorrow, thisWeekend, nextWeek, inAMonth, someday, desktop, pickDate]];
    gridMenu.delegate = self;
    [self presentGridMenu:gridMenu animated:YES completion:^{
        NSLog(@"Grid Menu Presented");
    }];
}

- (void)gridMenuDidTapOnBackground:(CNPGridMenu *)menu {
    [self dismissGridMenuAnimated:YES completion:^{
        NSLog(@"Grid Menu Dismissed With Background Tap");
    }];
}

- (void)gridMenu:(CNPGridMenu *)menu didTapOnItem:(CNPGridMenuItem *)item {
    [self dismissGridMenuAnimated:YES completion:^{
        NSLog(@"Grid Menu Did Tap On Item: %@", item.title);
    }];
}

@end
