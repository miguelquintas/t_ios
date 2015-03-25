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
    if(notificationPayload) {
        //Load new messages in inbox VC here
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Test" message:self.window.rootViewController delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alertView show];
//        UIStoryboard *storyBoard = self.window.rootViewController.storyboard;
//        TKTutorialViewController *vc = (TKTutorialViewController *)[storyBoard instantiateViewControllerWithIdentifier:@"TabViewController"];
//        UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController: vc];
//        self.window.rootViewController = navVC;
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
    
    NSLog(@"currentInstallation %@", currentInstallation);
    
    [currentInstallation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        NSLog(@"success : %d  with error : %@",succeeded,error);
    }];
    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
//    [PFPush handlePush:userInfo];
    if ([PFUser currentUser] != nil)
    {
        //If inside Inbox tab refresh the conversation list
        
        //if inside a chat show push note
        
        //else show push note and change inbox icon to alert notifications
    }
    // the userInfo dictionary usually contains the same information as the notificationPayload dictionary
    //        NSLog(@"Estou no %@", ((UITabBarController*)self.window.rootViewController).selectedViewController);
    //        NSLog(@"Estou no %@", ((UINavigationController*)self.window.rootViewController).visibleViewController);
    //        UINavigationController *navController = [UINavigationController new];
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
    application.applicationIconBadgeNumber = 0;
    
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
