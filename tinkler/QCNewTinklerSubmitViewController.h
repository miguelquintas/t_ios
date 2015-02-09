//
//  QCNewTinklerSubmitViewController.h
//  qrcar
//
//  Created by Diogo Guimarães on 11/01/15.
//  Copyright (c) 2015 Miguel Quintas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QCTinkler.h"
#import "QCTinklerType.h"
#import "QCProfileViewController.h"
#import "QCApi.h"
#import "LTHMonthYearPickerView.h"

@interface QCNewTinklerSubmitViewController : UIViewController <LTHMonthYearPickerViewDelegate>

@property (strong, nonatomic) IBOutlet UILabel *tinklerNameLabel;

@property (strong, nonatomic) IBOutlet UIImageView *tinklerImage;
@property (strong, nonatomic) IBOutlet UILabel *tinklerTypeLabel;

//New Tinkler Name
@property (strong, nonatomic) NSString *tinklerName;

//Selected Tinkler Type
@property (strong, nonatomic) PFObject *tinklerType;

//Menu to select photo source
@property (strong, nonatomic) UIActionSheet *photoSourceMenu;

//Date Picker
@property (nonatomic, strong) LTHMonthYearPickerView *monthYearPicker;

//Selected new photo flag
@property (nonatomic) BOOL hasNewPhoto;

//Tinkler's additional fields UITextFields
@property (strong, nonatomic) IBOutlet UITextField * vehiclePlateTF;
@property (strong, nonatomic) IBOutlet UITextField * vehicleYearTF;
@property (strong, nonatomic) IBOutlet UITextField * petBreedTF;
@property (strong, nonatomic) IBOutlet UITextField * petAgeTF;
@property (strong, nonatomic) IBOutlet UITextField * brandTF;
@property (strong, nonatomic) IBOutlet UITextField * colorTF;

- (QCTinkler*)saveNewTinkler;

- (IBAction)addNewTinkler:(id)sender;
- (IBAction)selectPhoto:(id)sender;

@end
