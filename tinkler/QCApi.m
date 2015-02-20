//
//  QCApi.m
//  qrcar
//
//  Created by Diogo Guimarães on 08/09/14.
//  Copyright (c) 2014 Miguel Quintas. All rights reserved.
//

#import "QCApi.h"

@implementation QCApi

+ (void) getAllTinklersWithCallBack:(void (^)(NSMutableArray *tinklersArray, NSError *error))block{
    NSMutableArray *tinklers = [[NSMutableArray alloc] init];
    PFQuery *myTinklers = [PFQuery queryWithClassName:@"Tinkler"];
    [myTinklers whereKey:@"owner" equalTo:[PFUser currentUser]];
    [myTinklers includeKey:@"type"];
    
    NSLog(@"Trying to retrieve from cache");
    
    [myTinklers orderByDescending:@"createdAt"];
    [myTinklers findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %lu tinklers.", (unsigned long)objects.count);
            
            // If no objects are loaded in memory, we look to the cache first to fill the table
            // and then subsequently do a query against the network.
            if (objects.count == 0)
                myTinklers.cachePolicy = kPFCachePolicyCacheThenNetwork;
            else
                myTinklers.cachePolicy = kPFCachePolicyNetworkOnly;
            
            // Create the tinkler objects to include in the tinkler array
            for (PFObject *object in objects) {
                NSLog(@"%@", object.objectId);
                QCTinkler *tinkler = [[QCTinkler alloc] init];
                [tinkler setTinklerId:object.objectId];
                [tinkler setTinklerName:[object objectForKey:@"name"]];
                [tinkler setTinklerType:[object objectForKey:@"type"]];
                [tinkler setOwner:[object objectForKey:@"owner"]];
                [tinkler setVehiclePlate:[object objectForKey:@"plate"]];
                [tinkler setVehicleYear:[object objectForKey:@"year"]];
                [tinkler setPetAge:[object objectForKey:@"petAge"]];
                [tinkler setPetBreed:[object objectForKey:@"petBreed"]];
                [tinkler setColor:[object objectForKey:@"color"]];
                [tinkler setBrand:[object objectForKey:@"brand"]];
                [tinkler setTinklerImage:[object objectForKey:@"picture"]];
                [tinkler setTinklerQRCode:[object objectForKey:@"qrCode"]];
                [tinkler setTinklerQRCodeKey:[object objectForKey:@"qrCodeKey"]];
                [tinklers addObject:tinkler];
            }
            
            block(tinklers, nil);
            
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
            
            block(nil,error);
        }
    }];
    
}

