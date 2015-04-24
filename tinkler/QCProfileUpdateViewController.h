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

@interface QCProfileUpdateViewController :UIViewController<UIActionSheetDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *profilePic;

@property (strong, nonatomic) IBOutlet UITextField *userNameEdit;

@property (weak, nonatomic) IBOutlet UIButton *tutorialButton;
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;
@property (weak, nonatomic) IBOutlet UIButton *resetPassButton;
@property (strong, nonatomic) IBOutlet UIView *line1;
@property (strong, nonatomic) IBOutlet UIView *line2;
@property (strong, nonatomic) IBOutlet UIView *line3;

- (IBAction)changePasswordButton:(id)sender;

//Menu to select photo source
@property (strong, nonatomic) UIActionSheet *photoSourceMenu;

@property (strong, nonatomic) IBOutlet UISwitch *customMsgSwitch;

- (IBAction)selectPhoto:(id)sender;
- (IBAction)logoutButton:(id)sender;
- (IBAction)goToTutorial:(id)sender;

@end
