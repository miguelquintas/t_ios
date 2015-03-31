//
//  QCInboxDetailViewController.m
//  qrcar
//
//  Created by Diogo Guimarães on 10/10/14.
//  Copyright (c) 2014 Miguel Quintas. All rights reserved.
//

#import "QCInboxDetailViewController.h"

@interface QCInboxDetailViewController ()

@end

@implementation QCInboxDetailViewController

@synthesize selectedConversation = _selectedConversation;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = [_selectedConversation talkingToTinkler][@"name"];
    
    //Set the block conversation button
    UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithTitle:@"Block" style:UIBarButtonItemStylePlain target:self action:@selector(blockConversation)];
    self.navigationItem.rightBarButtonItem = anotherButton;
    
    [self setHasSentMsg:NO];
    
    //We re not using avatars
    self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
    self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
    
    /**
     *  You MUST set your senderId and display name
     */
    self.senderId = [PFUser currentUser].username;
    self.senderDisplayName = @"Me";
    
    /**
     *  Create message bubble images objects.
     *
     *  Be sure to create your bubble images one time and reuse them for good performance.
     *
     */
    JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
    
    self.outgoingBubbleImageData = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleGreenColor]];
    self.incomingBubbleImageData = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
    
    self.messages = [[NSMutableArray alloc] init];
    
    if(_selectedConversation.hasUnreadMsg || _selectedConversation.hasSentMsg){
        [QCApi getOnlineMessages:_selectedConversation:^(NSMutableArray *messagesArray, NSError *error) {
            if (error == nil){
                [self loadMessagesToView:messagesArray];
                [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
            } else {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Connection Failed" message:@"There was an error loading your conversations. Please try again later." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                [alertView show];
            }
        }];
    }else{//load messages from localdatastore
        [QCApi getLocalMessages:_selectedConversation:^(NSMutableArray *localMessagesArray, NSError *error) {
            if (error == nil){
                //If there are any messages stored locally load them
                if (localMessagesArray.count > 0) {
                    [self loadMessagesToView:localMessagesArray];
                }else{//go get the messages online
                    //Validate if there is network connectivity
                    if ([QCApi checkForNetwork]) {
                        [QCApi getOnlineMessages:_selectedConversation:^(NSMutableArray *onlineMessagesArray, NSError *error) {
                            if (error == nil){
                                [self loadMessagesToView:onlineMessagesArray];
                            } else {
                                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Connection Failed" message:@"There was an error loading your conversations. Please try again later." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                                [alertView show];
                            }
                        }];
                    }else{
                        //Warn user that he has no network connection
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"No Network Connection" message:@"You must be online to load received messages." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                        [alertView show];
                    }
                }
            } else {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Connection Failed" message:@"There was an error loading your conversations. Please try again later." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                [alertView show];
            }
        }];
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    if(_hasSentMsg){
        [(QCInboxViewController*)_parentVC setHasSentMsg:YES];
    }
}

- (void) blockConversation{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Block User" message:@"Are you sure you want to block this conversation?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"%ld", (long)buttonIndex);
    if(buttonIndex == 1)
    {
        [QCApi blockConversationWithCompletion:_selectedConversation completion:^void(BOOL finished) {
            if (finished) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Block Confirmation" message:@"This conversation has been blocked" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                [alert show];
                [self.navigationController popViewControllerAnimated:YES];
            }
        }];
    }
}

- (void)loadMessagesToView:(NSMutableArray *) messagesArray{
    [_selectedConversation setConversationMsgs:messagesArray];
    
    //Run through the reversed messages array to have the most recent msgs displayed at the bottom of the screen
    for(QCMessage *message in [[messagesArray reverseObjectEnumerator]allObjects]){
        //Case when its the current user sending an answer through a custom message
        if([[message msgType][@"text"] isEqualToString:@"Custom Message"]){
            JSQMessage *newMessage = [[JSQMessage alloc]initWithSenderId:message.from.username senderDisplayName:@"Tinkler User" date: message.sentDate text:message.msgText];
            [self.messages addObject:newMessage];
        }else {
            JSQMessage *newMessage = [[JSQMessage alloc]initWithSenderId:message.from.username senderDisplayName:@"Tinkler User" date: message.sentDate text:[message msgType][@"text"] ];
            [self.messages addObject:newMessage];
        }
    }
}

- (void) answerPushNotification:(NSString *) messageType :(NSString *) messageToSend{
    
    //Loading spinner
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
    [PFCloud callFunctionInBackground:@"answerPushToUser"
                       withParameters:@{@"userId": _selectedConversation.talkingToUser.objectId, @"messageType": messageType, @"message":messageToSend, @"tinklerId":_selectedConversation.talkingToTinkler.objectId}
                                block:^(NSString *success, NSError *error) {
                                    if (!error) {
                                        // Push sent successfully
                                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                                        [(QCInboxViewController*)_parentVC setHasSentMsg:YES];
                                        NSLog(@"Message Sent Successfully");
                                    }
                                }];
    });
}

