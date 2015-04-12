//
//  QCScanViewController.h
//  qrcar
//
//  Created by Diogo Guimarães on 03/09/14.
//  Copyright (c) 2014 Miguel Quintas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <Parse/Parse.h>
#import "QCApi.h"
#import "QCMessageType.h"

@interface QCScanViewController : UIViewController <UIActionSheetDelegate, AVCaptureMetadataOutputObjectsDelegate>
@property (strong, nonatomic) IBOutlet UIView *qrCam;
@property (strong, nonatomic) IBOutlet UIView *noItemsView;
@property (weak, nonatomic) IBOutlet UILabel *offlineTopLayer;
@property (weak, nonatomic) IBOutlet UILabel *offlineBottomLayer;

@property (strong, nonatomic) UIImageView *scanBorder;
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;

@property (strong, nonatomic) NSMutableArray *msgTypes;

@property (strong, nonatomic) NSString *scannedTinklerId;
@property (strong, nonatomic) NSString *scannedTinklerType;
@property (strong, nonatomic) NSNumber *scannedTinklerKey;

//Menu to select message type to send
@property (strong, nonatomic) UIActionSheet *messageTypeMenu;

@end
