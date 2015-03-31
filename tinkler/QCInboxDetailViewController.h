//
//  QCInboxDetailViewController.h
//  qrcar
//
//  Created by Diogo Guimarães on 10/10/14.
//  Copyright (c) 2014 Miguel Quintas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QCApi.h"
#import "QCMessage.h"
#import "QCConversation.h"
#import "JSQMessagesViewController/JSQMessages.h"
#import "MBProgressHUD.h"
#import "QCInboxViewController.h"

@interface QCInboxDetailViewController : JSQMessagesViewController <UIActionSheetDelegate>

@property (strong, nonatomic) UIViewController *parentVC;

//Variables to pass information
@property (nonatomic, strong) QCConversation *selectedConversation;

//Array to have the conversation messages initialized
@property (strong, nonatomic) NSMutableArray *messages;

//User sent a message flag
@property (nonatomic) BOOL hasSentMsg;

- (void)updateConversationWithReceivedMsg:(NSString *) text;

@property (strong, nonatomic) JSQMessagesBubbleImage *outgoingBubbleImageData;

@property (strong, nonatomic) JSQMessagesBubbleImage *incomingBubbleImageData;

@end
