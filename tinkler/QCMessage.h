//
//  QCMessage.h
//  qrcar
//
//  Created by Diogo Guimarães on 15/09/14.
//  Copyright (c) 2014 Miguel Quintas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Parse/Parse.h"

@interface QCMessage : NSObject

@property (strong, nonatomic) NSString *messageId;
@property (strong, nonatomic) PFObject *msgType;
@property (strong, nonatomic) NSString *msgText;
@property (strong, nonatomic) PFUser *from;
@property (strong, nonatomic) PFUser *to;
@property (strong, nonatomic) PFObject *targetTinkler;
@property (strong, nonatomic) NSDate *sentDate;
@property (strong, nonatomic) NSNumber *isRead;

- (NSString *) messageDateToString:(NSDate *) messageDate;
- (NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime;
@end
