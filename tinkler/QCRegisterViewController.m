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

- (void) viewDidLoad{
    [super viewDidLoad];
    [self.view setBackgroundColor:[QCApi colorWithHexString:@"00CEBA"]];
    [_registerButton setBackgroundColor:[QCApi colorWithHexString:@"EE463E"]];
    [_registerButton.layer setCornerRadius: 4.0f];
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc]init] forBarMetrics:UIBarMetricsDefault];
}


- (void) viewWillAppear:(BOOL)animated{
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
    //Loading spinner
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                NSLog(@"User was registered successfully!");
                
                //Code to set name, bans, customMsg and installation details to the new registered user
                [PFCloud callFunctionInBackground:@"postRegisterActions"
                                   withParameters:@{}
                                        block:^(NSString *success, NSError *error) {
                                            if (!error) {
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                                                });
                                                //Set name to NSUserDefaults preferences
                                                // Create instances of NSData
                                                NSString *name =_name.text;
                                                // Store the data
                                                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                                                [defaults setObject:name forKey:@"name"];
                                                
                                                [defaults synchronize];
                                                NSLog(@"Data saved");
                                                
                                                // Present the Home view controller
                                                [(TKHomeViewController*)_parentVC setRegisteredEmail:_email.text];
                                                // Push sent successfully
                                                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Registration Success" message:@"Please check your email to validate your user then and log in" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                                                [alertView show];
                                                
                                            }else{
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                                                });
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
        
    });
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0 && [alertView.title isEqualToString:@"Registration Success"] ){
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

- (IBAction)registerButtonClicked:(id)sender{
    [_name resignFirstResponder];
    [_password resignFirstResponder];
    [_confirmPassword resignFirstResponder];
    [_email resignFirstResponder];
    [self checkFields];
}


@end
