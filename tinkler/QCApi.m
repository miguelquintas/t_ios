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
    
    PFQuery *myTinklers = [PFQuery queryWithClassName:@"Tinkler"];
    [myTinklers whereKey:@"owner" equalTo:[PFUser currentUser]];
    [myTinklers includeKey:@"type"];
    [myTinklers orderByDescending:@"createdAt"];
    
    //Check connectivity
    if([self checkForNetwork]){
        NSLog(@"We have network connectivity");
        [myTinklers findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                // The find succeeded.
                NSLog(@"Successfully retrieved %lu tinklers.", (unsigned long)objects.count);
                
                //Unpin previous objects and then pin new collected ones
                [PFObject unpinAllInBackground:objects withName:@"pinnedTinklers" block:^(BOOL succeeded, NSError *error) {
                    if (!error) {
                        [PFObject pinAllInBackground:objects withName: @"pinnedTinklers"];
                    }else{
                        // Log details of the failure
                        NSLog(@"Error unpinning objects: %@ %@", error, [error userInfo]);
                    }
                }];
                
                block([self createTinklerObj:objects], nil);
                
            } else {
                // Log details of the failure
                NSLog(@"Error quering tinklers: %@ %@", error, [error userInfo]);
                
                block(nil,error);
            }
        }];
        
    }else{
        NSLog(@"We don't have network connectivity");
        
        // Query the Local Datastore
        [myTinklers fromPinWithName:@"pinnedTinklers"];
        [myTinklers findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                // The find succeeded.
                NSLog(@"Successfully retrieved %lu tinklers.", (unsigned long)objects.count);
                
                // Create the tinkler objects to include in the tinkler array
                block([self createTinklerObj:objects], nil);
                
            }else{
                // Log details of the failure
                NSLog(@"Error: %@ %@", error, [error userInfo]);
                
                block(nil,error);
            }
        }];
    }
}

+ (NSMutableArray *) createTinklerObj:(NSArray *) objects{
    NSMutableArray *tinklers = [NSMutableArray new];
    
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
    
    return tinklers;
}

+(void) getAllConversationsWithCallBack:(void (^)(NSMutableArray *conversationsArray, NSError *error))block {
    
    //Query to get the started conversations by the current user
    PFQuery *startedConv = [PFQuery queryWithClassName:@"Conversation"];
    [startedConv whereKey:@"starterUser" equalTo:[PFUser currentUser]];
        
    //Query to get the conversations started by another user
    PFQuery *toConv = [PFQuery queryWithClassName:@"Conversation"];
    [toConv whereKey:@"talkingToUser" equalTo:[PFUser currentUser]];
        
    //Or query to get all this user's conversations
    PFQuery *myConv = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:startedConv,toConv,nil]];
        
    [myConv orderByDescending:@"updatedAt"];
    [myConv includeKey:@"talkingToTinkler"];
    [myConv includeKey:@"starterUser"];
    [myConv includeKey:@"talkingToUser"];
    
    //Check internet connection
    if([self checkForNetwork]){
        [myConv findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                //The find succeeded.
                NSLog(@"Successfully retrieved %lu conversations.", (unsigned long)objects.count);
                
                //Unpin previous objects and then pin new collected ones
                [PFObject unpinAllInBackground:objects withName:@"pinnedConversations" block:^(BOOL succeeded, NSError *error) {
                    if (!error) {
                        [PFObject pinAllInBackground:objects withName: @"pinnedConversations"];
                    }else{
                        // Log details of the failure
                        NSLog(@"Error unpinning objects: %@ %@", error, [error userInfo]);
                    }
                }];
                
                block([self createConversationObj:objects],nil);
            }else{
                // Log details of the failure
                NSLog(@"Error: %@ %@", error, [error userInfo]);
                block(nil,error);
            }
        }];
        
    }else{
        // Query the Local Datastore
        [myConv fromPinWithName:@"pinnedConversations"];
        [myConv findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                //The find succeeded.
                NSLog(@"Successfully retrieved %lu conversations.", (unsigned long)objects.count);
                
                block([self createConversationObj:objects],nil);
            }else{
                // Log details of the failure
                NSLog(@"Error: %@ %@", error, [error userInfo]);
                block(nil,error);
            }
        }];
    }

}

