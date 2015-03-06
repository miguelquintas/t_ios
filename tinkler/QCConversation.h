//
//  QCConversation.h
//  qrcar
//
//  Created by Diogo Guimarães on 25/10/14.
//  Copyright (c) 2014 Miguel Quintas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "QCMessage.h"

@interface QCConversation : NSObject

@property (strong, nonatomic) NSString *conversationId;
@property (strong, nonatomic) PFUser *talkingToUser;
@property (strong, nonatomic) PFObject *talkingToTinkler;
@property (strong, nonatomic) NSMutableArray *conversationMsgs;
@property (strong, nonatomic) NSString *lastSentDate;
@property (nonatomic) Boolean hasUnreadMsg;
@property (nonatomic) Boolean wasDeleted;

@end