//Check the last 2 messages in the stack, if they belong to you it will lock the conversation
- (void)isItToLock{
    QCMessage *message1 = [self.selectedConversation.conversationMsgs objectAtIndex:0];
    QCMessage *message2 = [self.selectedConversation.conversationMsgs objectAtIndex:1];
    if ([message1.from.username isEqualToString:[PFUser currentUser].username] && [message2.from.username isEqualToString:[PFUser currentUser].username]) {
        [QCApi lockConversation:self.selectedConversation];
        _selectedConversation.isLocked = YES;
    }
}

//Check the last 3 messages in the stack, if they belong to the other user it will unlock the conversation
- (void)isItToUnLock{
    QCMessage *message1 = [self.selectedConversation.conversationMsgs objectAtIndex:0];
    QCMessage *message2 = [self.selectedConversation.conversationMsgs objectAtIndex:1];
    QCMessage *message3 = [self.selectedConversation.conversationMsgs objectAtIndex:2];
    if (![message1.from.username isEqualToString:[PFUser currentUser].username] && ![message2.from.username isEqualToString:[PFUser currentUser].username] && ![message3.from.username isEqualToString:[PFUser currentUser].username]) {
        [QCApi unlockConversation:self.selectedConversation];
    }
}

//Check the last 3 messages in the stack, if they belong to the other user it will unlock the conversation
- (void)addMsgToSelConversations:(NSString *) text{
    QCMessage *newMsg = [QCMessage new];
    [newMsg setTargetTinkler:_selectedConversation.talkingToTinkler];
    [newMsg setTo:_selectedConversation.talkingToUser];
    [newMsg setFrom:[PFUser currentUser]];
    [newMsg setMsgText:text];
    
    [_selectedConversation.conversationMsgs insertObject:newMsg atIndex:0];
}

- (void)updateConversationWithReceivedMsg:(NSString *) msgtext{
    //Set the msgs read and the hasSent to TRUE to reload messages
    [QCApi setHasSentMsg:_selectedConversation];
    
    //Unlock Conversation
    [_selectedConversation setIsLocked:NO];
    
    //Update the msg array from the _selected_conversation
    QCMessage *newMsg = [QCMessage new];
    [newMsg setTargetTinkler:_selectedConversation.talkingToTinkler];
    [newMsg setTo:[PFUser currentUser]];
    [newMsg setFrom:_selectedConversation.talkingToUser];
    [newMsg setMsgText:msgtext];
    [_selectedConversation.conversationMsgs insertObject:newMsg atIndex:0];
    
    //Update the msgs in the current view
    JSQMessage *newMessage = [[JSQMessage alloc]initWithSenderId:_selectedConversation.talkingToUser.username senderDisplayName:@"Tinkler User" date:[NSDate date] text:msgtext];
    [self.messages addObject:newMessage];
    [self.collectionView reloadData];
    
    if (self.automaticallyScrollsToMostRecentMessage) {
        [self scrollToBottomAnimated:YES];
    }
    
    //Reload inbox conversations
    [(QCInboxViewController*)_parentVC setHasSentMsg:YES];
}

#pragma mark - JSQMessages CollectionView DataSource

- (void)didPressAccessoryButton:(UIButton *)sender{
    //TODO in the Future
}

- (void)didPressSendButton:(UIButton *)button
           withMessageText:(NSString *)text
                  senderId:(NSString *)senderId
         senderDisplayName:(NSString *)senderDisplayName
                      date:(NSDate *)date
{
    /**
     *  Sending a message. Your implementation of this method should do *at least* the following:
     *
     *  1. Play sound (optional)
     *  2. Add new id<JSQMessageData> object to your data source
     *  3. Call `finishSendingMessage`
     */
    [JSQSystemSoundPlayer jsq_playMessageSentSound];
    
    JSQMessage *message = [[JSQMessage alloc] initWithSenderId:senderId
                                             senderDisplayName:senderDisplayName
                                                          date:date
                                                          text:text];
    
    [self.messages addObject:message];
    
    //Validate if there is network connectivity
    if ([QCApi checkForNetwork]) {
        //Validate if the user allows sending customMsgs
        if ([_selectedConversation.talkingToUser objectForKey:@"allowCustomMsg"]== [NSNumber numberWithBool:YES]) {
            if (!_selectedConversation.isLocked){
                if(_selectedConversation.conversationMsgs.count < 15){
                    if(_selectedConversation.conversationMsgs.count > 1)
                        [self isItToLock];
                    if(_selectedConversation.conversationMsgs.count > 2)
                        [self isItToUnLock];
                }
                [self answerPushNotification:@"Custom Message" :text];
                [self addMsgToSelConversations: text];
                [self finishSendingMessageAnimated:YES];
            }else{
                //Warn user, clean input field and hide keyboard
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Message Send Failed" message:@"This conversation is locked until you get an answer from the other Tinkler user" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                [alertView show];
            }
            
        }else{
            //Warn user, clean input field and hide keyboard
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Message Send Failed" message:@"This user does not allow custom messages" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alertView show];
        }
    }else{
        //Warn user, clean input field and hide keyboard
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Message Send Failed" message:@"You need to have network connectivity to send this message" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alertView show];
    }
    
    
}

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.messages objectAtIndex:indexPath.item];
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  You may return nil here if you do not want bubbles.
     *  In this case, you should set the background color of your collection view cell's textView.
     *
     *  Otherwise, return your previously created bubble image data objects.
     */
    
    JSQMessage *message = [self.messages objectAtIndex:indexPath.item];
    
    if ([message.senderId isEqualToString:self.senderId]) {
        return self.outgoingBubbleImageData;
    }
    
    return self.incomingBubbleImageData;
}

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Return `nil` here if you do not want avatars.
     *  If you do return `nil`, be sure to do the following in `viewDidLoad`:
     *
     *  self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
     *  self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
     *
     *  It is possible to have only outgoing avatars or only incoming avatars, too.
     */
    
    /**
     *  Return your previously created avatar image data objects.
     *
     *  Note: these the avatars will be sized according to these values:
     *
     *  self.collectionView.collectionViewLayout.incomingAvatarViewSize
     *  self.collectionView.collectionViewLayout.outgoingAvatarViewSize
     *
     *  Override the defaults in `viewDidLoad`
     */
