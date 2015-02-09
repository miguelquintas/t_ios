//
//  QCRegisterViewController.m
//  qrcar
//
//  Created by Miguel Quintas on 06/03/14.
//  Copyright (c) 2014 Miguel Quintas. All rights reserved.
//

#import "QCRegisterViewController.h"

@interface QCRegisterViewController ()

@end

@implementation QCRegisterViewController

@synthesize name = _name;
@synthesize password = _password;
@synthesize confirmPassword = _confirmPassword;
@synthesize email = _email;

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
}

//Code to hide keyboard when return key is pressed
-(IBAction)textFieldReturn:(id)sender{
    [sender resignFirstResponder];
}

//Code to hide the keyboard when touching any area outside it
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [_name endEditing:YES];
    [_email endEditing:YES];
    [_confirmPassword endEditing:YES];
    [_password endEditing:YES];
}

- (void) checkFields{
    if ([_name.text isEqualToString:@""] || [_password.text isEqualToString:@""] || [_confirmPassword.text isEqualToString:@""] || [_email.text isEqualToString:@""]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Register Failed" message:@"Please fill in all the fields" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alertView show];
    }else{
        [self checkPassword];
    }
}

- (void) checkPassword {
    if ( ![_password.text isEqualToString:_confirmPassword.text]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Register Failed" message:@"Passwords don't match" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alertView show];
    }else{
        [self registerNewUser];
    }
}

- (void) registerNewUser{
    PFUser *newUser = [PFUser user];
    newUser.username = _email.text;
    newUser.email = _email.text;
    newUser.password = _password.text;
    
    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            NSLog(@"User was registered successfully!");
            
            //Code to set name, bans, customMsg and installation details to the new registered user
            [PFCloud callFunctionInBackground:@"postRegisterActions"
                               withParameters:@{@"newName": _name.text}
                                        block:^(NSString *success, NSError *error) {
                                            if (!error) {
                                                // Push sent successfully
                                                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Registration Success" message:@"Please check your email to validate your user then and log in" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                                                [alertView show];
                                                // Present the log in view controller
                                                [self performSegueWithIdentifier:@"loginAfterRegister" sender:self];
                                                
                                            }else{
                                                NSLog(@"Error while registering!");
                                                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Register Failed" message:@"Error while registering!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                                                [alertView show];
                                            }
                                        }];
                        
        }else{
            NSLog(@"Error while registering!");
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Register Failed" message:@"Error while registering!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alertView show];
        }
    }];
}

- (IBAction)registerButtonClicked:(id)sender{
    [_name resignFirstResponder];
    [_password resignFirstResponder];
    [_confirmPassword resignFirstResponder];
    [_email resignFirstResponder];
    [self checkFields];
}

//Code to pass selected vehicle data to the Vehicle Edit View Controller
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"loginAfterRegister"]) {
        QCLoginViewController *destViewController = segue.destinationViewController;
        destViewController.registeredEmail = _email.text;
    }
}

@end