+(void) getAllConversationsWithCallBack:(void (^)(NSMutableArray *conversationsArray, NSError *error))block {
    NSMutableArray *conversations = [[NSMutableArray alloc]init];
    
    PFQuery *sentMsgs = [PFQuery queryWithClassName:@"Message"];
    [sentMsgs whereKey:@"from" equalTo:[PFUser currentUser]];
    
    PFQuery *receivedMsgs = [PFQuery queryWithClassName:@"Message"];
    [receivedMsgs whereKey:@"to" equalTo:[PFUser currentUser]];
    
    PFQuery *myMsgs = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:sentMsgs,receivedMsgs,nil]];
    
    NSLog(@"Trying to retrieve from cache");
    
    [myMsgs whereKey:@"deletedByUser" equalTo:[NSNumber numberWithBool:NO]];
    [myMsgs orderByDescending:@"createdAt"];
    [myMsgs includeKey:@"type"];
    [myMsgs includeKey:@"tinkler"];
    [myMsgs includeKey:@"from"];
    [myMsgs includeKey:@"to"];
    [myMsgs findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %lu messages.", (unsigned long)objects.count);
            
            // If no objects are loaded in memory, we look to the cache first to fill the table
            // and then subsequently do a query against the network.
            if (objects.count == 0)
                myMsgs.cachePolicy = kPFCachePolicyCacheThenNetwork;
            else
                myMsgs.cachePolicy = kPFCachePolicyNetworkOnly;
            
            // Create Message objects and group them in Conversation objects
            for (PFObject *object in objects) {
                //Create Message Object
                QCMessage *message = [[QCMessage alloc] init];
                [message setMessageId:object.objectId];
                [message setMsgType:[object objectForKey:@"type"]];
                [message setMsgText:[object objectForKey:@"customText"]];
                [message setFrom:[object objectForKey:@"from"]];
                [message setTo:[object objectForKey:@"to"]];
                [message setSentDate:object.createdAt];
                [message setTargetTinkler:[object objectForKey:@"tinkler"]];
                [message setIsRead:[object objectForKey:@"read"]];
                
                //Check if there are any conversations created
                if (conversations.count == 0){
                    [conversations addObject:[self createNewConversation:message]];
                }else{
                    //Boolean to know if there is a need to create a new conversation
                    Boolean isNew=FALSE;
                    
                    //Run through all the conversations to see if there is the need to create a new one for the current message
                    for(QCConversation *conversation in conversations){
                        //Check if this message belongs to the two intervenients from a conversation
                        if (([message.from.username isEqualToString:conversation.talkingToUser.username] || [message.to.username isEqualToString:conversation.talkingToUser.username])) {
                            //Check if this message's tinkler is the same from the conversation one
                            if([message.targetTinkler.objectId isEqualToString:conversation.talkingToTinkler.objectId]){
                                [conversation.conversationMsgs addObject:message];
                                isNew=FALSE;
                                break;
                            }else{
                                isNew=TRUE;
                            }
                        //Create new conversation
                        }else{
                            isNew =TRUE;
                        }
                    }
                    
                    if (isNew) {
                        [conversations addObject:[self createNewConversation:message]];
                    }
                    
                }
            }
            NSLog(@"Successfully created %lu conversations.", (unsigned long)conversations.count);
            
            //Clear the blocked conversations
            [self getBlockedConversationsWithBlock:conversations:^(NSMutableArray *blkdConversations, NSError *error) {
                if (error == nil){
                    [conversations removeObjectsInArray:blkdConversations];
                    block(conversations,nil);
                } else {
                    NSLog(@"%@", error);
                }
            }];
            
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
            block(nil,error);
        }
    }];
}

+ (void) getBlockedConversationsWithBlock:(NSMutableArray*) conversations :(void (^)(NSMutableArray *blkdConversations, NSError *error))block{
    //Array of blocked conversations to remove
    NSMutableArray *blockedConversations = [NSMutableArray array];
    //Counter
    NSUInteger counter = 0;
    
    
    //Run through all the conversations and remove the blocked ones
    for (QCConversation *conversation in conversations) {
        //Tinkler Object
        PFObject* thisTinkler = conversation.talkingToTinkler;
        //Talking to User
        PFUser* talkingToUser = conversation.talkingToUser;
        counter++;
        
        [self queryBlockedWithCompletion:thisTinkler :talkingToUser completion:^void(BOOL finished, BOOL blocked){
            if (finished) {
                if (blocked) {
                    [blockedConversations addObject:conversation];
                    NSLog(@"This conversation is blocked");
                }else{
                    NSLog(@"This conversation is allowed");
                }
                //Termination clause
                if(conversations.count == counter){
                    NSLog(@"blockedConversations has %lu conversations.", (unsigned long)blockedConversations.count);
                    block(blockedConversations,nil);
                }
            }
        }];
    }
}

+ (void)queryBlockedWithCompletion:(PFObject *) thisTinkler :(PFUser *) talkingToUser completion:(void (^)(BOOL finished, BOOL blocked))completion {
    
    PFUser* tinklerOwner = [thisTinkler objectForKey:@"owner"];
    
    // create a query on the conversation's Tinkler object
    PFQuery *banQuery = [PFQuery queryWithClassName:@"Tinkler"];
    [banQuery whereKey:@"objectId" equalTo:thisTinkler.objectId];
    
    //If the tinkler's owner is the current user check if the talkingToUser is in the banlist
    if([tinklerOwner.objectId isEqualToString:[PFUser currentUser].objectId]){
        [banQuery whereKey:@"ban" equalTo:talkingToUser];
    //else check if the currentuser has been blocked
    }else{
        [banQuery whereKey:@"ban" equalTo:[PFUser currentUser]];
    }
    
    [banQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            if ([objects count] > 0) {
                completion(YES,YES);
            }else{
                completion(YES,NO);
            }
        }else{
            NSLog(@"Error while quering banned users");
        }
    }];
}

