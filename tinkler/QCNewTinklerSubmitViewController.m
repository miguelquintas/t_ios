//
//  QCNewTinklerSubmitViewController.m
//  qrcar
//
//  Created by Diogo Guimarães on 11/01/15.
//  Copyright (c) 2015 Miguel Quintas. All rights reserved.
//

#import "QCNewTinklerSubmitViewController.h"

@interface QCNewTinklerSubmitViewController ()

@end

@implementation QCNewTinklerSubmitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Load the default pic
    [self.tinklerImage setImage:_selectedImage];
    
    self.tinklerImage.layer.cornerRadius = self.tinklerImage.frame.size.width / 2;
    self.tinklerImage.clipsToBounds = YES;
    self.tinklerImage.layer.borderColor=[[QCApi colorWithHexString:@"00CEBA"]CGColor];
    self.tinklerImage.layer.borderWidth= 1.0f;
    
    //Set the tinkler name and type to the respective labels
    self.title = _tinklerName;
    
    NSString *tinklerTypeName =[_tinklerType objectForKey:@"typeName"];
    [self.tinklerTypeLabel setText:tinklerTypeName];
    
    //Edit the buttons style
    [_submitButton setBackgroundColor:[QCApi colorWithHexString:@"EE463E"]];
    [_submitButton.layer setBorderWidth:1.0];
    [_submitButton.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    [_submitButton.layer setCornerRadius: 6.0f];
    
    //Display the optional fields for each tinkler type
    if ([tinklerTypeName isEqualToString:@"Vehicle"]) {
        [self createVehicleAdditionalFields];
    }else if ([tinklerTypeName isEqualToString:@"Pet"]){
        [self createPetAdditionalFields];
    }else if ([tinklerTypeName isEqualToString:@"Realty or Location"] || [tinklerTypeName isEqualToString:@"Key"]){
        [self createLocationAdditionalFields];
    }else if ([tinklerTypeName isEqualToString:@"Object"] || [tinklerTypeName isEqualToString:@"Bag or Suitcase"]){
        [self createBagsAcessoriesAdditionalFields];
    }else if ([tinklerTypeName isEqualToString:@"Advertisement"]){
        [self createAdAdditionalFields];
    }
}

- (void) createBagsAcessoriesAdditionalFields{
    _brandTF = [[UITextField alloc] init];
    _brandTF.font = [UIFont fontWithName:@"Helvetica" size:14];
    _brandTF.layer.cornerRadius=4.0f;
    _brandTF.layer.masksToBounds=YES;
    _brandTF.layer.borderColor=[[QCApi colorWithHexString:@"00CEBA"]CGColor];
    _brandTF.layer.borderWidth= 1.0f;
    _brandTF.frame = CGRectMake(0.0f, 30.0f, 250.0f, 40.0f);
    _brandTF.delegate = self;
    _brandTF.borderStyle = UITextBorderStyleRoundedRect;
    _brandTF.placeholder = @"Brand";
    _brandTF.userInteractionEnabled = YES;
    
    _colorTF = [[UITextField alloc] init];
    _colorTF.font = [UIFont fontWithName:@"Helvetica" size:14];
    _colorTF.layer.cornerRadius=4.0f;
    _colorTF.layer.masksToBounds=YES;
    _colorTF.layer.borderColor=[[QCApi colorWithHexString:@"00CEBA"]CGColor];
    _colorTF.layer.borderWidth= 1.0f;
    _colorTF.frame = CGRectMake(0.0f, _brandTF.frame.origin.y+45, 250.0f, 40.0f);
    _colorTF.delegate = self;
    _colorTF.borderStyle = UITextBorderStyleRoundedRect;
    _colorTF.placeholder = @"Color";
    _colorTF.userInteractionEnabled = YES;
    
    [_additionalFields addSubview:_brandTF];
    [_additionalFields addSubview:_colorTF];
    [self.view addSubview:_additionalFields];
}

