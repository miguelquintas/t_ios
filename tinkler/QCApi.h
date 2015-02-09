//
//  QCApi.h
//  qrcar
//
//  Created by Diogo Guimarães on 08/09/14.
//  Copyright (c) 2014 Miguel Quintas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QCTinkler.h"
#import "QCTinklerType.h"
#import "QCMessage.h"
#import "QCMessageType.h"
#import "QCConversation.h"
#import "QCQrCode.h"

@interface QCApi : NSObject
+ (QCConversation *)createNewConversation:(QCMessage *) message;
+ (void) getAllConversationsWithCallBack:(void (^)(NSMutableArray *conversationsArray, NSError *error))block ;
+ (void) getAllTinklersWithCallBack:(void (^)(NSMutableArray *tinklersArray, NSError *error))block;
+ (void)addTinklerWithCompletion:(QCTinkler *)tinkler completion:(void (^)(BOOL finished))completion;
+ (void)editTinklerWithCompletion:(QCTinkler *)tinkler completion:(void (^)(BOOL finished))completion;
+ (void)deleteTinklerWithCompletion:(QCTinkler *)tinkler completion:(void (^)(BOOL finished))completion;
+ (void)checkEmailVerifiedWithCompletion:(NSString *)email completion:(void (^)(BOOL finished, BOOL isVerified))completion;
+ (void) getMessageTypesWithCallBack:(void (^)(NSMutableArray *msgTypeArray, NSError *error))block;
+ (void) getAllTinklerTypesWithCallBack:(void (^)(NSArray *tinklerTypeArray, NSMutableArray *typeNameArray, NSError *error))block;
+ (void) editProfileSaveWithCompletion:(NSString *)name :(BOOL) customMsg completion:(void (^)(BOOL finished))completion;
+ (void) validateObjectsQrCodeWithCompletion:(NSString *)objectId :(NSNumber *)objectKey completion:(void (^)(BOOL finished, BOOL isValidated, BOOL allowCustom, BOOL isBlocked, BOOL isSelfTinkler))completion;
+ (void)sendQrCodeEmail:(NSString *) objectId;
+ (void) setMessagesAsRead:(NSMutableArray *) messages;
+ (void) getBlockedConversationsWithBlock:(NSMutableArray*) conversations :(void (^)(NSMutableArray *blkdConversations, NSError *error))block;
+ (void)queryBlockedWithCompletion:(PFObject *) thisTinkler :(PFUser *) talkingToUser completion:(void (^)(BOOL finished, BOOL blocked))completion;
+ (void)blockConversationWithCompletion:(QCConversation *) conversation completion:(void (^)(BOOL finished))completion;

@end
