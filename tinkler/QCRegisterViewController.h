//
//  QCRegisterViewController.h
//  qrcar
//
//  Created by Miguel Quintas on 06/03/14.
//  Copyright (c) 2014 Miguel Quintas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "QCApi.h"
#import "QCLoginViewController.h"
#import "MBProgressHUD.h"

@interface QCRegisterViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITextField *name;
@property(nonatomic, strong) IBOutlet UITextField *email;
@property(nonatomic, strong) IBOutlet UITextField *password;
@property (strong, nonatomic) IBOutlet UITextField *confirmPassword;

- (IBAction)registerButtonClicked:(id)sender;

@end
