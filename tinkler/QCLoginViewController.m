//
//  QCLoginViewController.m
//  qrcar
//
//  Created by Miguel Quintas on 06/03/14.
//  Copyright (c) 2014 Miguel Quintas. All rights reserved.
//

#import "QCLoginViewController.h"
#import "QCTabViewController.h"

@interface QCLoginViewController ()
@end

@implementation QCLoginViewController

@synthesize email = _email;
@synthesize password = _password;

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    if([PFUser currentUser].username != nil && [[[PFUser currentUser] objectForKey:@"emailVerified"] boolValue]){
        [self performSegueWithIdentifier:@"SucessLogin" sender:self];
    }else{
        [self.email setText:_registeredEmail];
    }
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

- (IBAction)loginButtonClicked:(id)sender{
    
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

@end
