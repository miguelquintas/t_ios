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
    NSLog(@"Current User %@",[PFUser currentUser]);
    NSLog(@"Email Verified User %i",[[[PFUser currentUser] objectForKey:@"emailVerified"] boolValue]);
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
    }else{
        [self.email setText:_registeredEmail];
    }
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
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
    
    
    //Set BG color
    [_loginView setBackgroundColor:[QCApi colorWithHexString:@"00CEBA"]];
    
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
    [_registerButton setBackgroundColor:[QCApi colorWithHexString:@"EE463E"]];
    [_registerButton.layer setCornerRadius: 4.0f];
    
    [_loginButton setBackgroundColor:[QCApi colorWithHexString:@"EE463E"]];
    [_loginButton.layer setCornerRadius: 4.0f];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//Code to hide keyboard when return key is pressed
-(BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    [_email resignFirstResponder];
    [_password resignFirstResponder];
    return YES;
}

//Code to hide the keyboard when touching any area outside it
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [_email endEditing:YES];
    [_password endEditing:YES];
}
- (void)customPushVC:(NSString *) identifier {
    UIStoryboard *storyBoard = self.storyboard;
    UIViewController *targetViewController = [storyBoard instantiateViewControllerWithIdentifier:identifier];
    UINavigationController *navController = self.navigationController;
    
    if (navController) {
        [navController pushViewController:targetViewController animated:NO];
    }
}


- (IBAction)loginButtonClicked:(id)sender {
    //Check that user has been verified by email
    [QCApi checkEmailVerifiedWithCompletion:_email.text completion:^void(BOOL finished, BOOL isVerified) {
        if (finished) {
            if(isVerified){
                [PFUser logInWithUsernameInBackground:_email.text password:_password.text block:^(PFUser *user, NSError *error) {
                    if (!error) {
                        NSLog(@"User Logged In!");
                        _email.text = nil;
                        _password.text = nil;
                        
                        // Associate the device with the current logged in user
                        PFInstallation *installation = [PFInstallation currentInstallation];
                        installation[@"user"] = [PFUser currentUser];
                        [installation saveInBackground];
                        
                        //Verify if user as seen tutorial through user preferences
                        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                        bool hasSeenTut = [defaults boolForKey:@"hasSeenTut"];
                        
                        if(hasSeenTut){
                            [self performSegueWithIdentifier:@"SucessLogin" sender:self];
                        }else{
                            UIStoryboard *storyBoard = self.storyboard;
                            UIViewController *targetViewController = [storyBoard instantiateViewControllerWithIdentifier:@"TutorialViewController"];
                            UINavigationController *navController = self.navigationController;
                            
                            if (navController) {
                                [navController pushViewController:targetViewController animated:NO];
                            }
                        }
                        
                    }else{
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Login Failed" message:@"Please insert correct email and password" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                        [alertView show];
                    }
                }];
            }else{
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Login Failed" message:@"Please verify your email to login" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                [alertView show];
            }
        }
    }];
}

- (IBAction)forgotPasswordButton:(id)sender {
    if([self.email.text isEqualToString:@""]){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Password Reset Failed" message:@"Please fill in the email text box" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alertView show];
    }else{
        [PFUser requestPasswordResetForEmailInBackground:self.email.text block:^(BOOL succeeded, NSError *error) {
            if (!error) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Password Reset Done!" message:@"Please check your email and follow the instructions to reset your password" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                [alertView show];
            }else{
                // Log details of the failure
                NSLog(@"Error: %@", error);
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Password Reset Failed!" message:@"Please spell check your email or verify your network connectivity" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                [alertView show];
            }
        }];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"toRegister"]) {
        QCRegisterViewController *destViewController = segue.destinationViewController;
        [destViewController setParentVC:self];
    }
}

@end
