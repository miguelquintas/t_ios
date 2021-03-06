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
#import "Reachability.h"

@interface QCApi : NSObject
+(void) getLocalConversations:(void (^)(NSMutableArray *conversationsArray, NSError *error))block;
+(void) getOnlineConversations:(void (^)(NSMutableArray *conversationsArray, NSError *error))block;
+(void) getLocalMessages:(QCConversation *) conversation :(void (^)(NSMutableArray *messagesArray, NSError *error))block;
+(void) getOnlineMessages:(QCConversation *) conversation :(void (^)(NSMutableArray *messagesArray, NSError *error))block;
+ (void) getLocalTinklers:(void (^)(NSMutableArray *tinklersArray, NSError *error))block;
+ (void) getOnlineTinklers:(void (^)(NSMutableArray *tinklersArray, NSError *error))block;
+(void) setHasSentMsg:(QCConversation *) conversation;
+ (void)addTinklerWithCompletion:(QCTinkler *)tinkler completion:(void (^)(BOOL finished))completion;
+ (void)editTinklerWithCompletion:(QCTinkler *)tinkler completion:(void (^)(BOOL finished))completion;
+ (void)deleteTinklerWithCompletion:(QCTinkler *)tinkler completion:(void (^)(BOOL finished))completion;
+ (void)deleteConversationWithCompletion:(QCConversation *)conversation completion:(void (^)(BOOL finished))completion;
+ (void)checkEmailVerifiedWithCompletion:(NSString *)email completion:(void (^)(BOOL finished, BOOL isVerified))completion;
+ (void) getLocalMessageTypes:(void (^)(NSMutableArray *msgTypeArray, NSError *error))block;
+ (void) getOnlineMessageTypes:(void (^)(NSMutableArray *msgTypeArray, NSError *error))block;
+ (void) getLocalTinklerTypes:(void (^)(NSArray *tinklerTypeArray, NSMutableArray *typeNameArray, NSError *error))block;
+ (void) getOnlineTinklerTypes:(void (^)(NSArray *tinklerTypeArray, NSMutableArray *typeNameArray, NSError *error))block;
+ (void) editProfileSaveWithCompletion:(BOOL) customMsg completion:(void (^)(BOOL finished))completion;
+ (void) validateObjectsQrCodeWithCompletion:(NSString *)objectId :(NSNumber *)objectKey completion:(void (^)(BOOL finished, BOOL isValidated, BOOL allowCustom, BOOL isBlocked, BOOL isSelfTinkler))completion;
+ (void)sendQrCodeEmail:(NSString *) objectId;
+ (void)blockConversationWithCompletion:(QCConversation *) conversation completion:(void (^)(BOOL finished))completion;
+ (UIColor*)colorWithHexString:(NSString*)hex;
+ (BOOL)checkForNetwork;
+ (void)lockConversation:(QCConversation *)conversation;
+ (void)unlockConversation:(QCConversation *)conversation;

@end
