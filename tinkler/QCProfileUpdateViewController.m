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
    
    self.title = @"Settings";
    
    self.profilePic.layer.cornerRadius = self.profilePic.frame.size.width / 2;
    self.profilePic.clipsToBounds = YES;
    
    // Get the stored data before the view loads
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *imageData = [defaults dataForKey:@"profilePic"];
    UIImage *storedProfilePic = [UIImage imageWithData:imageData];
    
    //Set profile pic from NSUserDefaults
    if(imageData == nil){
        //Load the default profile pic
        self.profilePic.image = [UIImage imageNamed:@"default_pic.png"];
    }else{
        self.profilePic.image = storedProfilePic;
    }
    
    [self.userNameEdit setText:[defaults stringForKey:@"name"]];
    
    //Set the user's switch value
    if ([[PFUser currentUser] objectForKey:@"allowCustomMsg"] == [NSNumber numberWithBool:YES])
        [self.customMsgSwitch setOn:YES];
    else
        [self.customMsgSwitch setOn:NO];
    
    //Edit the buttons style
    [_tutorialButton setBackgroundColor:[QCApi colorWithHexString:@"00CEBA"]];
    [_tutorialButton.layer setBorderWidth:1.0];
    [_tutorialButton.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    [_tutorialButton.layer setCornerRadius: 6.0f];
    
    [_logoutButton setBackgroundColor:[QCApi colorWithHexString:@"EE463E"]];
    [_logoutButton.layer setBorderWidth:1.0];
    [_logoutButton.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    [_logoutButton.layer setCornerRadius: 6.0f];
    
    [_resetPassButton setBackgroundColor:[QCApi colorWithHexString:@"EE463E"]];
    [_resetPassButton.layer setBorderWidth:1.0];
    [_resetPassButton.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    [_resetPassButton.layer setCornerRadius: 6.0f];
    
}

-(void) viewWillDisappear:(BOOL)animated {
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        //Set name to NSUserDefaults preferences
        NSString *name =_userNameEdit.text;
        // Store the data
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:name forKey:@"name"];
        
        [defaults synchronize];
        
        [QCApi editProfileSaveWithCompletion:_customMsgSwitch.isOn completion:^void(BOOL finished) {
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

//Delegate methods for imagePicker
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    self.profilePic.image = chosenImage;
    
    //Set image to NSUserDefaults preferences
    // Create instances of NSData
    NSData *imageData = UIImageJPEGRepresentation(chosenImage, 100);
    // Store the data
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:imageData forKey:@"profilePic"];
    
    [defaults synchronize];
    NSLog(@"Data saved");
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSLog(@"Button %ld", (long)buttonIndex);
    if(buttonIndex == 0){
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        [self presentViewController:picker animated:YES completion:NULL];
    }else if (buttonIndex == 1){
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        [self presentViewController:picker animated:YES completion:NULL];
    }
}

- (IBAction)selectPhoto:(id)sender {
    _photoSourceMenu = [[UIActionSheet alloc] initWithTitle:@"Select the picture's source"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                     destructiveButtonTitle:nil
                                          otherButtonTitles:@"Camera", @"Photo Library", nil];
    
    // Show the sheet
    [_photoSourceMenu showInView:self.view];
}

- (IBAction)logoutButton:(id)sender {
    [PFUser logOut];
    
    // Present the home view controller
    [self.navigationController popToViewController:[[self.navigationController viewControllers] objectAtIndex:0] animated:YES];
}

- (IBAction)goToTutorial:(id)sender {
}

@end
