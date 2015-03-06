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
    self.tabBarController.navigationItem.title = @"Inbox";
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //Loading spinner
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [QCApi getAllConversationsWithCallBack:^(NSMutableArray *conversationsArray, NSError *error) {
            if (error == nil){
                self.conversations = conversationsArray;
                [self.messageTabView reloadData];
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

// Cell Swipe delete code
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [QCApi deleteConversationWithCompletion:[self.conversations objectAtIndex:indexPath.row] completion:^void(BOOL finished) {
            if (finished) {
                // Remove the row from data model
                [self.conversations removeObjectAtIndex:indexPath.row];
                // Request table view to reload
                [self.messageTabView reloadData];
            }
        }];
    }
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
        [cell.tinklerThumb setImageWithURL: [NSURL URLWithString:tinklerImage.url]];
    }
    
    cell.tinklerThumb.layer.cornerRadius = cell.tinklerThumb.frame.size.width / 2;
    cell.tinklerThumb.clipsToBounds = YES;
    
    //Messages to see in the current conversation
    if(thisConversation.hasUnreadMsg == YES){
        cell.msgNotification.hidden = NO;
        cell.msgNotification.layer.cornerRadius = cell.msgNotification.frame.size.width / 2;
        cell.msgNotification.clipsToBounds = YES;
        [cell.msgNotification setBackgroundColor:[QCApi colorWithHexString:@"73CACD"]];
        [cell.tinklerNameLabel setFont:[UIFont boldSystemFontOfSize:17]];
        [cell.sentDate setFont:[UIFont boldSystemFontOfSize:11]];
    }else{
        cell.msgNotification.hidden = YES;
        [cell.tinklerNameLabel setFont:[UIFont systemFontOfSize:17]];
        [cell.sentDate setFont:[UIFont systemFontOfSize:11]];
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
