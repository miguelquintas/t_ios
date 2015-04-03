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
    
    self.messageTabView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, CGRectGetHeight(self.tabBarController.tabBar.frame), 0.0f);
    [self setHasSentMsg:NO];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    //Set Tab Title
    [self setTitle:@"Inbox"];
    [self.noItemsView setBackgroundColor:[QCApi colorWithHexString:@"7FD0D1"]];
    
    [self.messageTabView setSeparatorColor:[QCApi colorWithHexString:@"00CEBA"]];
    
    //Verify if user has received a push notification - through user preferences
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    bool hasReceivedMsg = [defaults boolForKey:@"hasReceivedMsg"];
    
    if((_hasSentMsg || hasReceivedMsg) && [QCApi checkForNetwork]) {
        [self receivePushNotifications];
        //Set PushNotification Preference OFF
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setBool:NO forKey:@"hasReceivedMsg"];
        [defaults synchronize];
        
        [self setHasSentMsg:NO];
    } else {
        [self refreshMessages];
    }
    
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

- (void)refreshMessages{
    //Loading spinner
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        //Query Objects from LocalData Store
        [QCApi getLocalConversations:^(NSMutableArray *localConversationsArray, NSError *error) {
            if (error == nil){
                //If there are any conversations stored locally load them
                if(localConversationsArray.count > 0){
                    [self.noItemsView setHidden:YES];
                    [self.messageTabView setHidden:NO];
                    self.conversations = localConversationsArray;
                    [self.messageTabView reloadData];
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                }else{//Check online for conversations
                    if ([QCApi checkForNetwork]){
                        [QCApi getOnlineConversations:^(NSMutableArray *onlineConversationsArray, NSError *error) {
                            if (error == nil){
                                //If there are any conversations to load from parse load them
                                if(onlineConversationsArray.count > 0){
                                    [self.noItemsView setHidden:YES];
                                    self.conversations = onlineConversationsArray;
                                    [self.messageTabView reloadData];
                                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                                }else{//Show empty conversations placeholder
                                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                                    [self.noItemsView setHidden:NO];
                                    [self.messageTabView setHidden:YES];
                                }
                            }else{
                                [MBProgressHUD hideHUDForView:self.view animated:YES];
                                //Warn user
                                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Connection Failed" message:@"There was an error loading your conversations. Please try again later." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                                [alertView show];
                            }
                        }];
                    }else{//Show empty conversations placeholder
                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                        [self.noItemsView setHidden:NO];
                        [self.messageTabView setHidden:YES];
                    }
                }
            }else{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                //Warn user
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Connection Failed" message:@"There was an error loading your conversations. Please try again later." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                [alertView show];
            }
        }];
    });
}

- (void)receivePushNotifications{
    //Loading spinner
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        if ([QCApi checkForNetwork]){
            [QCApi getOnlineConversations:^(NSMutableArray *onlineConversationsArray, NSError *error) {
                if (error == nil){
                    [self.noItemsView setHidden:YES];
                    [self.messageTabView setHidden:NO];
                    self.conversations = onlineConversationsArray;
                    [self.messageTabView reloadData];
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                }else{
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    //Warn user there was a connection issue
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Connection Failed" message:@"There was an error loading your conversations. Please try again later." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                    [alertView show];
                }
            }];
        }else{
            //Warn user that he has no network connection
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"No Network Connection" message:@"You must be online to load new received messages." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alertView show];
        }
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
        [destViewController setParentVC:self];
    }
}

@end
