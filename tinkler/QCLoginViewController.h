//
//  QCLoginViewController.h
//  qrcar
//
//  Created by Miguel Quintas on 06/03/14.
//  Copyright (c) 2014 Miguel Quintas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "QCApi.h"

@interface QCLoginViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITextField* email;
@property(nonatomic, strong) IBOutlet UITextField* password;

@property (strong, nonatomic) NSString* registeredEmail;

- (IBAction)loginButtonClicked:(id)sender;
- (IBAction)forgotPasswordButton:(id)sender;

@end