+ (NSMutableArray *) createConversationObj:(NSArray *) objects{
    NSMutableArray *conversations = [NSMutableArray new];
    
    for (PFObject *object in objects) {
        //Create Message Object
        QCConversation *conversation = [QCConversation new];
        [conversation setConversationId:object.objectId];
        [conversation setTalkingToTinkler:[object objectForKey:@"talkingToTinkler"]];
        
        //If the current user started this conversation then set the talkingToUser and the was Deleted values accordingly
        if([[[object objectForKey:@"starterUser"] objectId] isEqualToString:[PFUser currentUser].objectId]){
            [conversation setTalkingToUser:[object objectForKey:@"talkingToUser"]];
            [conversation setWasDeleted:[[object objectForKey:@"wasDeletedByStarter"]boolValue]];
            [conversation setIsLocked:[[object objectForKey:@"isLockedByStarter"]boolValue]];
        }else{
            [conversation setTalkingToUser:[object objectForKey:@"starterUser"]];
            [conversation setWasDeleted:[[object objectForKey:@"wasDeletedByTo"]boolValue]];
            [conversation setIsLocked:[[object objectForKey:@"isLockedByTo"]boolValue]];
        }
        
        if([self checkForNetwork]){
            //Get the messages from the relation "messages"
            // create a relation based on the messages key
            PFRelation *relation = [object relationForKey:@"messages"];
            // generate a query based on that relation
            PFQuery *messagesQuery = [relation query];
            [messagesQuery orderByDescending:@"createdAt"];
            [messagesQuery includeKey:@"type"];
            [messagesQuery includeKey:@"tinkler"];
            [messagesQuery includeKey:@"from"];
            [messagesQuery includeKey:@"to"];
            NSArray *messageObjects =[messagesQuery findObjects];
            
            //Pin queried messages objects
            [PFObject pinAllInBackground:messageObjects withName: @"pinnedMessages"];
            
            //Set the messages array to this conversation
            [conversation setConversationMsgs:[self createMessageObj:messageObjects :conversation]];
            
            //Check blocked conversations and deleted conversations
            if(![[object objectForKey:@"isBlocked"]boolValue] && !conversation.wasDeleted){
                [conversations addObject:conversation];
            }else{
                NSLog(@"This conversation is blocked");
            }
            
        }else{
            // Query the Local Datastore (Parse has a bug with relation queries so we are doing it manually)
            PFQuery *messagesQuery = [PFQuery queryWithClassName:@"Message"];
            [messagesQuery orderByDescending:@"createdAt"];
            [messagesQuery includeKey:@"type"];
            [messagesQuery includeKey:@"tinkler"];
            [messagesQuery includeKey:@"from"];
            [messagesQuery includeKey:@"to"];
            [messagesQuery whereKey:@"tinkler" equalTo:[conversation talkingToTinkler]];
            
            [messagesQuery fromPinWithName:@"pinnedMessages"];
            NSArray *messageObjects =[messagesQuery findObjects];
            
            //Set the messages array to this conversation
            [conversation setConversationMsgs:[self createMessageObj:messageObjects :conversation]];
            
            //Check blocked conversations and deleted conversations
            if(![[object objectForKey:@"isBlocked"]boolValue] && !conversation.wasDeleted){
                [conversations addObject:conversation];
            }else{
                NSLog(@"This conversation is blocked");
            }
        }
    }
    
    return conversations;
}

+ (NSMutableArray *) createMessageObj:(NSArray *) objects :(QCConversation *) conversation{
    NSMutableArray *messages = [NSMutableArray new];
    int countLastSentDate =0;
    for (PFObject *object in objects) {
        
        //Create Message Object
        QCMessage *message = [QCMessage new];
        [message setMessageId:object.objectId];
        [message setMsgType:[object objectForKey:@"type"]];
        [message setMsgText:[object objectForKey:@"customText"]];
        [message setFrom:[object objectForKey:@"from"]];
        [message setTo:[object objectForKey:@"to"]];
        [message setSentDate:object.createdAt];
        [message setTargetTinkler:[object objectForKey:@"tinkler"]];
        [message setIsRead:[[object objectForKey:@"read"]boolValue]];
        
        //Set LastSent Date with the most recent message date
        if(countLastSentDate==0){
            [conversation setLastSentDate:[message messageDateToString:object.createdAt]];
        }
        
        //Set hasUnreadMsg checking if there is any message sent to this user to read
        if([[message to].objectId isEqualToString:[PFUser currentUser].objectId] && ![[object objectForKey:@"read"]boolValue]){
            [conversation setHasUnreadMsg:YES];
        }
        
        [messages addObject:message];
        countLastSentDate++;
    }
    
    return messages;
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
                            completion(YES);
                            NSLog(@"Saved QR-Code and QR-Code Key!");
                            NSLog(@"QR-Code created, saved and sent to the user email");
                        }else
                            NSLog(@"Error saving QR-Code and QR-Code Key!");
                    }];
                }else{
                    NSLog(@"Error getting the new created tinkler!");
                }
            }];
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
    
    if([tinkler tinklerQRCode] != nil)
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

    //Delete all conversations regarding this Tinkler
    PFQuery *conversationsToDelete = [PFQuery queryWithClassName:@"Conversation"];
    [conversationsToDelete whereKey:@"talkingToTinkler" equalTo:tinklerToDelete];
    
    [conversationsToDelete findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            //Delete all found conversations
            for (PFObject *object in objects) {
                [object deleteEventually];
            }
            completion(YES);
        }else
            NSLog(@"Error deleting this tinkler's conversations!");
        
    }];
    
    [tinklerToDelete deleteEventually];
}

