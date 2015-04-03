//
//  TKHomeViewController.h
//  Tinkler
//
//  Created by Diogo Guimarães on 25/01/15.
//  Copyright (c) 2015 Tinkler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "TKTutorialViewController.h"
#import "QCRegisterViewController.h"

@interface TKHomeViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *loginView;

@property (weak, nonatomic) IBOutlet UITextField *email;
@property (weak, nonatomic) IBOutlet UITextField *password;

@property (strong, nonatomic) NSString* registeredEmail;

- (IBAction)loginButtonClicked:(id)sender;

- (IBAction)forgotPasswordButton:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *registerButton;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@end
