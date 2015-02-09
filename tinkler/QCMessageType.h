//
//  QCMessageType.h
//  qrcar
//
//  Created by Diogo Guimarães on 01/11/14.
//  Copyright (c) 2014 Miguel Quintas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Parse/Parse.h"

@interface QCMessageType : NSObject

@property (strong, nonatomic) NSString *msgTypeId;
@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) PFObject *tinklerType;

@end
