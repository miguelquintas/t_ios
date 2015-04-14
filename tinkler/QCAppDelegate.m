//
//  QCAppDelegate.m
//  qrcar
//
//  Created by Miguel Quintas on 04/03/14.
//  Copyright (c) 2014 Miguel Quintas. All rights reserved.
//

#import "QCAppDelegate.h"

@implementation QCAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //Parse code
    //Enable Pinning
    [Parse enableLocalDatastore];
    [Parse setApplicationId:@"cw3jgrLq6MFIDoaYln4DEKDsJeUIF3GACepXNiMN"
                  clientKey:@"zqfETbeQXwLqDvcZeW0OHYnbPkpcmFt7VTRG6Roh"];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    // Register for Push Notitications, if running iOS 8
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                        UIUserNotificationTypeBadge |
                                                        UIUserNotificationTypeSound);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                                 categories:nil];
        [application registerUserNotificationSettings:settings];
        [application registerForRemoteNotifications];
    } else {
        // Register for Push Notifications before iOS 8
        [application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                         UIRemoteNotificationTypeAlert |
                                                         UIRemoteNotificationTypeSound)];
    }
    
    // Extract the notification data
    NSDictionary *notificationPayload = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
    //If there is something in the notification payload go to the Inbox Tab
    if(notificationPayload || application.applicationIconBadgeNumber>0) {
        //Set PushNotification Preference ON
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setBool:YES forKey:@"hasReceivedMsg"];
        [defaults synchronize];
    }
    
    [[UINavigationBar appearance] setBarTintColor:[QCApi colorWithHexString:@"00CEBA"]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName]];
    
    CGSize imageSize = CGSizeMake(40, 40);
    UIGraphicsBeginImageContextWithOptions(imageSize, YES, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [[QCApi colorWithHexString:@"00CEBA"] setFill];
    CGContextFillRect(context, CGRectMake(0, 0, imageSize.width, imageSize.height));
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [[UITabBar appearance] setBackgroundImage:image];
    [[UITabBar appearance] setTintColor:[QCApi colorWithHexString:@"EE463E"]];
    [application setStatusBarStyle:UIStatusBarStyleLightContent];
    [application setStatusBarHidden:NO];
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    currentInstallation.channels = @[ @"global" ];
    
    [currentInstallation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//        NSLog(@"success : %d  with error : %@",succeeded,error);
    }];
    
}

- (UIViewController*)topViewController {
    return [self topViewControllerWithRootViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

- (UIViewController*)topViewControllerWithRootViewController:(UIViewController*)rootViewController {
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController* tabBarController = (UITabBarController*)rootViewController;
        return [self topViewControllerWithRootViewController:tabBarController.selectedViewController];
    } else if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController* navigationController = (UINavigationController*)rootViewController;
        return [self topViewControllerWithRootViewController:navigationController.visibleViewController];
    } else if (rootViewController.presentedViewController) {
        UIViewController* presentedViewController = rootViewController.presentedViewController;
        return [self topViewControllerWithRootViewController:presentedViewController];
    } else {
        return rootViewController;
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    // [PFPush handlePush:userInfo];
    // the userInfo dictionary usually contains the same information as the notificationPayload dictionary
    if ([PFUser currentUser])
    {
        NSString *sound = [userInfo objectForKey:@"aps"][@"sound"];
        NSLog(@"Received Push Sound: %@", sound);
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        
        NSLog(@"ViewController %@",[self topViewController]);
        NSLog(@"USER INFO  %@",userInfo);
        //If inside Inbox tab load new messages
        if ([[self topViewController] isKindOfClass:[QCInboxViewController class]]){
            [(QCInboxViewController *)[self topViewController] receivePushNotifications];
        //if inside a chat show push note and load new messages
        }else if ([[self topViewController] isKindOfClass:[QCInboxDetailViewController class]]){
            QCInboxDetailViewController * presentVC = (QCInboxDetailViewController *)[self topViewController];
            QCConversation * currentConversations = presentVC.selectedConversation;
            
            if([currentConversations.talkingToUser.objectId isEqualToString:[userInfo objectForKey:@"from"]] && [currentConversations.talkingToTinkler.objectId isEqualToString:[userInfo objectForKey:@"tinkler"]]){
                [presentVC updateConversationWithReceivedMsg:[userInfo objectForKey:@"message"]];
            }else{
                [presentVC setHasSentMsg:YES];
                [AGPushNoteView showWithNotificationMessage:[userInfo objectForKey:@"aps"][@"alert"]];
            }
        //else show push note, load new messages and change inbox icon to alert notifications
        }else{
            [AGPushNoteView showWithNotificationMessage:[userInfo objectForKey:@"aps"][@"alert"]];
            //Set PushNotification Preference ON
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setBool:YES forKey:@"hasReceivedMsg"];
            [defaults synchronize];
        }
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    //If the badge has not been cleand go to the Inbox Tab and load new messages
    if(application.applicationIconBadgeNumber>0) {
        //Set PushNotification Preference ON
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setBool:YES forKey:@"hasReceivedMsg"];
        [defaults synchronize];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
