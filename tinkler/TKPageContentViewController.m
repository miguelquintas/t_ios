//
//  TKPageContentViewController.m
//  Tinkler
//
//  Created by Miguel Quintas on 03/03/15.
//  Copyright (c) 2015 Tinkler. All rights reserved.
//

#import "TKPageContentViewController.h"

@interface TKPageContentViewController ()

@end

@implementation TKPageContentViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.backgroundImageView.image = [UIImage imageNamed:self.imageFile];
    self.finishButton.hidden = self.buttonHidden;
    self.imageDescription.text = self.descriptionText;
}

- (IBAction)goToScanPage {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:YES forKey:@"hasSeenTut"];
    [defaults synchronize];
    
    UIStoryboard *storyBoard = self.storyboard;
    UIViewController *targetViewController = [storyBoard instantiateViewControllerWithIdentifier:@"TabViewController"];
    UINavigationController *navController = self.navigationController;
    
    if (navController) {
        //Code to show the navigation bar
        [[self navigationController] setNavigationBarHidden:NO animated:NO];
        [navController pushViewController:targetViewController animated:YES];
    }
}

@end