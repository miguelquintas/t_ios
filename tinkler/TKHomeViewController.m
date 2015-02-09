//
//  TKHomeViewController.m
//  Tinkler
//
//  Created by Diogo Guimarães on 25/01/15.
//  Copyright (c) 2015 Tinkler. All rights reserved.
//

#import "TKHomeViewController.h"

@interface TKHomeViewController ()

@end

@implementation TKHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //validate viewController one being displayed
    if([PFUser currentUser].username != nil && [[[PFUser currentUser] objectForKey:@"emailVerified"] boolValue]){
        
        UIStoryboard *storyBoard = self.storyboard;
        UIViewController *targetViewController = [storyBoard instantiateViewControllerWithIdentifier:@"TabViewController"];
        UINavigationController *navController = self.navigationController;
        
        if (navController) {
            //Code to hide the back button in the following tabs of the Tab View Controller
            targetViewController.navigationItem.hidesBackButton = YES;
            [navController pushViewController:targetViewController animated:NO];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
