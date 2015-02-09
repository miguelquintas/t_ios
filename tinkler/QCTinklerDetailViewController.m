//
//  QCTinklerDetailViewController.m
//  qrcar
//
//  Created by Diogo Guimarães on 09/01/15.
//  Copyright (c) 2015 Miguel Quintas. All rights reserved.
//

#import "QCTinklerDetailViewController.h"

@interface QCTinklerDetailViewController ()

@end

@implementation QCTinklerDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.hasNewPhoto = false;
    self.tinklerNameEdit.text = [self.selectedTinkler tinklerName];
    [_tinklerTypeEdit setTitle:[[self.selectedTinkler tinklerType] objectForKey:@"typeName"] forState:UIControlStateNormal];
    
    //Set Tinkler Image
    if([self.selectedTinkler tinklerImage] != nil){
        [self.tinklerImage setImageWithURL:[NSURL URLWithString:[self.selectedTinkler tinklerImage].url]];
    }else{
        //Load the default vehicle pic
        self.tinklerImage.image = [UIImage imageNamed:@"default_pic.jpg"];
    }
    
    //Set Tinkler's QR-Code Image
    if([self.selectedTinkler tinklerQRCode] != nil){
        [self.qrCodeImage setImageWithURL:[NSURL URLWithString:[self.selectedTinkler tinklerQRCode].url]];
    }else{
        //Load the default vehicle pic
        self.tinklerImage.image = [UIImage imageNamed:@"default_pic.jpg"];
    }
    
    //Display the optional fields for each tinkler type
    if ([[_selectedTinkler.tinklerType objectForKey:@"typeName"] isEqualToString:@"Vehicle"]) {
        [self createVehicleAdditionalFields];
    }else if ([[_selectedTinkler.tinklerType objectForKey:@"typeName"] isEqualToString:@"Pet"]){
        [self createPetAdditionalFields];
    }else if ([[_selectedTinkler.tinklerType objectForKey:@"typeName"] isEqualToString:@"Realty or Location"] || [[_selectedTinkler.tinklerType objectForKey:@"typeName"] isEqualToString:@"Key"]){
        NSLog(@"It's a key or a realty/location");
    }else if ([[_selectedTinkler.tinklerType objectForKey:@"typeName"] isEqualToString:@"Accessory"] || [[_selectedTinkler.tinklerType objectForKey:@"typeName"] isEqualToString:@"Object"] || [[_selectedTinkler.tinklerType objectForKey:@"typeName"] isEqualToString:@"Bag or Suitcase"]){
        [self createBagsAcessoriesAdditionalFields];
    }
    
    //Get the existing Tinkler Types
    [QCApi getAllTinklerTypesWithCallBack:^(NSArray *tinklerTypeArray, NSMutableArray *typeNameArray, NSError *error) {
        if (error == nil){
            self.tinklerTypes = tinklerTypeArray;
            self.tinklerTypeNames = typeNameArray;
            NSLog(@"Tinkler Type Names Array %@", self.tinklerTypeNames);
        } else {
            NSLog(@"%@", error);
        }
    }];
    
    //TinklerTypePicker Initialization
    [_tinklerTypeEdit addTarget:self action:@selector(showTinklerTypePicker:) forControlEvents:UIControlEventTouchUpInside];
}