- (void) createPetAdditionalFields{
    _petBreedTF = [[UITextField alloc] init];
    _petBreedTF.font = [UIFont fontWithName:@"Helvetica" size:14];
    _petBreedTF.layer.cornerRadius=4.0f;
    _petBreedTF.layer.masksToBounds=YES;
    _petBreedTF.layer.borderColor=[[QCApi colorWithHexString:@"00CEBA"]CGColor];
    _petBreedTF.layer.borderWidth= 1.0f;
    _petBreedTF.frame = CGRectMake(0.0f, 30.0f, 250.0f, 40.0f);
    _petBreedTF.delegate = self;
    _petBreedTF.borderStyle = UITextBorderStyleRoundedRect;
    _petBreedTF.placeholder = @"Breed";
    _petBreedTF.userInteractionEnabled = YES;
    
    _petAgeTF = [[UITextField alloc] init];
    _petAgeTF.font = [UIFont fontWithName:@"Helvetica" size:14];
    _petAgeTF.layer.cornerRadius=4.0f;
    _petAgeTF.layer.masksToBounds=YES;
    _petAgeTF.layer.borderColor=[[QCApi colorWithHexString:@"00CEBA"]CGColor];
    _petAgeTF.layer.borderWidth= 1.0f;
    _petAgeTF.frame = CGRectMake(0.0f, _petBreedTF.frame.origin.y+45, 250.0f, 40.0f);
    _petAgeTF.delegate = self;
    _petAgeTF.borderStyle = UITextBorderStyleRoundedRect;
    _petAgeTF.placeholder = @"Birth Date";
    _petAgeTF.userInteractionEnabled = YES;
    
    //Datepicker initialization
    _monthYearPicker = [[LTHMonthYearPickerView alloc] initWithDate: [NSDate date]
                                                        shortMonths: NO
                                                     numberedMonths: NO
                                                         andToolbar: YES];
    _monthYearPicker.delegate = self;
    _petAgeTF.inputView = _monthYearPicker;
    
    [_additionalFields addSubview:_petBreedTF];
    [_additionalFields addSubview:_petAgeTF];
    [self.view addSubview:_additionalFields];
}

- (void) createVehicleAdditionalFields{
    _vehiclePlateTF = [[UITextField alloc] init];
    _vehiclePlateTF.font = [UIFont fontWithName:@"Helvetica" size:14];
    _vehiclePlateTF.layer.cornerRadius=4.0f;
    _vehiclePlateTF.layer.masksToBounds=YES;
    _vehiclePlateTF.layer.borderColor=[[QCApi colorWithHexString:@"00CEBA"]CGColor];
    _vehiclePlateTF.layer.borderWidth= 1.0f;
    _vehiclePlateTF.frame = CGRectMake(0.0f, 30.0f, 250.0f, 40.0f);
    _vehiclePlateTF.delegate = self;
    _vehiclePlateTF.borderStyle = UITextBorderStyleRoundedRect;
    _vehiclePlateTF.placeholder = @"Plate";
    _vehiclePlateTF.userInteractionEnabled = YES;
    
    _vehicleYearTF = [[UITextField alloc] init];
    _vehicleYearTF.font = [UIFont fontWithName:@"Helvetica" size:14];
    _vehicleYearTF.layer.cornerRadius=4.0f;
    _vehicleYearTF.layer.masksToBounds=YES;
    _vehicleYearTF.layer.borderColor=[[QCApi colorWithHexString:@"00CEBA"]CGColor];
    _vehicleYearTF.layer.borderWidth= 1.0f;
    _vehicleYearTF.frame = CGRectMake(0.0f, _vehiclePlateTF.frame.origin.y+45, 250.0f, 40.0f);
    _vehicleYearTF.delegate = self;
    _vehicleYearTF.borderStyle = UITextBorderStyleRoundedRect;
    _vehicleYearTF.placeholder = @"Year";
    _vehicleYearTF.userInteractionEnabled = YES;
    
    //Datepicker initialization
    _monthYearPicker = [[LTHMonthYearPickerView alloc] initWithDate: [NSDate date]
                                                            shortMonths: NO
                                                         numberedMonths: NO
                                                             andToolbar: YES];
    _monthYearPicker.delegate = self;
    _vehicleYearTF.inputView = _monthYearPicker;

    
    [_additionalFields addSubview:_vehiclePlateTF];
    [_additionalFields addSubview:_vehicleYearTF];
    [self.view addSubview:_additionalFields];
}

