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
        
        //Verify if user as seen tutorial through user preferences
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        long hasSeenTut = [defaults integerForKey:@"hasSeenTut"];
        
        if(hasSeenTut == 0){
            NSLog(@"hasSeenTut value %ld", hasSeenTut);
           [self customPushVC:@"TutorialViewController"];
            
        }else{
            [self customPushVC:@"TabViewController"];
        }
    }
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    //Set BG color
    [self.view setBackgroundColor:[QCApi colorWithHexString:@"73CACD"]];
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)customPushVC:(NSString *) identifier {
    UIStoryboard *storyBoard = self.storyboard;
    UIViewController *targetViewController = [storyBoard instantiateViewControllerWithIdentifier:identifier];
    UINavigationController *navController = self.navigationController;
    
    if (navController) {
        [navController pushViewController:targetViewController animated:NO];
    }
}

@end
