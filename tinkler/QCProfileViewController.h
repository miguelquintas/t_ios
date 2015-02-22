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
#import "MBProgressHUD.h"

@interface QCProfileViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) NSMutableArray *tinklers;
@property (strong, nonatomic) NSArray *thumbnails;
@property (weak, nonatomic) IBOutlet UIImageView *profilePic;

@property (strong, nonatomic) IBOutlet UILabel *usernameLabel;

@property (strong, nonatomic) IBOutlet UITableView *tinklersTabView;

//Menu to select photo source
@property (strong, nonatomic) UIActionSheet *photoSourceMenu;

- (IBAction)selectPhoto:(id)sender;

@end
