//
//  QCAppDelegate.h
//  qrcar
//
//  Created by Miguel Quintas on 04/03/14.
//  Copyright (c) 2014 Miguel Quintas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QCApi.h"
#import <Parse/Parse.h>
#import <AudioToolbox/AudioToolbox.h>
#import "QCInboxViewController.h"
#import "QCInboxDetailViewController.h"
#import "QCScanViewController.h"
#import "QCProfileViewController.h"
#import "MPGNotification.h"

@interface QCAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@end
