//
//  QCScanViewController.m
//  qrcar
//
//  Created by Diogo Guimarães on 03/09/14.
//  Copyright (c) 2014 Miguel Quintas. All rights reserved.
//

#import "QCScanViewController.h"

@interface QCScanViewController ()

@end

@implementation QCScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _captureSession = nil;
    
    [self.noItemsView setBackgroundColor:[QCApi colorWithHexString:@"7FD0D1"]];
    [_offlineTopLayer setText:@"There is no internet connection"];
    [_offlineTopLayer setTextColor:[QCApi colorWithHexString:@"5BBABD"]];
    [_offlineTopLayer setFont:[UIFont boldSystemFontOfSize:20]];
    [_offlineBottomLayer setText:@"You need to have network connectivity to scan QR-Codes"];
    [_offlineBottomLayer setTextColor:[QCApi colorWithHexString:@"5BBABD"]];
    [_offlineBottomLayer setFont:[UIFont boldSystemFontOfSize:20]];
    
    //Check connectivity
    if([QCApi checkForNetwork]){
        [QCApi getOnlineMessageTypes:^(NSMutableArray *msgTypeArray, NSError *error) {
            if (error == nil){
                self.msgTypes = msgTypeArray;
            } else {
                NSLog(@"%@", error);
                //Warn user
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Connection Failed" message:@"There was an error loading the message types. Please check your connectivity and restart Tinkler." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                [alertView show];
            }
        }];
    }else{
        [QCApi getLocalMessageTypes:^(NSMutableArray *msgTypeArray, NSError *error) {
            if (error == nil){
                self.msgTypes = msgTypeArray;
            } else {
                NSLog(@"%@", error);
                //Warn user
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Connection Failed" message:@"There was an error loading the message types. Please check your connectivity and restart Tinkler." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                [alertView show];
            }
        }];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    
    self.scannedTinklerId = @"";
    
    //if there's no internet connection hide qrCam frame
    if(![QCApi checkForNetwork]){
        [_qrCam setHidden:YES];
        [self.noItemsView setHidden:NO];
    } else {
        [self.noItemsView setHidden:YES];
        [_qrCam setHidden:NO];
        [self startQrCodeRead];
        
        if (self.scanBorder == nil){
            int scanBorderWidth = self.view.frame.size.width * 0.9;
            
            self.scanBorder = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 - scanBorderWidth / 2, (self.view.frame.size.height-70) / 2 - scanBorderWidth / 2, scanBorderWidth, scanBorderWidth)];
            [self.scanBorder setImage:[UIImage imageNamed:@"scan_border.png"]];
        
            [self.view addSubview:self.scanBorder];
        }
    }
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:YES];
    [self performSelectorOnMainThread:@selector(stopQrCodeRead) withObject:nil waitUntilDone:NO];
}


