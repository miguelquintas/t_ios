//
//  QCNewTinklerViewController.h
//  qrcar
//
//  Created by Diogo Guimarães on 03/01/15.
//  Copyright (c) 2015 Miguel Quintas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QCTinkler.h"
#import "QCTinklerType.h"
#import "QCApi.h"
#import "QCNewTinklerSubmitViewController.h"
#import "SBPickerSelector.h"

@interface QCNewTinklerViewController : UIViewController <UIActionSheetDelegate, SBPickerSelectorDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) IBOutlet UITextField *tinklerName;
@property (strong, nonatomic) IBOutlet UIButton *tinklerType;
@property (weak, nonatomic) IBOutlet UIButton *nextButtonOutlet;
@property (weak, nonatomic) IBOutlet UIImageView *tinklerImage;
@property (weak, nonatomic) IBOutlet UITextField *tinklerTypeTF;

//Array with the existing tinkler types objects
@property (strong, nonatomic) NSArray *tinklerTypes;

//Selected new photo flag
@property (nonatomic) BOOL hasNewPhoto;

//Menu to select photo source
@property (strong, nonatomic) UIActionSheet *photoSourceMenu;

//Array with the existing tinkler types names
@property (strong, nonatomic) NSMutableArray *tinklerTypeNames;
- (IBAction)nextButton:(id)sender;
- (IBAction)tinklerImagePicker:(id)sender;


@end
