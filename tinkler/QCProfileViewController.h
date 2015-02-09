//
//  QCProfileViewController.h
//  qrcar
//
//  Created by Diogo Guimarães on 06/09/14.
//  Copyright (c) 2014 Miguel Quintas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "QCTinkler.h"
#import "QCApi.h"
#import "UIImageView+AFNetworking.h"
#import "QCTinklerTableViewCell.h"
#import "QCTinklerDetailViewController.h"

@interface QCProfileViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSMutableArray *tinklers;
@property (strong, nonatomic) NSArray *thumbnails;

@property (strong, nonatomic) IBOutlet UILabel *usernameLabel;
- (IBAction)registerButton:(id)sender;

@property (strong, nonatomic) IBOutlet UITableView *tinklersTabView;

@end