-(void) viewWillDisappear:(BOOL)animated {
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        //Save edited object
        [self editTinkler];
        [QCApi editTinklerWithCompletion:self.selectedTinkler completion:^void(BOOL finished) {
            if (finished) {
                NSLog(@"Updates were saved!");
            }
        }];
    }
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) createBagsAcessoriesAdditionalFields{
    _brandTF = [[UITextField alloc] init];
    _brandTF.frame = CGRectMake(0.0f, 0.0f, 250.0f, 35.0f);
    _brandTF.delegate = self;
    _brandTF.borderStyle = UITextBorderStyleRoundedRect;
    _brandTF.placeholder = @"Brand";
    _brandTF.userInteractionEnabled = YES;
    _brandTF.clearButtonMode = UITextFieldViewModeAlways;
    _brandTF.text = [self.selectedTinkler brand];
    
    _colorTF = [[UITextField alloc] init];
    _colorTF.frame = CGRectMake(0.0f, _brandTF.frame.origin.y+45, 250.0f, 35.0f);
    _colorTF.delegate = self;
    _colorTF.borderStyle = UITextBorderStyleRoundedRect;
    _colorTF.placeholder = @"Color";
    _colorTF.userInteractionEnabled = YES;
    _colorTF.clearButtonMode = UITextFieldViewModeAlways;
    _colorTF.text = [self.selectedTinkler color];
    
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
    _petBreedTF.text = [self.selectedTinkler petBreed];
    
    _petAgeTF = [[UITextField alloc] init];
    _petAgeTF.frame = CGRectMake(0.0f, _petBreedTF.frame.origin.y+45, 250.0f, 35.0f);
    _petAgeTF.delegate = self;
    _petAgeTF.borderStyle = UITextBorderStyleRoundedRect;
    _petAgeTF.placeholder = @"Birth Date";
    _petAgeTF.userInteractionEnabled = YES;
    _petAgeTF.clearButtonMode = UITextFieldViewModeAlways;
    _petAgeTF.text = [self.selectedTinkler tinklerDateToString:[self.selectedTinkler petAge]];
    
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
    _vehiclePlateTF.text = [self.selectedTinkler vehiclePlate];
    
    _vehicleYearTF = [[UITextField alloc] init];
    _vehicleYearTF.frame = CGRectMake(0.0f, _vehiclePlateTF.frame.origin.y+45, 250.0f, 35.0f);
    _vehicleYearTF.delegate = self;
    _vehicleYearTF.borderStyle = UITextBorderStyleRoundedRect;
    _vehicleYearTF.placeholder = @"Year";
    _vehicleYearTF.userInteractionEnabled = YES;
    _vehicleYearTF.clearButtonMode = UITextFieldViewModeAlways;
    _vehicleYearTF.text = [self.selectedTinkler tinklerDateToString:[self.selectedTinkler vehicleYear]];
    
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

//Code to hide keyboard when return key is pressed
-(BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    [_tinklerNameEdit resignFirstResponder];
    [_vehiclePlateTF resignFirstResponder];
    [_petBreedTF resignFirstResponder];
    [_brandTF resignFirstResponder];
    [_colorTF resignFirstResponder];
    return YES;
}

//Code to hide the keyboard when touching any area outside it
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [_tinklerNameEdit endEditing:YES];
}

-(void)editTinkler{
    
    [self.selectedTinkler setTinklerName:self.tinklerNameEdit.text];
    
    //Set TinklerType Object to the editted Tinkler
    for (PFObject *selectedTinklerType in self.tinklerTypes){
        
        NSLog(@"Tinkler Type Name %@", [selectedTinklerType objectForKey:@"typeName"]);
        if ([[selectedTinklerType objectForKey:@"typeName"] isEqualToString:_tinklerTypeEdit.titleLabel.text]){
            [self.selectedTinkler setTinklerType:selectedTinklerType];
            NSLog(@"Added the Tinkler Type Successfully");
        }
    }
    
    //Set additional attributes
    [self.selectedTinkler setVehiclePlate:_vehiclePlateTF.text];
    [self.selectedTinkler setVehicleYear: [self.selectedTinkler tinklerStringToDate:_vehicleYearTF.text]];
    [self.selectedTinkler setPetBreed:_petBreedTF.text];
    [self.selectedTinkler setPetAge: [self.selectedTinkler tinklerStringToDate:_petAgeTF.text]];
    [self.selectedTinkler setBrand:_brandTF.text];
    [self.selectedTinkler setColor:_colorTF.text];
    
    //Creating a PFFile object with the selected Tinkler image only when user has selected new photo
    if(_hasNewPhoto){
        NSData *imageData = UIImageJPEGRepresentation(self.tinklerImage.image, 0.05f);
        PFFile *imageFile = [PFFile fileWithName:@"TinklerImage.jpg" data:imageData];
        [self.selectedTinkler setTinklerImage:imageFile];
        NSLog(@"Added new photo to Tinkler object");
    }
    
}

