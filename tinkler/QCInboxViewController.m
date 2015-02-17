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
        [QCApi getAllConversationsWithCallBack:^(NSArray *conversationsArray, NSError *error) {
            if (error == nil){
                self.conversations = conversationsArray;
                [self.messageTabView reloadData];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                });
            } else {
                NSLog(@"%@", error);
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
    
    cell.tinklerNameLabel.text = [thisConversation talkingToTinkler][@"name"];
    //Get the proper date format
    cell.sentDate.text = thisConversation.lastSentDate;
    
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
