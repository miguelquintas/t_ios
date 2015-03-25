//
//  QCProfileUpdateViewController.h
//  qrcar
//
//  Created by Diogo Guimarães on 06/10/14.
//  Copyright (c) 2014 Miguel Quintas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "QCApi.h"

@interface QCProfileUpdateViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITextField *userNameEdit;

- (IBAction)changePasswordButton:(id)sender;

@property (strong, nonatomic) IBOutlet UISwitch *customMsgSwitch;
- (IBAction)logoutButton:(id)sender;

@end
