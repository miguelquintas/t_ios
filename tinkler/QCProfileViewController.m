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

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    //Set Tab Title
    self.tabBarController.navigationItem.title = @"My Profile";
    [self.tinklersTabView reloadData];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    //[[PFUser currentUser] refresh];
    self.usernameLabel.text = [[PFUser currentUser] objectForKey:@"name"];
    [QCApi getAllTinklersWithCallBack:^(NSMutableArray *tinklersArray, NSError *error) {
        if (error == nil){
            self.tinklers = tinklersArray;
            NSLog(@"Tinkler Array: %@", [[self.tinklers objectAtIndex:0] tinklerName]);
            [self.tinklersTabView reloadData];
        } else {
            NSLog(@"%@", error);
        }
    }];
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

- (IBAction)registerButton:(id)sender {
    [PFUser logOut];
    
    // Present the log in view controller
    [self.navigationController popViewControllerAnimated:YES];
}

@end