+ (QCConversation *)createNewConversation:(QCMessage *) message{
    QCConversation *newConversation = [[QCConversation alloc]init];
    NSMutableArray *messages = [[NSMutableArray alloc]init];
    
    //Case when this is a message from the current user to another user
    if([[PFUser currentUser].username isEqualToString:message.from.username]){
        [newConversation setTalkingToTinkler:message.targetTinkler];
        [newConversation setTalkingToUser:message.to];
        [messages addObject:message];
        [newConversation setConversationMsgs:messages];
        [newConversation setLastSentDate:[message messageDateToString:[message sentDate]]];
        NSLog(@"This message is from user %@ regarding tinkler %@", newConversation.talkingToUser.username, newConversation.talkingToTinkler.objectId);
    }//Case when this is a message from another user to the current user
    else{
        [newConversation setTalkingToTinkler:message.targetTinkler];
        [newConversation setTalkingToUser:message.from];
        [messages addObject:message];
        [newConversation setConversationMsgs:messages];
        [newConversation setLastSentDate:[message messageDateToString:[message sentDate]]];
        NSLog(@"This message is from user %@ regarding tinkler %@", newConversation.talkingToUser.username, newConversation.talkingToTinkler.objectId);
    }
    
    return newConversation;
}

+ (void)sendQrCodeEmail:(NSString *) objectId{
    
    [PFCloud callFunctionInBackground:@"sendEmailQRCode"
                       withParameters:@{@"objectId": objectId}
                                block:^(NSString *success, NSError *error) {
                                    if (!error) {
                                        // Push sent successfully
                                        NSLog(@"Email sent successfully");
                                    }
                                }];
}

+ (void)addTinklerWithCompletion:(QCTinkler *)tinkler completion:(void (^)(BOOL finished))completion {
    
    //Code when adding an entry in the Tinkler table
    //Create initial QR-Code key
    NSNumber *qrCodeKey = [NSNumber numberWithInt:1];
    
    PFObject *tinklerToAdd = [PFObject objectWithClassName:@"Tinkler"];
    [tinklerToAdd setObject:[PFUser currentUser]  forKey:@"owner"];
    [tinklerToAdd setObject:[tinkler tinklerName] forKey:@"name"];
    [tinklerToAdd setObject:[tinkler tinklerType] forKey:@"type"];
    //Add Additional Fields
    if([tinkler vehiclePlate] != nil)
        [tinklerToAdd setObject:[tinkler vehiclePlate] forKey:@"vehiclePlate"];
    
    if([tinkler vehicleYear] != nil)
        [tinklerToAdd setObject:[tinkler vehicleYear] forKey:@"vehicleYear"];
    
    if([tinkler petAge] != nil)
        [tinklerToAdd setObject:[tinkler birthDateToAge: tinkler.petAge] forKey:@"petAge"];
    
    if([tinkler petBreed] != nil)
        [tinklerToAdd setObject:[tinkler petBreed] forKey:@"petBreed"];
    
    if([tinkler brand] != nil)
        [tinklerToAdd setObject:[tinkler brand] forKey:@"brand"];
        
    if([tinkler color] != nil)
        [tinklerToAdd setObject:[tinkler color] forKey:@"color"];
   
    if([tinkler tinklerImage] != nil)
        [tinklerToAdd setObject:[tinkler tinklerImage] forKey:@"picture"];
    [tinklerToAdd saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(!error){
            NSLog(@"Added New Tinkler! We will now create a QR-Code and store it");
            PFQuery *addedTinkler = [PFQuery queryWithClassName:@"Tinkler"];
            [addedTinkler whereKey:@"owner" equalTo:[PFUser currentUser]];
            [addedTinkler whereKey:@"name" equalTo:[tinkler tinklerName]];
            [addedTinkler getFirstObjectInBackgroundWithBlock:^(PFObject *newTinkler, NSError *error) {
                if (!error) {
                    //Save QRCode image to camera roll
                    UIImage *qrCodeImage = [QCQrCode generateQRCode:newTinkler.objectId :qrCodeKey :[tinkler.tinklerType objectForKey:@"typeName"]];
                    UIImageWriteToSavedPhotosAlbum(qrCodeImage, nil, nil, nil);
                    
                    //Save the QR-Code and QR-Code Key in the DB and send email
                    NSData *qrCodeimageData = UIImageJPEGRepresentation(qrCodeImage, 0.05f);
                    PFFile *qrCodeimageFile = [PFFile fileWithName:@"qrCode.jpg" data:qrCodeimageData];
                    
                    [newTinkler setObject:qrCodeimageFile forKey:@"qrCode"];
                    [newTinkler setObject:qrCodeKey forKey:@"qrCodeKey"];
                    [newTinkler saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        if (!error) {
                            //Send QR-Code via email
                            [self sendQrCodeEmail:newTinkler.objectId];
                            NSLog(@"Saved QR-Code and QR-Code Key!");
                        }else
                            NSLog(@"Error saving QR-Code and QR-Code Key!");
                    }];
        
                    NSLog(@"QR-Code created, saved and sent to the user email");
                }else{
                    NSLog(@"Error getting the new created tinkler!");
                }
            }];

            completion(YES);
        }else{
            NSLog(@"Error adding new tinkler!");
        }
    }];
}

