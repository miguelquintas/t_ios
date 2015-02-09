//
//  QCProfileUpdateViewController.m
//  qrcar
//
//  Created by Diogo Guimarães on 06/10/14.
//  Copyright (c) 2014 Miguel Quintas. All rights reserved.
//

#import "QCProfileUpdateViewController.h"

@interface QCProfileUpdateViewController ()

@end

@implementation QCProfileUpdateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[PFUser currentUser] refresh];
    [self.userNameEdit setText:[[PFUser currentUser] objectForKey:@"name"]];
    
    //Set the user's switch value
    if ([[PFUser currentUser] objectForKey:@"allowCustomMsg"] == [NSNumber numberWithBool:YES])
        [self.customMsgSwitch setOn:YES];
    else
        [self.customMsgSwitch setOn:NO];
    
}

-(void) viewWillDisappear:(BOOL)animated {
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        //Code to add the name to the current registered user
        [QCApi editProfileSaveWithCompletion:_userNameEdit.text :_customMsgSwitch.isOn completion:^void(BOOL finished) {
            if (finished) {
                NSLog(@"Updates were saved!");
            }
        }];
        
    }
    [super viewWillDisappear:animated];
}

//Code to hide keyboard when return key is pressed
-(IBAction)textFieldReturn:(id)sender{
    [sender resignFirstResponder];
}

//Code to hide the keyboard when touching any area outside it
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [_userNameEdit endEditing:YES];
}

- (IBAction)changePasswordButton:(id)sender {
    
    [PFUser requestPasswordResetForEmailInBackground:[PFUser currentUser].email block:^(BOOL succeeded, NSError *error) {
        if (!error) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Password Reset Done!" message:@"Please check your email and follow the instructions to reset your password" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alertView show];
        }else{
            // Log details of the failure
            NSLog(@"Error: %@", error);
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Password Reset Failed!" message:@"Please verify your network connectivity" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alertView show];
        }
    }];
    

}


@end
