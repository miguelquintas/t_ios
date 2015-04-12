//
//  QCTinklerDetailViewController.h
//  qrcar
//
//  Created by Diogo Guimarães on 09/01/15.
//  Copyright (c) 2015 Miguel Quintas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QCTinkler.h"
#import "QCApi.h"
#import "QCQrCode.h"
#import "UIImageView+AFNetworking.h"
#import "LTHMonthYearPickerView.h"
#import "SBPickerSelector.h"
#import "MBProgressHUD.h"

@interface QCTinklerDetailViewController : UIViewController <LTHMonthYearPickerViewDelegate, UIActionSheetDelegate, SBPickerSelectorDelegate, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *aditionalFieldsView;
@property (strong, nonatomic) IBOutlet UITextField * tinklerNameEdit;
@property (strong, nonatomic) IBOutlet UIButton * tinklerTypeEdit;
@property (weak, nonatomic) IBOutlet UITextField *tinklerTypeTF;

@property (strong, nonatomic) IBOutlet UIImageView * tinklerImage;
@property (strong, nonatomic) IBOutlet UIImageView *qrCodeImage;

//Array with the existing tinkler types objects
@property (strong, nonatomic) NSArray *tinklerTypes;

//Array with the existing tinkler types names
@property (strong, nonatomic) NSMutableArray *tinklerTypeNames;

//Date Picker
@property (nonatomic, strong) LTHMonthYearPickerView *monthYearPicker;

//Menu to select photo source
@property (strong, nonatomic) UIActionSheet *photoSourceMenu;

//Selected new photo flag
@property (nonatomic) BOOL hasNewPhoto;

//Tinkler's additional fields UITextFields
@property (strong, nonatomic) IBOutlet UITextField * vehiclePlateTF;
@property (strong, nonatomic) IBOutlet UITextField * vehicleYearTF;
@property (strong, nonatomic) IBOutlet UITextField * petBreedTF;
@property (strong, nonatomic) IBOutlet UITextField * petAgeTF;
@property (strong, nonatomic) IBOutlet UITextField * brandTF;
@property (strong, nonatomic) IBOutlet UITextField * colorTF;

//Variables to pass information
@property (nonatomic, strong) QCTinkler *selectedTinkler;

@property (weak, nonatomic) IBOutlet UIButton *regenerateButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UIButton *updateButton;


-(void)editTinkler;
- (IBAction)generateQRCode:(id)sender;
- (IBAction)selectPhoto:(id)sender;
- (IBAction)deleteTinkler:(id)sender;
- (IBAction)updateTinkler:(id)sender;

@end