+ (void)deleteConversationWithCompletion:(QCConversation *)conversation completion:(void (^)(BOOL finished))completion {
    
    //Get Conversation to delete
    PFQuery *query = [PFQuery queryWithClassName:@"Conversation"];
    PFObject *conversationToDelete = [query getObjectWithId:conversation.conversationId];
    
    //If the current user started this conversation set the deletedbystarter flag to true
    if([[[conversationToDelete objectForKey:@"starterUser"] objectId] isEqualToString:[PFUser currentUser].objectId]){
        [conversationToDelete setObject:[NSNumber numberWithBool:YES] forKey:@"wasDeletedByStarter"];
    }else{
        [conversationToDelete setObject:[NSNumber numberWithBool:YES] forKey:@"wasDeletedByTo"];
    }
    
    [conversationToDelete saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(!error){
            completion(YES);
            NSLog(@"Conversation Eddited!");
        }else{
            NSLog(@"Error deleting conversation!");
        }
    }];
}

+ (void)checkEmailVerifiedWithCompletion:(NSString *)email completion:(void (^)(BOOL finished, BOOL isVerified))completion {

    PFQuery *userToLoginQuery = [PFUser query];
    [userToLoginQuery whereKey:@"email" equalTo:email];
    [userToLoginQuery getFirstObjectInBackgroundWithBlock:^(PFObject *userToValidate, NSError *error) {
        if (!error) {
            // Refresh to make sure the user did not recently verify
            [userToValidate fetch];
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
    PFQuery *myMsgTypes = [PFQuery queryWithClassName:@"MessageType"];
    [myMsgTypes includeKey:@"type"];
    [myMsgTypes orderByAscending:@"createdAt"];
    
    //Check connectivity
    if([self checkForNetwork]){
        NSLog(@"We have network connectivity");
        [myMsgTypes findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                
                //Unpin previous objects and then pin new collected ones
                [PFObject unpinAllInBackground:objects withName:@"pinnedMsgTypes" block:^(BOOL succeeded, NSError *error) {
                    if (!error) {
                        [PFObject pinAllInBackground:objects withName: @"pinnedMsgTypes"];
                    }else{
                        // Log details of the failure
                        NSLog(@"Error unpinning objects: %@ %@", error, [error userInfo]);
                    }
                }];
                
                block([self createMsgTypeObj:objects], nil);
                
            } else {
                // Log details of the failure
                NSLog(@"Error: %@ %@", error, [error userInfo]);
                
                block(nil,error);
            }
        }];
    }else{
        NSLog(@"We are offline");
        // Query the Local Datastore
        [myMsgTypes fromPinWithName:@"pinnedMsgTypes"];
        [myMsgTypes findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                block([self createMsgTypeObj:objects], nil);
                
            } else {
                // Log details of the failure
                NSLog(@"Error: %@ %@", error, [error userInfo]);
                
                block(nil,error);
            }
        }];
    }
    
    
}

+ (NSMutableArray *) createMsgTypeObj:(NSArray *) objects{
    NSMutableArray *msgTypes = [NSMutableArray new];
    
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
    
    return msgTypes;
}

+ (void) getAllTinklerTypesWithCallBack:(void (^)(NSArray *tinklerTypeArray, NSMutableArray *typeNameArray, NSError *error))block{
    PFQuery *myTinklerTypes = [PFQuery queryWithClassName:@"TinklerType"];
    [myTinklerTypes includeKey:@"type"];
    [myTinklerTypes orderByAscending:@"createdAt"];
    //Check connectivity
    if([self checkForNetwork]){
        NSLog(@"We have network connectivity");
        [myTinklerTypes findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                
                //Unpin previous objects and then pin new collected ones
                [PFObject unpinAllInBackground:objects withName:@"pinnedTinklerTypes" block:^(BOOL succeeded, NSError *error) {
                    if (!error) {
                        [PFObject pinAllInBackground:objects withName: @"pinnedTinklerTypes"];
                    }else{
                        // Log details of the failure
                        NSLog(@"Error unpinning objects: %@ %@", error, [error userInfo]);
                    }
                }];
                
                // Add the returned results to the tinkler types array
                block(objects, [self createTinklerTypeObj:objects], nil);
                
            } else {
                // Log details of the failure
                NSLog(@"Error: %@ %@", error, [error userInfo]);
                block(nil, nil, error);
            }
        }];
    }else{
        NSLog(@"We are offline");
        // Query the Local Datastore
        [myTinklerTypes fromPinWithName:@"pinnedTinklerTypes"];
        [myTinklerTypes findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                // Add the returned results to the tinkler types array
                block(objects, [self createTinklerTypeObj:objects], nil);
            } else {
                //Log details of the failure
                NSLog(@"Error: %@ %@", error, [error userInfo]);
                block(nil, nil, error);
            }
        }];
    }
}