- (void)startQrCodeRead{
    NSError *error;
    
    //Capturing Code
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    
    if (!input)
        NSLog(@"%@", [error localizedDescription]);
    
    _captureSession = [[AVCaptureSession alloc] init];
    [_captureSession addInput:input];
    
    AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    [_captureSession addOutput:captureMetadataOutput];
    dispatch_queue_t dispatchQueue;
    dispatchQueue = dispatch_queue_create("myQueue", NULL);
    [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
    [captureMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObject:AVMetadataObjectTypeQRCode]];
    
    //Camera View Code
    _videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
    [_videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [_videoPreviewLayer setFrame:_qrCam.layer.bounds];
    [_qrCam.layer addSublayer:_videoPreviewLayer];
    [_captureSession startRunning];
    
}

- (void)stopQrCodeRead{
    [_captureSession stopRunning];
    _captureSession = nil;
}

- (void)sendPushNotification:(NSString *) messageType :(NSString *) messageToSend{
    
    [PFCloud callFunctionInBackground:@"sendPushToUser"
                       withParameters:@{@"recipientId": _scannedTinklerId, @"messageType": messageType, @"message":messageToSend}
                                block:^(NSString *success, NSError *error) {
                                    if (!error) {
                                        //Update the conversations online
                                        //Set PushNotification Preference ON
                                        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                                        [defaults setBool:YES forKey:@"hasReceivedMsg"];
                                        [defaults synchronize];
                                        
                                        // Push sent successfully
                                        NSLog(@"Message Sent Successfully");
                                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Message Sent" message:@"Your message was successfully sent!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                                        [alertView show];
                                    }
                                }];
}

- (void) chooseMessageType:(BOOL) allowCustomMsg{
    _messageTypeMenu = [[UIActionSheet alloc] initWithTitle:@"Select a message to send"
                                                   delegate:self
                                          cancelButtonTitle:nil
                                     destructiveButtonTitle:nil
                                          otherButtonTitles:nil];
    
    // Add buttons one by one through the msgTypes array
    for (QCMessageType *msgType in self.msgTypes) {
        //Filter messages by this Tinkler's types
        if([[msgType.tinklerType objectForKey:@"typeName"] isEqualToString:self.scannedTinklerType]){
            [_messageTypeMenu addButtonWithTitle:msgType.text];
        }else if ([msgType.text isEqualToString:@"Custom Message"] && allowCustomMsg){
            [_messageTypeMenu addButtonWithTitle:msgType.text];
        }
    }
    
    // Add the cancel button in the last position
    [_messageTypeMenu addButtonWithTitle:@"Cancel"];
    // Set cancel button index to the one we just added so that we know which one it is in delegate call
    _messageTypeMenu.destructiveButtonIndex = _messageTypeMenu.numberOfButtons-1;
    
    // Show the menu
    [_messageTypeMenu showInView:self.parentViewController.view];
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.destructiveButtonIndex){
        //Cancel button pressed so re start the qrcode reading
        [self startQrCodeRead];
        return;
    }
    
    
    NSString *clicked = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    //If it is a custom message start type menu
    if ([clicked isEqualToString:@"Custom Message"]){
        UIAlertView *customMsgAlert = [[UIAlertView alloc] initWithTitle:@"Custom Message" message:@"Enter the message text to send" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil] ;
        customMsgAlert.tag = 2;
        customMsgAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
        [customMsgAlert show];
       
    //If it is a regular message send push notification with the message text
    }else{
        if([QCApi checkForNetwork]){
            [self sendPushNotification:clicked :clicked];
        }else{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Message Send Failed" message:@"You need to have network connectivity to send messages" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alertView show];
        }
    }
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    //Re Start the qrcode reader only after the users presses "ok"
    if(buttonIndex == 0 && [alertView.title isEqualToString:@"Message Sent"]){
        //Set PushNotification Preference ON
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setBool:YES forKey:@"hasReceivedMsg"];
        [defaults synchronize];
        
        [self.tabBarController setSelectedIndex:0];
    }
    else if(buttonIndex == 0){
        [self startQrCodeRead];
        
    }else if (buttonIndex == 1) {
        //Get textfield from the custom messages
        UITextField * alertTextField = [alertView textFieldAtIndex:0];
        [self sendPushNotification:@"Custom Message" :alertTextField.text];
    }
    
}

- (void) postScanTasks:(NSString *) metadataObj{

    //Get the first part of the qrCode content (until the '?' sign)
    NSString *tinklerUrl =[[metadataObj componentsSeparatedByString:@"?"] objectAtIndex:0];
    
    //If the QR-Code was not generated by Tinkler give alert
    if(![tinklerUrl isEqualToString:@"http://tinkler.it"]){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Invalid QR-Code" message:@"This QR-Code was not generated by Tinkler" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alertView show];
    }else{
        //Get the second part of the qrCode content (after the '?' sign)
        NSString *objectData =[[metadataObj componentsSeparatedByString:@"?"] objectAtIndex:1];
        
        //Get the objectID, objectKey and tinklerType from the second part of the qrCode content
        self.scannedTinklerId = [[objectData componentsSeparatedByString:@"!"] objectAtIndex:0];

        //Separate the objectKey from the tinklerType by checking the "&" char
        self.scannedTinklerType = [[[[objectData componentsSeparatedByString:@"!"] objectAtIndex:1] componentsSeparatedByString:@"&"] objectAtIndex:1];
        
        //Convert the objectkey String to Number
        NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
        [f setNumberStyle:NSNumberFormatterDecimalStyle];
        self.scannedTinklerKey = [f numberFromString:[[[[objectData componentsSeparatedByString:@"!"] objectAtIndex:1] componentsSeparatedByString:@"&"] objectAtIndex:0]];
        
        if([QCApi checkForNetwork]){
            //Validate Object QR-Code and Custom Messages boolean
            [QCApi validateObjectsQrCodeWithCompletion:self.scannedTinklerId :self.scannedTinklerKey completion:^void(BOOL finished, BOOL isValidated, BOOL allowCustom, BOOL isBlocked, BOOL isSelfTinkler){
                if (finished) {
                    if(isSelfTinkler){
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Invalid Scan" message:@"This Tinkler belongs to you" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                        [alertView show];
                    }else if(isBlocked){
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Invalid Scan" message:@"This conversation is blocked" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                        [alertView show];
                    }else if (isValidated) {
                        [self chooseMessageType:allowCustom];
                    }else{
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Invalid QR-Code" message:@"This QR-Code is not valid" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                        [alertView show];
                    }
                }
            }];
        }else{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Scan Failed" message:@"You need to have network connectivity to scan Tinklers" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alertView show];
        }
    }
}

-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{

    if (metadataObjects != nil && [metadataObjects count] == 1) {
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
        if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode]) {
            
            [self performSelectorOnMainThread:@selector(stopQrCodeRead) withObject:nil waitUntilDone:NO];
            
            [self performSelectorOnMainThread:@selector(postScanTasks:) withObject:[metadataObj stringValue] waitUntilDone:NO];
            
        }
    }
}

@end
