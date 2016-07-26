//
//  AppDelegate.m
//  FantasyFootball
//
//  Created by Mark Riley on 24/07/2016.
//  Copyright © 2016 MH Riley. All rights reserved.
//

#import "AppDelegate.h"
#import "LeagueViewController.h"
#import "SettingsManager.h"
#import <AirshipKit/AirshipKit.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;
    //UINavigationController *navigationController = [tabBarController viewControllers][0];
    //LeagueViewController *teamViewController = [navigationController viewControllers][0];
    
    self.window.tintColor = [UIColor colorWithRed:44.0/255 green:176.0/255 blue:55.0/255 alpha:1];
    self.rowBackground = [UIColor colorWithRed:253.0/255.0 green:251.0/255.0 blue:248.0/255.0 alpha:1.0];
    self.userBackground = [UIColor colorWithRed:204.0/255 green:255.0/255 blue:217.0/255 alpha:1];
    
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:236.0/255 green:246.0/255 blue:234.0/255 alpha:1.0]];
    [[UITabBar appearance] setBarTintColor:[UIColor colorWithRed:236.0/255 green:246.0/255 blue:234.0/255 alpha:1.0]];
    
    UIUserNotificationSettings* requestedSettings
        = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeBadge
                                                      | UIUserNotificationTypeAlert
                                                      | UIUserNotificationTypeSound)
                                            categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:requestedSettings];
    
    [UAirship takeOff];
    [UAirship push].userPushNotificationsEnabled = YES;
    
    [SettingsManager loadSettings];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [SettingsManager loadSettings];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (bool) canChangeBadge {
    UIUserNotificationSettings* notificationSettings = [[UIApplication sharedApplication] currentUserNotificationSettings];
    return (notificationSettings.types & UIUserNotificationTypeBadge);
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"Remote notif success: %@", [deviceToken description]);
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Remote notif failure: %@", [error description]);
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    NSLog(@"Can send push: %@", (notificationSettings.types & UIUserNotificationTypeAlert) ? @"yes" : @"no");
    NSLog(@"Can set badge: %@", (notificationSettings.types & UIUserNotificationTypeBadge) ? @"yes" : @"no");
    NSLog(@"Can play sound: %@", (notificationSettings.types & UIUserNotificationTypeSound) ? @"yes" : @"no");
    
    //NSLog(@"Push status: %d", [[UIApplication sharedApplication] isRegisteredForRemoteNotifications]);
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}

@end