+ (void)editTinklerWithCompletion:(QCTinkler *)tinkler completion:(void (^)(BOOL finished))completion {
    
    //Code when edditing an existing object
    PFQuery *query = [PFQuery queryWithClassName:@"Tinkler"];
    PFObject *tinklerToEdit = [query getObjectWithId:tinkler.tinklerId];
    [tinklerToEdit setObject:[tinkler tinklerName] forKey:@"name"];
    [tinklerToEdit setObject:[tinkler tinklerType] forKey:@"type"];
    //Edit Additional Fields
    if([tinkler vehiclePlate] != nil)
        [tinklerToEdit setObject:[tinkler vehiclePlate] forKey:@"vehiclePlate"];
    
    if([tinkler vehicleYear] != nil)
        [tinklerToEdit setObject:[tinkler vehicleYear] forKey:@"vehicleYear"];
    
    if([tinkler petAge] != nil)
        [tinklerToEdit setObject:[tinkler birthDateToAge: tinkler.petAge] forKey:@"petAge"];
    
    if([tinkler petBreed] != nil)
        [tinklerToEdit setObject:[tinkler petBreed] forKey:@"petBreed"];
    
    if([tinkler brand] != nil)
        [tinklerToEdit setObject:[tinkler brand] forKey:@"brand"];
    
    if([tinkler color] != nil)
        [tinklerToEdit setObject:[tinkler color] forKey:@"color"];

    [tinklerToEdit setObject:[tinkler tinklerQRCode] forKey:@"qrCode"];
    [tinklerToEdit setObject:[tinkler tinklerQRCodeKey] forKey:@"qrCodeKey"];
    if([tinkler tinklerImage] != nil)
        [tinklerToEdit setObject:[tinkler tinklerImage] forKey:@"picture"];
    [tinklerToEdit saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(!error){
            completion(YES);
            NSLog(@"Tinkler Eddited!");
        }else{
            NSLog(@"Error edditing tinkler!");
        }
    }];
}

+ (void)deleteTinklerWithCompletion:(QCTinkler *)tinkler completion:(void (^)(BOOL finished))completion {
    // Tinkler to delete
    PFObject *tinklerToDelete = [PFObject objectWithoutDataWithClassName:@"Tinkler"
                                                                objectId:[tinkler tinklerId]];

    //Mark as deleted all messages regarding this Object
    PFQuery *sentMsgs = [PFQuery queryWithClassName:@"Message"];
    [sentMsgs whereKey:@"from" equalTo:[PFUser currentUser]];
    [sentMsgs whereKeyExists:@"customText"];
    [sentMsgs whereKey:@"tinkler" equalTo:tinklerToDelete];
    
    PFQuery *receivedMsgs = [PFQuery queryWithClassName:@"Message"];
    [receivedMsgs whereKey:@"to" equalTo:[PFUser currentUser]];
    [receivedMsgs whereKey:@"tinkler" equalTo:tinklerToDelete];
    
    PFQuery *tinklerMsgs = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:sentMsgs,receivedMsgs,nil]];
    
    [tinklerMsgs findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // Create Message objects and group them in Conversation objects
            for (PFObject *object in objects) {
                [object setObject:[NSNumber numberWithBool:YES] forKey:@"deletedByUser"];
                [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if(!error){
                        NSLog(@"Message marked as deleted");
                    }else{
                        NSLog(@"Error marking as deleted tinkler!");
                    }
                }];
            }
        }else
            NSLog(@"Error deleting this tinkler's messages!");
        
    }];
    
    [tinklerToDelete deleteEventually];
    
    completion(YES);
}

