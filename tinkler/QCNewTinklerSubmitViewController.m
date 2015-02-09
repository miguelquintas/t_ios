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
    
    //Load the default vehicle pic
    self.tinklerImage.image = [UIImage imageNamed:@"default_pic.jpg"];
    
    //Set the tinkler name and type to the respective labels
    [self.tinklerNameLabel setText:_tinklerName];
    [self.tinklerNameLabel setCenter:self.view.center];
    NSString *tinklerTypeName =[_tinklerType objectForKey:@"typeName"];
    [self.tinklerTypeLabel setText:tinklerTypeName];
    
    //Display the optional fields for each tinkler type
    if ([tinklerTypeName isEqualToString:@"Vehicle"]) {
        [self createVehicleAdditionalFields];
    }else if ([tinklerTypeName isEqualToString:@"Pet"]){
        [self createPetAdditionalFields];
    }else if ([tinklerTypeName isEqualToString:@"Realty or Location"] || [tinklerTypeName isEqualToString:@"Key"]){
        NSLog(@"It's a key or a realty/location");
    }else if ([tinklerTypeName isEqualToString:@"Accessory"] || [tinklerTypeName isEqualToString:@"Object"] || [tinklerTypeName isEqualToString:@"Bag or Suitcase"]){
        [self createBagsAcessoriesAdditionalFields];
    }
}

- (void) createBagsAcessoriesAdditionalFields{
    _brandTF = [[UITextField alloc] init];
    _brandTF.frame = CGRectMake(0.0f, 0.0f, 250.0f, 35.0f);
    _brandTF.delegate = self;
    _brandTF.borderStyle = UITextBorderStyleRoundedRect;
    _brandTF.placeholder = @"Brand";
    _brandTF.userInteractionEnabled = YES;
    _brandTF.clearButtonMode = UITextFieldViewModeAlways;
    
    _colorTF = [[UITextField alloc] init];
    _colorTF.frame = CGRectMake(0.0f, _brandTF.frame.origin.y+45, 250.0f, 35.0f);
    _colorTF.delegate = self;
    _colorTF.borderStyle = UITextBorderStyleRoundedRect;
    _colorTF.placeholder = @"Color";
    _colorTF.userInteractionEnabled = YES;
    _colorTF.clearButtonMode = UITextFieldViewModeAlways;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(15, 330, 300, 150)];
    [view addSubview:_brandTF];
    [view addSubview:_colorTF];
    [self.view addSubview:view];
}

- (void) createPetAdditionalFields{
    _petBreedTF = [[UITextField alloc] init];
    _petBreedTF.frame = CGRectMake(0.0f, 0.0f, 250.0f, 35.0f);
    _petBreedTF.delegate = self;
    _petBreedTF.borderStyle = UITextBorderStyleRoundedRect;
    _petBreedTF.placeholder = @"Breed";
    _petBreedTF.userInteractionEnabled = YES;
    _petBreedTF.clearButtonMode = UITextFieldViewModeAlways;
    
    _petAgeTF = [[UITextField alloc] init];
    _petAgeTF.frame = CGRectMake(0.0f, _petBreedTF.frame.origin.y+45, 250.0f, 35.0f);
    _petAgeTF.delegate = self;
    _petAgeTF.borderStyle = UITextBorderStyleRoundedRect;
    _petAgeTF.placeholder = @"Birth Date";
    _petAgeTF.userInteractionEnabled = YES;
    _petAgeTF.clearButtonMode = UITextFieldViewModeAlways;
    
    //Datepicker initialization
    _monthYearPicker = [[LTHMonthYearPickerView alloc] initWithDate: [NSDate date]
                                                        shortMonths: NO
                                                     numberedMonths: NO
                                                         andToolbar: YES];
    _monthYearPicker.delegate = self;
    _petAgeTF.inputView = _monthYearPicker;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(15, 330, 300, 150)];
    [view addSubview:_petBreedTF];
    [view addSubview:_petAgeTF];
    [self.view addSubview:view];
}

- (void) createVehicleAdditionalFields{
    _vehiclePlateTF = [[UITextField alloc] init];
    _vehiclePlateTF.frame = CGRectMake(0.0f, 0.0f, 250.0f, 35.0f);
    _vehiclePlateTF.delegate = self;
    _vehiclePlateTF.borderStyle = UITextBorderStyleRoundedRect;
    _vehiclePlateTF.placeholder = @"Plate";
    _vehiclePlateTF.userInteractionEnabled = YES;
    _vehiclePlateTF.clearButtonMode = UITextFieldViewModeAlways;
    
    _vehicleYearTF = [[UITextField alloc] init];
    _vehicleYearTF.frame = CGRectMake(0.0f, _vehiclePlateTF.frame.origin.y+45, 250.0f, 35.0f);
    _vehicleYearTF.delegate = self;
    _vehicleYearTF.borderStyle = UITextBorderStyleRoundedRect;
    _vehicleYearTF.placeholder = @"Year";
    _vehicleYearTF.userInteractionEnabled = YES;
    _vehicleYearTF.clearButtonMode = UITextFieldViewModeAlways;
    
    
    //Datepicker initialization
    _monthYearPicker = [[LTHMonthYearPickerView alloc] initWithDate: [NSDate date]
                                                            shortMonths: NO
                                                         numberedMonths: NO
                                                             andToolbar: YES];
    _monthYearPicker.delegate = self;
    _vehicleYearTF.inputView = _monthYearPicker;

    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(15, 330, 300, 150)];
    [view addSubview:_vehiclePlateTF];
    [view addSubview:_vehicleYearTF];
    [self.view addSubview:view];
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
    
    [QCApi addTinklerWithCompletion:[self saveNewTinkler] completion:^void(BOOL finished) {
        if (finished) {
            //String with the alert message
            NSString* alertmessage = [NSString stringWithFormat: @"New tinkler %@ created! Check your email or your phone's camera roll to get your QR-Code", _tinklerName];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Tinkler Creation" message:alertmessage delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alertView show];
            // Present the profile view controller
            [self.navigationController popToViewController:[[self.navigationController viewControllers] objectAtIndex:1] animated:YES];
        }
    }];
    
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
    }
    
}

- (void)pickerDidPressDoneWithMonth:(NSString *)month andYear:(NSString *)year {
    
    if([[_tinklerType objectForKey:@"typeName"] isEqualToString:@"Vehicle"]){
        _vehicleYearTF.text = [NSString stringWithFormat: @"%@ %@", month, year];
        [_vehicleYearTF resignFirstResponder];
    }else if([[_tinklerType objectForKey:@"typeName"] isEqualToString:@"Pet"]){
        _petAgeTF.text = [NSString stringWithFormat: @"%@ %@", month, year];
        [_petAgeTF resignFirstResponder];
    }
}


- (void)pickerDidPressCancel {
    [_vehicleYearTF resignFirstResponder];
    if([[_tinklerType objectForKey:@"typeName"] isEqualToString:@"Vehicle"]){
        [_vehicleYearTF resignFirstResponder];
    }else if([[_tinklerType objectForKey:@"typeName"] isEqualToString:@"Pet"]){
        [_petAgeTF resignFirstResponder];
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
    }
    
}


@end
