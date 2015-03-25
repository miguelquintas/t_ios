//
//  QCInboxViewController.m
//  qrcar
//
//  Created by Diogo Guimarães on 06/09/14.
//  Copyright (c) 2014 Miguel Quintas. All rights reserved.
//

#import "QCInboxViewController.h"

@implementation QCInboxViewController

@synthesize conversations;
@synthesize messageTabView;

- (void)viewDidLoad{
    self.messageTabView.contentInset = UIEdgeInsetsZero;
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    //Set Tab Title
    [self setTitle:@"Inbox"];
    [self.messageTabView reloadData];
    
    [self.noItemsView setBackgroundColor:[QCApi colorWithHexString:@"7FD0D1"]];

    [self loadMessages];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
}

// Cell Swipe delete code
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        //Validate if there is network connectivity
        if ([QCApi checkForNetwork]) {
            [QCApi deleteConversationWithCompletion:[self.conversations objectAtIndex:indexPath.row] completion:^void(BOOL finished) {
                if (finished) {
                    // Remove the row from data model
                    [self.conversations removeObjectAtIndex:indexPath.row];
                    // Request table view to reload
                    [self.messageTabView reloadData];
                }
            }];
        }else{
            //Warn user
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Conversation Delete Failed" message:@"You need to have network connectivity to delete this conversation" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alertView show];
        }
    }
}

- (void)loadMessages{
    //Loading spinner
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [QCApi getAllConversationsWithCallBack:^(NSMutableArray *conversationsArray, NSError *error) {
            if (error == nil){
                
                //[conversationsArray removeAllObjects];
                
                if ([conversationsArray count] == 0){
                    [self.noItemsView setHidden:NO];
                    
                    [self.messageTabView setHidden:YES];
                } else {
                    [self.noItemsView setHidden:YES];
                    
                    self.conversations = conversationsArray;
                    [self.messageTabView reloadData];
                }
                
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            } else {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            }
        }];
    });
    
}

//Delegate methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.conversations count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"InboxCell";
    
    QCInboxTableViewCell *cell = (QCInboxTableViewCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    QCConversation *thisConversation = [conversations objectAtIndex:indexPath.row];
    PFFile *tinklerImage = [thisConversation talkingToTinkler][@"picture"];
    
    cell.tinklerNameLabel.text = [thisConversation talkingToTinkler][@"name"];
    //Get the proper date format
    cell.sentDate.text = thisConversation.lastSentDate;
    
    if(tinklerImage== nil){
        [cell.tinklerThumb setImage:[UIImage imageNamed:@"default_pic.jpg"]];
    }else{
        [tinklerImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error) {
                [cell.tinklerThumb setImage:[UIImage imageWithData:data]];
            }
        }];
    }
    
    cell.tinklerThumb.layer.cornerRadius = cell.tinklerThumb.frame.size.width / 2;
    cell.tinklerThumb.clipsToBounds = YES;
    
    //Messages to see in the current conversation
    if(thisConversation.hasUnreadMsg == YES){
        cell.msgNotification.hidden = NO;
        cell.msgNotification.layer.cornerRadius = cell.msgNotification.frame.size.width / 2;
        cell.msgNotification.clipsToBounds = YES;
        [cell.msgNotification setBackgroundColor:[QCApi colorWithHexString:@"00CEBA"]];
    }else{
        cell.msgNotification.hidden = YES;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 78;
}
//End of Delegate methods

//Code to pass selected vehicle data to the Vehicle Edit View Controller
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"messageDetail"]) {
        NSIndexPath *indexPath = [self.messageTabView indexPathForSelectedRow];
        QCInboxDetailViewController *destViewController = segue.destinationViewController;
        destViewController.selectedConversation = [conversations objectAtIndex:indexPath.row];
    }
}

@end