+ (void)checkEmailVerifiedWithCompletion:(NSString *)email completion:(void (^)(BOOL finished, BOOL isVerified))completion {

    PFQuery *userToLoginQuery = [PFUser query];
    [userToLoginQuery whereKey:@"email" equalTo:email];
    [userToLoginQuery getFirstObjectInBackgroundWithBlock:^(PFObject *userToValidate, NSError *error) {
        if (!error) {
            // Refresh to make sure the user did not recently verify
            [userToValidate refresh];
            if([[userToValidate objectForKey:@"emailVerified"] boolValue])
                completion(YES, YES);
            else
                completion(YES, NO);
            NSLog(@"Email verification completed");
        }else{
            completion(YES, NO);
            NSLog(@"Error getting the new registered user!");
        }
    }];
}

+ (void) getMessageTypesWithCallBack:(void (^)(NSMutableArray *msgTypeArray, NSError *error))block{
    NSMutableArray *msgTypes = [[NSMutableArray alloc] init];
    PFQuery *myMsgTypes = [PFQuery queryWithClassName:@"MessageType"];
    [myMsgTypes includeKey:@"type"];
    NSLog(@"Trying to retrieve from cache");
    
    [myMsgTypes orderByAscending:@"createdAt"];
    [myMsgTypes findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            
            // If no objects are loaded in memory, we look to the cache first to fill the table
            // and then subsequently do a query against the network.
            if (objects.count == 0)
                myMsgTypes.cachePolicy = kPFCachePolicyCacheThenNetwork;
            else
                myMsgTypes.cachePolicy = kPFCachePolicyNetworkOnly;
            
            // Add the returned results to the msg types array
            for (PFObject *object in objects) {
                NSLog(@"%@", object.objectId);
                //Create Message Object
                QCMessageType *msgType = [[QCMessageType alloc] init];
                [msgType setMsgTypeId:object.objectId];
                [msgType setText:[object objectForKey:@"text"]];
                [msgType setTinklerType:[object objectForKey:@"type"]];
                [msgTypes addObject:msgType];
            }
            
            block(msgTypes, nil);
            
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
            
            block(nil,error);
        }
    }];
}

+ (void) getAllTinklerTypesWithCallBack:(void (^)(NSArray *tinklerTypeArray, NSMutableArray *typeNameArray, NSError *error))block{
    NSMutableArray *typeNames = [[NSMutableArray alloc] init];
    PFQuery *myTinklerTypes = [PFQuery queryWithClassName:@"TinklerType"];
    NSLog(@"Trying to retrieve from cache");
    [myTinklerTypes includeKey:@"type"];
    
    [myTinklerTypes orderByAscending:@"createdAt"];
    [myTinklerTypes findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            
            // If no objects are loaded in memory, we look to the cache first to fill the table
            // and then subsequently do a query against the network.
            if (objects.count == 0)
                myTinklerTypes.cachePolicy = kPFCachePolicyCacheThenNetwork;
            else
                myTinklerTypes.cachePolicy = kPFCachePolicyNetworkOnly;
            
            // Add the returned results to the tinkler types array
            for (PFObject *object in objects) {
                NSLog(@"%@", object.objectId);
                [typeNames addObject:[object objectForKey:@"typeName"]];
            }
            
            block(objects, typeNames, nil);
            
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
            
            block(nil, nil, error);
        }
    }];
}

+ (void) editProfileSaveWithCompletion:(NSString *)name :(BOOL) customMsg completion:(void (^)(BOOL finished))completion {
    
    [[PFUser currentUser] setObject:name forKey:@"name"];
    
    NSNumber *customMsgAsAnNSNumber = [NSNumber numberWithBool: customMsg ];
    [[PFUser currentUser] setObject:customMsgAsAnNSNumber forKey:@"allowCustomMsg"];
    
    [[PFUser currentUser] saveInBackground];
    
    completion(YES);
}

