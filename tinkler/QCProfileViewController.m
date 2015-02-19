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
    self.title = @"Profile";
    self.tinklersTabView.allowsMultipleSelectionDuringEditing = NO;

}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillAppear:YES];
    self.tabBarController.navigationItem.rightBarButtonItem =nil;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    
    //Set the logout button conversation button
    UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStylePlain target:self action:@selector(logoutUser)];
    self.tabBarController.navigationItem.rightBarButtonItem = anotherButton;
    
    //Set Tab Title
    self.tabBarController.navigationItem.title = @"My Profile";
    [self.tinklersTabView reloadData];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    //[[PFUser currentUser] refresh];
    self.usernameLabel.text = [[PFUser currentUser] objectForKey:@"name"];
    //Loading spinner
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [QCApi getAllTinklersWithCallBack:^(NSMutableArray *tinklersArray, NSError *error) {
            if (error == nil){
                self.tinklers = tinklersArray;
                NSLog(@"Tinkler Array: %@", [[self.tinklers objectAtIndex:0] tinklerName]);
                [self.tinklersTabView reloadData];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                });
            } else {
                NSLog(@"%@", error);
            }
        }];
        
    });
    
}

- (void) logoutUser{
    [PFUser logOut];
    
    // Present the log in view controller
    [self.navigationController popViewControllerAnimated:YES];
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
    [cell.thumbnailImageView setImageWithURL: [NSURL URLWithString:thisTinkler.tinklerImage.url]];
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

// Cell Swipe delete code 
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [QCApi deleteTinklerWithCompletion:[self.tinklers objectAtIndex:indexPath.row] completion:^void(BOOL finished) {
            if (finished) {
                // Remove the row from data model
                [self.tinklers removeObjectAtIndex:indexPath.row];
                // Request table view to reload
                [self.tinklersTabView reloadData];
            }
        }];
    }
}

//End of Delegate methods

@end
