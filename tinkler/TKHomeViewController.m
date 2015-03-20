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
        bool hasSeenTut = [defaults boolForKey:@"hasSeenTut"];
        
        if(hasSeenTut) {
            [self customPushVC:@"TabViewController"];
        } else {
            [self performSegueWithIdentifier:@"seeTutorialFromHome" sender:self];
        }
    }
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    //Set BG color

    [[self navigationController] setNavigationBarHidden:YES animated:NO];
    [_registerButton.layer setBorderWidth:1.0];
    [_registerButton.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    [_registerButton.layer setCornerRadius: 4.0f];

    [_loginButton setBackgroundColor:[UIColor whiteColor]];
    [_loginButton.layer setBorderWidth:1.0];
    [_loginButton.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    [_loginButton.layer setCornerRadius: 4.0f];
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        if ([[UIScreen mainScreen] respondsToSelector: @selector(scale)]) {
            CGSize result = [[UIScreen mainScreen] bounds].size;
            CGFloat scale = [UIScreen mainScreen].scale;
            result = CGSizeMake(result.width * scale, result.height * scale);
            
            if(result.height == 960) {
                NSLog(@"iPhone 4 Resolution");
                self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"splash_4.png"]];
            }
            if(result.height == 1136) {
                NSLog(@"iPhone 5 Resolution");
                self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"splash_5.png"]];
            }
            if(result.height == 1334) {
                NSLog(@"iPhone 6 Resolution");
                self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"splash_6.png"]];
                NSLog(@"%f", self.view.frame.size.width);
                NSLog(@"%f", self.view.frame.size.height);
            }
            if(result.height == 2208) {
                NSLog(@"iPhone 6 Plus Resolution");
                self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"splash_6+.png"]];
            }
        }else{
            NSLog(@"Standard Resolution");
            self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"splash_4.png"]];
        }
    }
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
