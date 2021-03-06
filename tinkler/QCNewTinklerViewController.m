//
//  QCNewTinklerViewController.m
//  qrcar
//
//  Created by Diogo Guimarães on 03/01/15.
//  Copyright (c) 2015 Miguel Quintas. All rights reserved.
//

#import "QCNewTinklerViewController.h"

@interface QCNewTinklerViewController ()

@end

@implementation QCNewTinklerViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    //Load the default pic
    self.tinklerImage.image = [UIImage imageNamed:@"default_icon_blue.png"];
    self.tinklerImage.layer.borderColor=[[QCApi colorWithHexString:@"00CEBA"]CGColor];
    self.tinklerImage.layer.borderWidth= 1.0f;
    self.tinklerImage.layer.cornerRadius = self.tinklerImage.frame.size.width / 2;
    self.tinklerImage.clipsToBounds = YES;
    
    //Set the border color of the name textfield
    _tinklerName.layer.cornerRadius=4.0f;
    _tinklerName.layer.masksToBounds=YES;
    _tinklerName.layer.borderColor=[[QCApi colorWithHexString:@"00CEBA"]CGColor];
    _tinklerName.layer.borderWidth= 1.0f;
    
    _tinklerTypeTF.layer.cornerRadius=4.0f;
    _tinklerTypeTF.layer.masksToBounds=YES;
    _tinklerTypeTF.layer.borderColor=[[QCApi colorWithHexString:@"00CEBA"]CGColor];
    _tinklerTypeTF.layer.borderWidth= 1.0f;
    
    //Get the existing Tinkler Types
    //Check connectivity
    if([QCApi checkForNetwork]){
        [QCApi getOnlineTinklerTypes:^(NSArray *tinklerTypeArray, NSMutableArray *typeNameArray, NSError *error) {
            if (error == nil){
                self.tinklerTypes = tinklerTypeArray;
                self.tinklerTypeNames = typeNameArray;
            } else {
                NSLog(@"%@", error);
                //Warn user
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Connection Failed" message:@"There was an error loading the Tinkler types. Please check your connectivity and restart Tinkler." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                [alertView show];
            }
        }];
    }else{
        [QCApi getLocalTinklerTypes:^(NSArray *tinklerTypeArray, NSMutableArray *typeNameArray, NSError *error) {
            if (error == nil){
                self.tinklerTypes = tinklerTypeArray;
                self.tinklerTypeNames = typeNameArray;
            } else {
                NSLog(@"%@", error);
                //Warn user
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Connection Failed" message:@"There was an error loading the Tinkler types. Please check your connectivity and restart Tinkler." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                [alertView show];
            }
        }];
    }
    
    self.title = @"New Tinkler";
    
    //Edit the buttons style
    [_nextButtonOutlet setBackgroundColor:[QCApi colorWithHexString:@"EE463E"]];
    [_nextButtonOutlet.layer setBorderWidth:1.0];
    [_nextButtonOutlet.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    [_nextButtonOutlet.layer setCornerRadius: 6.0f];
    
    //TinklerTypePicker Initialization
    [_tinklerType addTarget:self action:@selector(showTinklerTypePicker:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//Code to hide keyboard when return key is pressed
-(IBAction)textFieldReturn:(id)sender{
    [sender resignFirstResponder];
}

//Code to hide the keyboard when touching any area outside it
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [_tinklerName endEditing:YES];
}

- (void) showTinklerTypePicker:(id)sender{
    [_tinklerName endEditing:YES];
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

- (IBAction)nextButton:(id)sender {
    
    if(!([_tinklerName.text length] == 0) && !([_tinklerTypeTF.text length] == 0)){
        [self performSegueWithIdentifier:@"submitTinkler" sender:self];
    }else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Missing Data" message:@"Please fill in the name and type of your new Tinkler before continuing" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

- (IBAction)tinklerImagePicker:(id)sender {
    _photoSourceMenu = [[UIActionSheet alloc] initWithTitle:@"Select the picture's source"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                     destructiveButtonTitle:nil
                                          otherButtonTitles:@"Camera", @"Photo Library", nil];
    
    // Show the sheet
    [_photoSourceMenu showInView:self.view];
}

//Delegate methods for imagePicker
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    self.tinklerImage.image = chosenImage;
    
    //Change the clicked button flag
    self.hasNewPhoto = true;
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
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

//Tinkler Type Picker Delegate Methods
#pragma mark - SBPickerSelectorDelegate

-(void) SBPickerSelector:(SBPickerSelector *)selector selectedValue:(NSString *)value index:(NSInteger)idx{
    [_tinklerTypeTF setText:value];
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

//Code to pass selected Tinkler's data to the Tinkler Submit View Controller
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"submitTinkler"]) {
        QCNewTinklerSubmitViewController *destViewController = segue.destinationViewController;
        destViewController.tinklerName = _tinklerName.text;
        destViewController.selectedImage = _tinklerImage.image;
        destViewController.hasNewPhoto = _hasNewPhoto;
        
        //Set TinklerType Object to the new Tinkler
        for (PFObject *selectedTinklerType in self.tinklerTypes){
            if ([[selectedTinklerType objectForKey:@"typeName"] isEqualToString:_tinklerTypeTF.text]){
                NSLog(@"Added the Tinkler Type Successfully");
                destViewController.tinklerType = selectedTinklerType;
            }
        }
        
        
    }
}


@end