+ (void) validateObjectsQrCodeWithCompletion:(NSString *)objectId :(NSNumber *)objectKey completion:(void (^)(BOOL finished, BOOL isValidated, BOOL allowCustom, BOOL isBlocked, BOOL isSelfTinkler))completion{
    //Validate this Tinkler's QRCode Key and Custom Message's Flag
    PFQuery *queryToValidate = [PFQuery queryWithClassName:@"Tinkler"];
    [queryToValidate includeKey:@"owner"];
    
    [queryToValidate getObjectInBackgroundWithId:objectId block:^(PFObject *tinklerObject, NSError *error) {
        if (!error) {
            // create a relation based on the banned users key
            PFRelation *relation = [tinklerObject relationForKey:@"ban"];
            // generate a query based on that relation
            PFQuery *blockedQuery = [relation query];
            [blockedQuery whereKey:@"email" equalTo:[[PFUser currentUser]username]];
            [blockedQuery findObjectsInBackgroundWithBlock:^(NSArray *banObjects, NSError *error) {
                if (!error) {
                    if ([[PFUser currentUser].username isEqualToString:[[tinklerObject objectForKey:@"owner"]username]]){
                        completion(YES, NO, NO, NO, YES);
                        NSLog(@"Tinkler belongs to current user - QR-Code not valid");
                    }else if(banObjects.count > 0){
                        completion(YES, NO, NO, YES, NO);
                        NSLog(@"Tinkler exists - This conversation channel is blocked");
                    }else if(!([tinklerObject objectForKey:@"qrCodeKey"] == objectKey)){
                        completion(YES, NO, NO, NO, NO);
                        NSLog(@"Tinkler exists - QR-Code not valid");
                    }else if (([tinklerObject objectForKey:@"qrCodeKey"] == objectKey) && ([[tinklerObject objectForKey:@"owner"] objectForKey:@"allowCustomMsg"]== [NSNumber numberWithBool:YES])){
                        completion(YES, YES, YES, NO, NO);
                        NSLog(@"Tinkler exists - QR-Code valid and user allows custom msgs");
                    }else if (([tinklerObject objectForKey:@"qrCodeKey"] == objectKey) && ([[tinklerObject objectForKey:@"owner"] objectForKey:@"allowCustomMsg"]== [NSNumber numberWithBool:NO])){
                        completion(YES, YES, NO, NO, NO);
                        NSLog(@"Tinkler exists - QR-Code valid and user doesnt allow custom msgs");
                    }
                }else{
                    NSLog(@"Error querying the banned users");
                }
            }];
        
        }else{
            completion(YES, NO, NO, NO, NO);
            NSLog(@"Error querying the scanned Tinkler");
        }
    }];
}

+ (void) setMessagesAsRead:(NSMutableArray *) messages{
    //Run through all the seen messages and update the "read" field to true
    for (QCMessage *message in messages) {
        
        if (message.isRead == 0) {
            //query to get this message's record
            PFQuery *query = [PFQuery queryWithClassName:@"Message"];
            [query whereKey:@"to" equalTo:[PFUser currentUser]];
            PFObject *messageToEdit = [query getObjectWithId:message.messageId];
            [messageToEdit saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if(!error){
                    NSLog(@"Message Eddited!");
                }else{
                    NSLog(@"Error edditing message!");
                }
            }];
        }
    }
}

+ (void)blockConversationWithCompletion:(QCConversation *) conversation completion:(void (^)(BOOL finished))completion {
    
    //Set Relationship "Ban" between talkingToUser and TalkingToTinklers
    
    PFUser* tinklerOwner = [conversation.talkingToTinkler  objectForKey:@"owner"];
    
    //Create a relation to associate the banned user with the tinkler's conversation
    PFRelation *relation = [conversation.talkingToTinkler relationForKey:@"ban"];
    
    //If the tinkler's owner is the current user add the talkingToUser to the ban
    if([tinklerOwner.objectId isEqualToString:[PFUser currentUser].objectId]){
        [relation addObject:conversation.talkingToUser];
    }else{
        [relation addObject:[PFUser currentUser]];
    }
    
    // save the tinkler object
    [conversation.talkingToTinkler saveInBackground];
    completion(YES);
    
}

+ (UIColor*)colorWithHexString:(NSString*)hex
{
    NSString *cString = [[hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor grayColor];
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    
    if ([cString length] != 6) return  [UIColor grayColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}

@end
