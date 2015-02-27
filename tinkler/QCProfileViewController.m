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
    
    self.profilePic.layer.cornerRadius = self.profilePic.frame.size.width / 2;
    self.profilePic.clipsToBounds = YES;
    
    // Get the stored data before the view loads
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *imageData = [defaults dataForKey:@"profilePic"];
    UIImage *storedProfilePic = [UIImage imageWithData:imageData];
    
    //Set profile pic from NSUserDefaults
    if(imageData == nil){
        //Load the default profile pic
        self.profilePic.image = [UIImage imageNamed:@"default_pic.jpg"];
    }else{
        self.profilePic.image = storedProfilePic;
    }
    
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
    
    //Remove NavBar bottom border
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setBackgroundColor:[QCApi colorWithHexString:@"73CACD"]];
    [self.navigationController.navigationBar setBarTintColor:[QCApi colorWithHexString:@"73CACD"]];
    
    //Set Profile View background color
    [_profileView setBackgroundColor:[QCApi colorWithHexString:@"73CACD"]];
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
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                });
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
    
    if(thisTinkler.tinklerImage == nil){
        [cell.thumbnailImageView setImage:[UIImage imageNamed:@"default_pic.jpg"]];
    }else{
        [cell.thumbnailImageView setImageWithURL: [NSURL URLWithString:thisTinkler.tinklerImage.url]];
    }
    
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

//Delegate methods for imagePicker
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    self.profilePic.image = chosenImage;
    
    //Set image to NSUserDefaults preferences
    // Create instances of NSData
    NSData *imageData = UIImageJPEGRepresentation(chosenImage, 100);
    // Store the data
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:imageData forKey:@"profilePic"];
    
    [defaults synchronize];
    NSLog(@"Data saved");
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSLog(@"Button %ld", (long)buttonIndex);
    if(buttonIndex == 0){
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        [self presentViewController:picker animated:YES completion:NULL];
    }else if (buttonIndex == 1){
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        [self presentViewController:picker animated:YES completion:NULL];
    }
}

//End of Delegate methods

- (IBAction)selectPhoto:(id)sender {
    _photoSourceMenu = [[UIActionSheet alloc] initWithTitle:@"Select the picture's source"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                     destructiveButtonTitle:nil
                                          otherButtonTitles:@"Camera", @"Photo Library", nil];
    
    // Show the sheet
    [_photoSourceMenu showInView:self.view];
}

@end