+ (NSMutableArray *) createTinklerTypeObj:(NSArray *) objects{
    NSMutableArray *typeNames = [NSMutableArray new];
    
    for (PFObject *object in objects) {
        NSLog(@"%@", object.objectId);
        [typeNames addObject:[object objectForKey:@"typeName"]];
    }
    
    return typeNames;
}

+ (void) editProfileSaveWithCompletion:(BOOL) customMsg completion:(void (^)(BOOL finished))completion {
    
    NSNumber *customMsgAsAnNSNumber = [NSNumber numberWithBool: customMsg ];
    [[PFUser currentUser] setObject:customMsgAsAnNSNumber forKey:@"allowCustomMsg"];
    
    [[PFUser currentUser] saveEventually];
    
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
        
        if (!message.isRead && [[message to].objectId isEqualToString:[PFUser currentUser].objectId]) {
            //query to get this message's record
            PFQuery *query = [PFQuery queryWithClassName:@"Message"];
            [query whereKey:@"to" equalTo:[PFUser currentUser]];
            PFObject *messageToEdit = [query getObjectWithId:message.messageId];
            [messageToEdit setObject:[NSNumber numberWithBool:YES] forKey:@"read"];
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
    PFUser* tinklerOwner = [conversation.talkingToTinkler objectForKey:@"owner"];
    
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
    
    //Update the conversation blocked boolean
    PFQuery *query = [PFQuery queryWithClassName:@"Conversation"];
    PFObject *conversationToEdit = [query getObjectWithId:conversation.conversationId];
    [conversationToEdit setObject:[NSNumber numberWithBool:YES] forKey:@"isBlocked"];
    [conversationToEdit saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(!error){
            NSLog(@"Conversation Eddited!");
            completion(YES);
        }else{
            NSLog(@"Error edditing conversation!");
        }
    }];
    
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

+ (void)lockConversation:(QCConversation *)conversation{
    //Get Conversation to lock
    PFQuery *query = [PFQuery queryWithClassName:@"Conversation"];
    PFObject *conversationToLock = [query getObjectWithId:conversation.conversationId];
    
    //If the current user started this conversation set the islockedbystarter flag to true
    if([[[conversationToLock objectForKey:@"starterUser"] objectId] isEqualToString:[PFUser currentUser].objectId]){
        [conversationToLock setObject:[NSNumber numberWithBool:YES] forKey:@"isLockedByStarter"];
    }else{
        [conversationToLock setObject:[NSNumber numberWithBool:YES] forKey:@"isLockedByTo"];
    }
    
    [conversationToLock saveEventually];
    
}

+ (void)unlockConversation:(QCConversation *)conversation{
    //Get Conversation to unlock
    PFQuery *query = [PFQuery queryWithClassName:@"Conversation"];
    PFObject *conversationToUnlock = [query getObjectWithId:conversation.conversationId];
    
    //If the current user started this conversation set the islockedbyto flag to NO
    if([[[conversationToUnlock objectForKey:@"starterUser"] objectId] isEqualToString:[PFUser currentUser].objectId]){
        [conversationToUnlock setObject:[NSNumber numberWithBool:NO] forKey:@"isLockedByTo"];
    }else{
        [conversationToUnlock setObject:[NSNumber numberWithBool:NO] forKey:@"isLockedByStarter"];
    }
    
    [conversationToUnlock saveEventually];

}

+ (BOOL)checkForNetwork
{
    // check if we've got network connectivity
    Reachability *myNetwork = [Reachability reachabilityWithHostname:@"apple.com"];
    NetworkStatus myStatus = [myNetwork currentReachabilityStatus];
    
    switch (myStatus) {
        case NotReachable:
            NSLog(@"There's no internet connection at all. Display error message now.");
            return NO;
            break;
            
        case ReachableViaWWAN:
            NSLog(@"We have a 3G connection");
            return YES;
            break;
            
        case ReachableViaWiFi:
            NSLog(@"We have WiFi.");
            return YES;
            break;
            
        default:
            return NO;
            break;
    }
}

@end