//    JSQMessage *message = [self.demoData.messages objectAtIndex:indexPath.item];
//    
//    if ([message.senderId isEqualToString:self.senderId]) {
//        if (![NSUserDefaults outgoingAvatarSetting]) {
//            return nil;
//        }
//    }
//    else {
//        if (![NSUserDefaults incomingAvatarSetting]) {
//            return nil;
//        }
//    }
//    
//    
//    return [self.demoData.avatars objectForKey:message.senderId];
    return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  This logic should be consistent with what you return from `heightForCellTopLabelAtIndexPath:`
     *  The other label text delegate methods should follow a similar pattern.
     *
     *  Show a timestamp for every 3rd message
     */
    if (indexPath.item % 3 == 0) {
        JSQMessage *message = [self.messages objectAtIndex:indexPath.item];
        return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
    }
    
    return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [self.messages objectAtIndex:indexPath.item];
    
    /**
     *  iOS7-style sender name labels
     */
    if ([message.senderId isEqualToString:self.senderId]) {
        return nil;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:message.senderId]) {
            return nil;
        }
    }
    
    /**
     *  Don't specify attributes to use the defaults.
     */
    return [[NSAttributedString alloc] initWithString:message.senderDisplayName];
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.messages count];
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Override point for customizing cells
     */
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    /**
     *  Configure almost *anything* on the cell
     *
     *  Text colors, label text, label colors, etc.
     *
     *
     *  DO NOT set `cell.textView.font` !
     *  Instead, you need to set `self.collectionView.collectionViewLayout.messageBubbleFont` to the font you want in `viewDidLoad`
     *
     *
     *  DO NOT manipulate cell layout information!
     *  Instead, override the properties you want on `self.collectionView.collectionViewLayout` from `viewDidLoad`
     */
    
    JSQMessage *msg = [self.messages objectAtIndex:indexPath.item];
    
    if ([msg isKindOfClass:[JSQMessage class]]) {
        
        if ([msg.senderId isEqualToString:self.senderId]) {
            cell.textView.textColor = [UIColor whiteColor];
        }
        else {
            cell.textView.textColor = [UIColor blackColor];
        }
        
        cell.textView.linkTextAttributes = @{ NSForegroundColorAttributeName : cell.textView.textColor,
                                              NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid) };
    }
    
    return cell;
}



#pragma mark - JSQMessages collection view flow layout delegate

#pragma mark - Adjusting cell label heights

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Each label in a cell has a `height` delegate method that corresponds to its text dataSource method
     */
    
    /**
     *  This logic should be consistent with what you return from `attributedTextForCellTopLabelAtIndexPath:`
     *  The other label height delegate methods should follow similarly
     *
     *  Show a timestamp for every 3rd message
     */
    if (indexPath.item % 3 == 0) {
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
    
    return 0.0f;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  iOS7-style sender name labels
     */
    JSQMessage *currentMessage = [self.messages objectAtIndex:indexPath.item];
    if ([[currentMessage senderId] isEqualToString:self.senderId]) {
        return 0.0f;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:[currentMessage senderId]]) {
            return 0.0f;
        }
    }
    
    return kJSQMessagesCollectionViewCellLabelHeightDefault;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return 0.0f;
}

#pragma mark - Responding to collection view tap events

- (void)collectionView:(JSQMessagesCollectionView *)collectionView
                header:(JSQMessagesLoadEarlierHeaderView *)headerView didTapLoadEarlierMessagesButton:(UIButton *)sender
{
    NSLog(@"Load earlier messages!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapAvatarImageView:(UIImageView *)avatarImageView atIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Tapped avatar!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Tapped message bubble!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapCellAtIndexPath:(NSIndexPath *)indexPath touchLocation:(CGPoint)touchLocation
{
    NSLog(@"Tapped cell at %@!", NSStringFromCGPoint(touchLocation));
}




@end