- (IBAction)generateQRCode:(id)sender {
    
    //set new QR-Code key
    NSNumber *newQrCodeKey = [NSNumber numberWithInt:[[self.selectedTinkler tinklerQRCodeKey] intValue] + 1];
    
    //Save QRCode image to camera roll
    UIImage *newQrCode = [QCQrCode generateQRCode:[self.selectedTinkler tinklerId] :newQrCodeKey :[self.selectedTinkler.tinklerType objectForKey:@"typeName"]];
    UIImageWriteToSavedPhotosAlbum(newQrCode, nil, nil, nil);
    
    //String with the alert message
    NSString* alertmessage = [NSString stringWithFormat: @"The QR-Code for %@ was regenarated. The previous one will no longer be valid", self.tinklerNameEdit.text];
    
    //Send an email with the regenarated QR-Code
    [QCApi sendQrCodeEmail:[self.selectedTinkler tinklerId]];
    
    //Update QrCode and QrCodeKey
    NSData *imageData = UIImageJPEGRepresentation(newQrCode, 0.05f);
    PFFile *qrCodeFile = [PFFile fileWithName:@"qrCode.jpg" data:imageData];
    [self.selectedTinkler setTinklerQRCode: qrCodeFile];
    [self.selectedTinkler setTinklerQRCodeKey:newQrCodeKey];
    
    //Alert to warn user that the QR Code has been saved
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"QR Code Regenarated!" message:alertmessage delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [alertView show];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) showTinklerTypePicker:(id)sender{
    [_tinklerNameEdit endEditing:YES];
    //Vehicle Picker Initialization
    SBPickerSelector *picker = [SBPickerSelector picker];
    picker.pickerData = self.tinklerTypeNames; //picker content
    picker.delegate = self;
    picker.pickerType = SBPickerSelectorTypeText;
    picker.doneButtonTitle = @"Done";
    picker.cancelButtonTitle = @"Cancel";
    
    CGPoint point = [self.view convertPoint:[sender frame].origin fromView:[sender superview]];
    CGRect frame = [sender frame];
    frame.origin = point;
    
    [picker showPickerIpadFromRect:frame inView:self.view];
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

- (IBAction)deleteTinkler:(id)sender {
    //String with the alert message
    NSString* deletemessage = [NSString stringWithFormat: @"Are you sure you want to delete the Tinkler %@?", _tinklerNameEdit.text];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete Tinkler" message:deletemessage delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
    [alert show];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"%ld", (long)buttonIndex);
    if(buttonIndex == 1)
    {
        [QCApi deleteTinklerWithCompletion:_selectedTinkler completion:^void(BOOL finished) {
            if (finished) {
                NSString* deletemessage = [NSString stringWithFormat: @"The Tinkler %@ has been deleted", _tinklerNameEdit.text];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete Confirmation" message:deletemessage delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                [alert show];
            }
        }];
    }
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
    if([[_selectedTinkler.tinklerType objectForKey:@"typeName"] isEqualToString:@"Vehicle"]){
        _vehicleYearTF.text = [NSString stringWithFormat:
                               @"%@ %@",
                               initialValues[@"month"],
                               initialValues[@"year"]];
        [_vehicleYearTF resignFirstResponder];
    }else if([[_selectedTinkler.tinklerType objectForKey:@"typeName"] isEqualToString:@"Pet"]){
        _petAgeTF.text = [NSString stringWithFormat:
                          @"%@ %@",
                          initialValues[@"month"],
                          initialValues[@"year"]];
        [_petAgeTF resignFirstResponder];
    }
    
}

- (void)pickerDidPressDoneWithMonth:(NSString *)month andYear:(NSString *)year {
    
    if([[_selectedTinkler.tinklerType objectForKey:@"typeName"] isEqualToString:@"Vehicle"]){
        _vehicleYearTF.text = [NSString stringWithFormat: @"%@ %@", month, year];
        [_vehicleYearTF resignFirstResponder];
    }else if([[_selectedTinkler.tinklerType objectForKey:@"typeName"] isEqualToString:@"Pet"]){
        _petAgeTF.text = [NSString stringWithFormat: @"%@ %@", month, year];
        [_petAgeTF resignFirstResponder];
    }
}


- (void)pickerDidPressCancel {
    [_vehicleYearTF resignFirstResponder];
    if([[_selectedTinkler.tinklerType objectForKey:@"typeName"] isEqualToString:@"Vehicle"]){
        [_vehicleYearTF resignFirstResponder];
    }else if([[_selectedTinkler.tinklerType objectForKey:@"typeName"] isEqualToString:@"Pet"]){
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
    if([[_selectedTinkler.tinklerType objectForKey:@"typeName"] isEqualToString:@"Vehicle"]){
        _vehicleYearTF.text = [NSString stringWithFormat: @"%@ %@", month, year];
    }else if([[_selectedTinkler.tinklerType objectForKey:@"typeName"] isEqualToString:@"Pet"]){
        _petAgeTF.text = [NSString stringWithFormat: @"%@ %@", month, year];
    }
    
}

//Vehicle Picker Delegate Methods
#pragma mark - SBPickerSelectorDelegate
-(void) SBPickerSelector:(SBPickerSelector *)selector selectedValue:(NSString *)value index:(NSInteger)idx{
    [_tinklerTypeEdit setTitle:value forState:UIControlStateNormal];
}

-(void) SBPickerSelector:(SBPickerSelector *)selector cancelPicker:(BOOL)cancel{
    NSLog(@"press cancel");
    [selector resignFirstResponder];
}

-(void) SBPickerSelector:(SBPickerSelector *)selector intermediatelySelectedValue:(id)value atIndex:(NSInteger)idx{
    if ([value isMemberOfClass:[NSDate class]]) {
        [self SBPickerSelector:selector dateSelected:value];
    }else{
        [self SBPickerSelector:selector selectedValue:value index:idx];
    }
}

@end