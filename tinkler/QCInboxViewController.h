//
//  QCInboxViewController.h
//  qrcar
//
//  Created by Diogo Guimarães on 06/09/14.
//  Copyright (c) 2014 Miguel Quintas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "QCInboxTableViewCell.h"
#import "QCInboxDetailViewController.h"
#import "QCMessage.h"
#import "QCConversation.h"
#import "UIImageView+AFNetworking.h"
#import "QCApi.h"
#import "MBProgressHUD.h"

@interface QCInboxViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSArray *conversations;
@property (strong, nonatomic) IBOutlet UITableView *messageTabView;

@end