- (void) createAdAdditionalFields{
    _adTypeTF = [[UITextField alloc] init];
    _adTypeTF.font = [UIFont fontWithName:@"Helvetica" size:14];
    _adTypeTF.layer.cornerRadius=4.0f;
    _adTypeTF.layer.masksToBounds=YES;
    _adTypeTF.layer.borderColor=[[QCApi colorWithHexString:@"00CEBA"]CGColor];
    _adTypeTF.layer.borderWidth= 1.0f;
    _adTypeTF.frame = CGRectMake(0.0f, 0.0f, 250.0f, 40.0f);
    _adTypeTF.delegate = self;
    _adTypeTF.borderStyle = UITextBorderStyleRoundedRect;
    _adTypeTF.placeholder = @"Ad Type";
    _adTypeTF.userInteractionEnabled = YES;
    
    _eventDateTF = [[UITextField alloc] init];
    _eventDateTF.font = [UIFont fontWithName:@"Helvetica" size:14];
    _eventDateTF.layer.cornerRadius=4.0f;
    _eventDateTF.layer.masksToBounds=YES;
    _eventDateTF.layer.borderColor=[[QCApi colorWithHexString:@"00CEBA"]CGColor];
    _eventDateTF.layer.borderWidth= 1.0f;
    _eventDateTF.frame = CGRectMake(0.0f, _eventDateTF.frame.origin.y+46, 250.0f, 40.0f);
    _eventDateTF.delegate = self;
    _eventDateTF.borderStyle = UITextBorderStyleRoundedRect;
    _eventDateTF.placeholder = @"Event Date";
    _eventDateTF.userInteractionEnabled = YES;
    
    //Datepicker initialization
    _monthYearPicker = [[LTHMonthYearPickerView alloc] initWithDate: [NSDate date]
                                                        shortMonths: NO
                                                     numberedMonths: NO
                                                         andToolbar: YES];
    _monthYearPicker.delegate = self;
    _eventDateTF.inputView = _monthYearPicker;
    
    [_additionalFields addSubview:_adTypeTF];
    [_additionalFields addSubview:_eventDateTF];
    [self.view addSubview:_additionalFields];
}

- (void) createLocationAdditionalFields{
    
    _locationCityTF = [[UITextField alloc] init];
    _locationCityTF.font = [UIFont fontWithName:@"Helvetica" size:14];
    _locationCityTF.layer.cornerRadius=4.0f;
    _locationCityTF.layer.masksToBounds=YES;
    _locationCityTF.layer.borderColor=[[QCApi colorWithHexString:@"00CEBA"]CGColor];
    _locationCityTF.layer.borderWidth= 1.0f;
    _locationCityTF.frame = CGRectMake(0.0f, 0.0f, 250.0f, 40.0f);
    _locationCityTF.delegate = self;
    _locationCityTF.borderStyle = UITextBorderStyleRoundedRect;
    _locationCityTF.placeholder = @"City";
    _locationCityTF.userInteractionEnabled = YES;
    
    [_additionalFields addSubview:_locationCityTF];
    [self.view addSubview:_additionalFields];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//Code to hide keyboard when return key is pressed
-(BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    [_vehiclePlateTF resignFirstResponder];
    [_petBreedTF resignFirstResponder];
    [_brandTF resignFirstResponder];
    [_colorTF resignFirstResponder];
    return YES;
}

//Code to hide the keyboard when touching any area outside it
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [_vehiclePlateTF endEditing:YES];
    [_petBreedTF endEditing:YES];
    [_brandTF endEditing:YES];
    [_colorTF endEditing:YES];
}

-(QCTinkler*)saveNewTinkler{
    
    QCTinkler *newTinkler = [[QCTinkler alloc] init];
    [newTinkler setTinklerName:_tinklerName];
    
    //Set TinklerType Object to the new Tinkler
    [newTinkler setTinklerType:_tinklerType];
    
    //Set additional attributes
    [newTinkler setVehiclePlate:_vehiclePlateTF.text];
    [newTinkler setVehicleYear: [newTinkler tinklerStringToDate:_vehicleYearTF.text]];
    [newTinkler setPetBreed:_petBreedTF.text];
    [newTinkler setPetAge: [newTinkler tinklerStringToDate:_petAgeTF.text]];
    [newTinkler setBrand:_brandTF.text];
    [newTinkler setColor:_colorTF.text];
    [newTinkler setLocationCity:_locationCityTF.text];
    [newTinkler setEventDate: [newTinkler tinklerStringToDate:_eventDateTF.text]];
    [newTinkler setAdType:_adTypeTF.text];
    
    //Creating a PFFile object with the selected tinkler image only when user has selected new photo
    if(_hasNewPhoto){
        NSData *imageData = UIImageJPEGRepresentation(self.tinklerImage.image, 0.05f);
        PFFile *imageFile = [PFFile fileWithName:@"tinklerImage.jpg" data:imageData];
        [newTinkler setTinklerImage:imageFile];
        NSLog(@"Added new photo to the tinkler's object");
    }
    
    return newTinkler;
}

