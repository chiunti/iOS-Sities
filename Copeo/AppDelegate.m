//
//  AppDelegate.m
//  Copeo
//
//  Created by Chiunti on 17/02/15.
//  Copyright (c) 2015 Chiunti Soft. All rights reserved.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>
#import <GoogleMaps/GoogleMaps.h>
#import "GAI.h"
#import <Pushwoosh/PushNotificationManager.h>


@interface AppDelegate ()<PushNotificationDelegate> {
    PushNotificationManager *pushManager;
}

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // [Optional] Power your app with Local Datastore. For more info, go to
    // https://parse.com/docs/ios_guide#localdatastore/iOS
    [Parse enableLocalDatastore];
    
    // Initialize Parse. test
    //[Parse setApplicationId:@"h9CbWMKOVPCR0QklWX6pfanGFx0NWpmfUwdAZbhb"
    //              clientKey:@"UjfbJ5NZ87IMrvR3NW5Gipg2ohu5ul6dIOgPFWXf"];
    // initialize Parse Copeo
    [Parse setApplicationId:@"8h9rGBxp2yelNGDjr6fiemfVoP1HcbRIV3Zer81u"
                  clientKey:@"B2oDwKIJsAL42kuUURK0v2qURpa2EmTPh3qKHDnU"];

    // [Optional] Track statistics around application opens.
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    // activar google maps
    [GMSServices provideAPIKey:@"AIzaSyB15CghfN-juM9UBv7_SXMZSHC7nGZVcio"];
    
    // google analytics
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    
    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
    [GAI sharedInstance].dispatchInterval = 20;
    
    // Optional: set Logger to VERBOSE for debug information.
    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelVerbose];
    
    // Initialize tracker. Replace with your tracking ID.
    [[GAI sharedInstance] trackerWithTrackingId:@"UA-59432242-2"];
    
    
    //-----------PUSHWOOSH PART-----------
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)])
    {
        // use registerUserNotificationSettings
        // iOS 8 Notifications
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        
        [application registerForRemoteNotifications];
    } else
    {
        // use registerForRemoteNotifications
    }
#else
    // use registerForRemoteNotifications
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes: (UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
#endif
    
    pushManager = [PushNotificationManager pushManager];
    pushManager.delegate = self;
    [pushManager handlePushReceived:launchOptions];
    
    if ([launchOptions objectForKey:UIApplicationLaunchOptionsLocationKey]) {
        
        [pushManager startLocationTracking];
    }
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    
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
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Push Notification Manager

- (void)onDidRegisterForRemoteNotificationsWithDeviceToken:(NSString *)token
{
    NSLog(@"Registered with push token: %@", token);
}

- (void)onDidFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"Failed to register: %@", [error description]);
}

- (void)onPushAccepted:(PushNotificationManager *)pushManager withNotification:(NSDictionary *)pushNotification
{
    [PushNotificationManager clearNotificationCenter];
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    NSLog(@"Received push notification: %@", pushNotification);
    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [pushManager handlePushReceived:userInfo];
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    [pushManager handlePushRegistration:deviceToken];
    NSString *mstrUserPushToken;
    mstrUserPushToken   = [[deviceToken description] stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    mstrUserPushToken   = [mstrUserPushToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"mstrUserPushToken %@", mstrUserPushToken);
}

@end
