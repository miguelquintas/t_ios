//
//  QCProfileViewController.m
//  qrcar
//
//  Created by Diogo Guimarães on 06/09/14.
//  Copyright (c) 2014 Miguel Quintas. All rights reserved.
//

#import "QCProfileViewController.h"

@implementation QCProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Tinklers";
    self.tinklersTabView.allowsMultipleSelectionDuringEditing = NO;
    
    //Edit the buttons style
    [_createNewButton.layer setBorderWidth:1.0];
    [_createNewButton.layer setBorderColor:[[QCApi colorWithHexString:@"EE463E"] CGColor]];
    [_createNewButton.layer setCornerRadius: self.createNewButton.frame.size.width / 2];
    
    //Set the settings button
    CGSize result = [[UIScreen mainScreen] bounds].size;
    CGFloat scale = [UIScreen mainScreen].scale;
    result = CGSizeMake(result.width * scale, result.height * scale);
    
    if(result.height == 960) {
        NSLog(@"iPhone 4 Resolution");
        UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"settings.png"] style:UIBarButtonItemStylePlain target:self action:@selector(goToSettings)];
        self.tabBarController.navigationItem.rightBarButtonItem = anotherButton;
    }else if(result.height == 1136) {
        NSLog(@"iPhone 5 Resolution");
        UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"settings@2x.png"] style:UIBarButtonItemStylePlain target:self action:@selector(goToSettings)];
        self.tabBarController.navigationItem.rightBarButtonItem = anotherButton;
    }else{
        NSLog(@"iPhone 6 or more Resolution");
        UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"settings@3x.png"] style:UIBarButtonItemStylePlain target:self action:@selector(goToSettings)];
        self.tabBarController.navigationItem.rightBarButtonItem = anotherButton;
    }
    
    [self.noItemsView setBackgroundColor:[QCApi colorWithHexString:@"7FD0D1"]];
    [_offlineTopLayer setText:@"Create your Tinklers, place your QR-Codes and start communicating!"];
    [_offlineTopLayer setTextColor:[QCApi colorWithHexString:@"5BBABD"]];
    [_offlineTopLayer setFont:[UIFont boldSystemFontOfSize:20]];
    [_offlineBottomLayer setText:@"You don't have any created Tinklers yet"];
    [_offlineBottomLayer setTextColor:[QCApi colorWithHexString:@"5BBABD"]];
    [_offlineBottomLayer setFont:[UIFont boldSystemFontOfSize:20]];
    
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    self.tabBarController.navigationItem.rightBarButtonItem =nil;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    
    [self.tinklersTabView setSeparatorColor:[QCApi colorWithHexString:@"00CEBA"]];
    
    //Set Tab Title
    [self.tinklersTabView reloadData];
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //Verify if user has updated the tinklers list - through user preferences
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    bool hasUpdatedTinklers = [defaults boolForKey:@"hasUpdatedTinkler"];
    
    if(hasUpdatedTinklers && [QCApi checkForNetwork]) {
        [self getTinklersOnline];
    } else {
        [self refreshTinklers];
    }
}

- (void)refreshTinklers{
    //Loading spinner
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [QCApi getLocalTinklers:^(NSMutableArray *localTinklersArray, NSError *error) {
            if (error == nil){
                //If there are any conversations stored locally load them
                if(localTinklersArray.count > 0){
                    [self.noItemsView setHidden:YES];
                    [self.tinklersTabView setHidden:NO];
                    self.tinklers = localTinklersArray;
                    [self.tinklersTabView reloadData];
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                }else{//Check online for conversations
                    if ([QCApi checkForNetwork]){
                        [QCApi getOnlineTinklers:^(NSMutableArray *onlineTinklersArray, NSError *error) {
                            if (error == nil){
                                //If there are any conversations to load from parse load them
                                if(onlineTinklersArray.count > 0){
                                    [self.noItemsView setHidden:YES];
                                    [self.tinklersTabView setHidden:NO];
                                    self.tinklers = onlineTinklersArray;
                                    [self.tinklersTabView reloadData];
                                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                                }else{//Show empty conversations placeholder
                                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                                    [self.noItemsView setHidden:NO];
                                    [self.tinklersTabView setHidden:YES];
                                }
                            }else{
                                [MBProgressHUD hideHUDForView:self.view animated:YES];
                                //Warn user
                                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Connection Failed" message:@"There was an error loading your Tinklers. Please try again later." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                                [alertView show];
                            }
                        }];
                    }else{//Show empty conversations placeholder
                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                        [self.noItemsView setHidden:NO];
                        [self.tinklersTabView setHidden:YES];
                    }
                }
            }else{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                //Warn user
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Connection Failed" message:@"There was an error loading your Tinklers. Please try again later." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                [alertView show];
            }
        }];
        
    });
}

- (void)getTinklersOnline{
    //Loading spinner
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        if ([QCApi checkForNetwork]){
            [QCApi getOnlineTinklers:^(NSMutableArray *onlineTinklersArray, NSError *error) {
                if (error == nil){
                    [self.noItemsView setHidden:YES];
                    [self.tinklersTabView setHidden:NO];
                    //Set PushNotification Preference OFF
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    [defaults setBool:NO forKey:@"hasUpdatedTinkler"];
                    [defaults synchronize];
                    self.tinklers = onlineTinklersArray;
                    [self.tinklersTabView reloadData];
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                }else{
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    //Warn user there was a connection issue
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Connection Failed" message:@"There was an error loading your Tinklers. Please try again later." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                    [alertView show];
                }
            }];
        }else{
            //Warn user that he has no network connection
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"No Network Connection" message:@"You must be online to load new Tinklers." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alertView show];
        }
    });
}

- (void)goToSettings{
    [self performSegueWithIdentifier:@"goToSettings" sender:self];
}

//Delegate methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.tinklers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"TinklerCell";
    
    QCTinklerTableViewCell *cell = (QCTinklerTableViewCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    QCTinkler *thisTinkler = [_tinklers objectAtIndex:indexPath.row];
    
    cell.tinklerNameLabel.text = [thisTinkler tinklerName];
    
    cell.thumbnailImageView.layer.borderColor=[[QCApi colorWithHexString:@"00CEBA"]CGColor];
    cell.thumbnailImageView.layer.borderWidth= 1.0f;
    
    if(thisTinkler.tinklerImage == nil){
        [cell.thumbnailImageView setImage:[UIImage imageNamed:@"default_pic.png"]];
    }else{
        [thisTinkler.tinklerImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error) {
                [cell.thumbnailImageView setImage:[UIImage imageWithData:data]];
            }
        }];
    }
    
    cell.thumbnailImageView.layer.cornerRadius = 30;
    cell.thumbnailImageView.clipsToBounds = YES;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 78;
}

//Code to pass selected vehicle data to the Vehicle Edit View Controller
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"editVehicle"]) {
        NSIndexPath *indexPath = [self.tinklersTabView indexPathForSelectedRow];
        QCTinklerDetailViewController *destViewController = segue.destinationViewController;
        destViewController.selectedTinkler = [_tinklers objectAtIndex:indexPath.row];
    }
}

//End of Delegate methods


@end
