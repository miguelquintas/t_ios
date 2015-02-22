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
    
    //Hide the type selector
    _tinklerType.hidden = YES;
    _tinklerTypeLabel.hidden = YES;
    
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
    
    if(!([_tinklerName.text length] == 0) && ![_tinklerType.titleLabel.text isEqualToString:@"Select Type"]){
        [self performSegueWithIdentifier:@"submitTinkler" sender:self];
    }else if(!([_tinklerName.text length] == 0)){
        _tinklerType.hidden = NO;
        _tinklerTypeLabel.hidden = NO;
        [_tinklerType sendActionsForControlEvents:UIControlEventTouchUpInside];
    }else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Empty Name" message:@"Please name your Tinkler before continuing" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

//Tinkler Type Picker Delegate Methods
#pragma mark - SBPickerSelectorDelegate

-(void) SBPickerSelector:(SBPickerSelector *)selector selectedValue:(NSString *)value index:(NSInteger)idx{
    [_tinklerType setTitle:value forState:UIControlStateNormal];
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

//Code to pass selected Tinkler's data to the Tinkler Edit View Controller
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"submitTinkler"]) {
        QCNewTinklerSubmitViewController *destViewController = segue.destinationViewController;
        destViewController.tinklerName = _tinklerName.text;
        
        //Set TinklerType Object to the new Tinkler
        for (PFObject *selectedTinklerType in self.tinklerTypes){
            
            NSLog(@"Tinkler Type Name %@", [selectedTinklerType objectForKey:@"typeName"]);
            if ([[selectedTinklerType objectForKey:@"typeName"] isEqualToString:_tinklerType.titleLabel.text]){
                NSLog(@"Added the Tinkler Type Successfully");
                destViewController.tinklerType = selectedTinklerType;
            }
        }
        
        
    }
}


@end
