//
//  AppDelegate.m
//  FantasyFootball
//
//  Created by Mark Riley on 24/07/2016.
//  Copyright © 2016 MH Riley. All rights reserved.
//

#import "AppDelegate.h"
#import "LeagueViewController.h"
#import "DataManager.h"
#import "TeamManager.h"
#import "Util.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import <AirshipKit/AirshipKit.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [[Fabric sharedSDK] setDebug: YES];
    [Fabric with:@[[Crashlytics class]]];

    self.window.tintColor = [UIColor colorWithRed:44.0/255 green:176.0/255 blue:55.0/255 alpha:1];
    self.rowBackground = [UIColor colorWithRed:253.0/255.0 green:251.0/255.0 blue:248.0/255.0 alpha:1.0];
    self.userBackground = [UIColor colorWithRed:204.0/255 green:255.0/255 blue:217.0/255 alpha:1];
    self.goldBackground = [UIColor colorWithRed:255.0/255 green:215.0/255 blue:0 alpha:1.0];
    self.goldText = [UIColor colorWithRed:255.0/255 green:161.0/255 blue:25.0/255 alpha:1];
    
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:236.0/255 green:246.0/255 blue:234.0/255 alpha:1.0]];
    [[UITabBar appearance] setBarTintColor:[UIColor colorWithRed:236.0/255 green:246.0/255 blue:234.0/255 alpha:1.0]];
    
    setOptionBoolForKey(@"testMode", NO);
    //removeOptionForKey(@"season");
    
    // convert csv weeks data to json weeks data
    /*NSMutableDictionary *weeksJSON = [NSMutableDictionary dictionary];
    weeksJSON[@"SUCCESS"] = @1;
    NSMutableArray *teams = [NSMutableArray array];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Weeks" ofType:@"csv"];
    NSString *fileContents = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    NSArray *lines = [fileContents componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    int i = 1;
    for (NSString *line in lines) {
        if (i == 1) {
            i++;
            continue;
        }
        NSMutableDictionary *team = [NSMutableDictionary dictionary];
        NSArray *columns = [line componentsSeparatedByString:@","];
        team[@"MANAGER"] = columns[0];
        team[@"TEAMNAME"] = columns[1];
        
        NSMutableArray *weeks = [NSMutableArray array];
        for (int i = 1; i <= 40; i++) {
            NSMutableDictionary *week = [NSMutableDictionary dictionary];
            week[@"WK"] = [NSString stringWithFormat:@"%d", i];
            week[@"PTS"] = columns[i+2];
            if (i < 40)
                week[@"GOALS"] = @"0";
            else
                week[@"GOALS"] = columns[44];
            week[@"POS"] = columns[45];
            [weeks addObject:week];
        }
        team[@"WEEKS"] = weeks;
        [teams addObject:team];
        i++;
    }
    weeksJSON[@"DATA"] = teams;
    NSData *JSONData = [NSJSONSerialization dataWithJSONObject:weeksJSON options:0 error:nil];
    NSString *text = [[NSString alloc] initWithData:JSONData encoding:NSUTF8StringEncoding];*/
    
    /*UIUserNotificationSettings* requestedSettings
        = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeBadge
                                                      | UIUserNotificationTypeAlert
                                                      | UIUserNotificationTypeSound)
                                            categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:requestedSettings];*/
    
    [UAirship takeOff];
    [UAirship push].userNotificationTypes = (UIUserNotificationTypeAlert |
                                             UIUserNotificationTypeBadge |
                                             UIUserNotificationTypeSound);
    [UAirship push].userPushNotificationsEnabled = YES;
    
    if (launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]) {
        NSLog(@"Push received");
    }
    if ([self canChangeBadge])
        application.applicationIconBadgeNumber = 0;

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSString *cachePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"cache_league.dat"];
    NSDictionary *cacheData = [NSDictionary dictionaryWithContentsOfFile:cachePath];
    if (cacheData)
        [[TeamManager getInstance] loadLeagueData:cacheData[@"static"]
                                         teamData:cacheData[@"teams"]
                                      overallData:cacheData[@"overall"]
                                     startingData:cacheData[@"starting"]
                                            cache:NO];

    if (application.applicationState != UIApplicationStateBackground)
        [DataManager loadData];
    
    // check max every hour
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:(60 * 10 * 1)];
    
    return YES;
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    [DataManager checkForNewData:completionHandler];
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
    if ([self canChangeBadge])
        application.applicationIconBadgeNumber = 0;
    [DataManager loadData];
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

/*- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
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
}*/

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"Push received");
    if ([self canChangeBadge])
        application.applicationIconBadgeNumber = 0;
}

@end