- (IBAction)addNewTinkler:(id)sender {
    
    //Validate if there is network connectivity
    if ([QCApi checkForNetwork]) {
        //Loading spinner
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            [QCApi addTinklerWithCompletion:[self saveNewTinkler] completion:^void(BOOL finished) {
                if (finished) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                    });
//                    //String with the alert message
                    NSString* alertmessage = [NSString stringWithFormat: @"New tinkler %@ created! Check your email or your phone's camera roll to get your QR-Code", _tinklerName];
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Tinkler Creation" message:alertmessage delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                    
                    [alertView show];
                    
                    
                }
            }];
        });
    }else{
        //Warn user
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Tinkler Creation Failed" message:@"You need to have network connectivity to create new Tinklers" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    //Re Start the qrcode reader only after the users presses "ok"
    if(buttonIndex == 0){
        //Set Updated Tinkler - ON
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setBool:YES forKey:@"hasUpdatedTinkler"];
        [defaults synchronize];
        
        // Present the profile view controller
        for (UIViewController* view in [self.navigationController viewControllers]){
            if ([view isKindOfClass:[QCTabViewController class]]){
                [self.navigationController popToViewController:view animated:YES];
            }
        }
    }
}

//Delegate methods for imagePicker
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    self.tinklerImage.image = chosenImage;
    
    //Change the clicked button flag
    self.hasNewPhoto = true;
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
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

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
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

#pragma mark - LTHMonthYearPickerView Delegate
- (void)pickerDidPressCancelWithInitialValues:(NSDictionary *)initialValues {
    
    //Check if this tinkler is a vehicle or a pet
    if([[_tinklerType objectForKey:@"typeName"] isEqualToString:@"Vehicle"]){
        _vehicleYearTF.text = [NSString stringWithFormat:
                               @"%@ %@",
                               initialValues[@"month"],
                               initialValues[@"year"]];
        [_vehicleYearTF resignFirstResponder];
    }else if([[_tinklerType objectForKey:@"typeName"] isEqualToString:@"Pet"]){
        _petAgeTF.text = [NSString stringWithFormat:
                               @"%@ %@",
                               initialValues[@"month"],
                               initialValues[@"year"]];
        [_petAgeTF resignFirstResponder];
    }else if([[_tinklerType objectForKey:@"typeName"] isEqualToString:@"Advertisement"]){
        _eventDateTF.text = [NSString stringWithFormat:
                             @"%@ %@",
                             initialValues[@"month"],
                             initialValues[@"year"]];
        [_eventDateTF resignFirstResponder];
    }
    
}

- (void)pickerDidPressDoneWithMonth:(NSString *)month andYear:(NSString *)year {
    
    if([[_tinklerType objectForKey:@"typeName"] isEqualToString:@"Vehicle"]){
        _vehicleYearTF.text = [NSString stringWithFormat: @"%@ %@", month, year];
        [_vehicleYearTF resignFirstResponder];
    }else if([[_tinklerType objectForKey:@"typeName"] isEqualToString:@"Pet"]){
        _petAgeTF.text = [NSString stringWithFormat: @"%@ %@", month, year];
        [_petAgeTF resignFirstResponder];
    }else if([[_tinklerType objectForKey:@"typeName"] isEqualToString:@"Advertisement"]){
        [_eventDateTF resignFirstResponder];
    }
}


- (void)pickerDidPressCancel {
    [_vehicleYearTF resignFirstResponder];
    if([[_tinklerType objectForKey:@"typeName"] isEqualToString:@"Vehicle"]){
        [_vehicleYearTF resignFirstResponder];
    }else if([[_tinklerType objectForKey:@"typeName"] isEqualToString:@"Pet"]){
        [_petAgeTF resignFirstResponder];
    }else if([[_tinklerType objectForKey:@"typeName"] isEqualToString:@"Advertisement"]){
        [_eventDateTF resignFirstResponder];
    }
}


- (void)pickerDidSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSLog(@"row: %li in component: %li", (long)row, (long)component);
}


- (void)pickerDidSelectMonth:(NSString *)month {
    NSLog(@"month: %@ ", month);
}


- (void)pickerDidSelectYear:(NSString *)year {
    NSLog(@"year: %@ ", year);
}


- (void)pickerDidSelectMonth:(NSString *)month andYear:(NSString *)year {
    if([[_tinklerType objectForKey:@"typeName"] isEqualToString:@"Vehicle"]){
        _vehicleYearTF.text = [NSString stringWithFormat: @"%@ %@", month, year];
    }else if([[_tinklerType objectForKey:@"typeName"] isEqualToString:@"Pet"]){
        _petAgeTF.text = [NSString stringWithFormat: @"%@ %@", month, year];
    }else if([[_tinklerType objectForKey:@"typeName"] isEqualToString:@"Advertisement"]){
        _eventDateTF.text = [NSString stringWithFormat: @"%@ %@", month, year];
    }
    
}


@end
