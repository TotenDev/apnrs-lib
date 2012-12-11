//
//  AppDelegate.m
//  demo
//
//  Created by Gabriel Pacheco on 12/10/12.
//  Copyright (c) 2012 TotenDev. All rights reserved.
//

#import "AppDelegate.h"

#import "ViewController.h"

#import "APNRSManager.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
	    self.viewController = [[ViewController alloc] initWithNibName:@"ViewController_iPhone" bundle:nil];
	} else {
	    self.viewController = [[ViewController alloc] initWithNibName:@"ViewController_iPad" bundle:nil];
	}
	self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
	//
	[[APNRSManager sharedPushNotifications] setAPNRSLibraryNotificationTypes:(UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound)];
	[[APNRSManager sharedPushNotifications] setAPNRSLibraryRequestUsername:@"clientOI"];
	[[APNRSManager sharedPushNotifications] setAPNRSLibraryRequestPassword:@"man"];
	[[APNRSManager sharedPushNotifications] setAPNRSLibraryRequestEntrypoint:@"10.0.2.5:8080"];
	//
	[[APNRSManager sharedPushNotifications] startRemoteNotificationServicesWithLaunchOptions:launchOptions];
//	[[APNRSManager sharedPushNotifications] setTags:[NSArray arrayWithObjects:@"presunto", nil] withCompletionBlock:^(BOOL success) { }];
	NSLog(@"%@",NSStringFromSelector(_cmd));
	NSLog(@"%@",launchOptions);
    return YES;
}

- (void)application:(UIApplication *)_app didReceiveRemoteNotification:(NSDictionary *)userInfo {
	NSLog(@"%@",NSStringFromSelector(_cmd));
	NSLog(@"%@",userInfo);
	[[APNRSManager sharedPushNotifications] application:_app didReceiveRemoteNotification:userInfo];
}
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
	NSLog(@"%@",NSStringFromSelector(_cmd));
	NSLog(@"%@",error);
	[[APNRSManager sharedPushNotifications] application:application didFailToRegisterForRemoteNotificationsWithError:error];
}
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
	// Get a hex string from the device token with no spaces or < >
	NSString * _deviceToken = [[[[deviceToken description] stringByReplacingOccurrencesOfString:@"<"withString:@""]
															stringByReplacingOccurrencesOfString:@">" withString:@""]
														 stringByReplacingOccurrencesOfString: @" " withString: @""];
	
	NSLog(@"%@",NSStringFromSelector(_cmd));
	NSLog(@"%@",_deviceToken);
	[[APNRSManager sharedPushNotifications] application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
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
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
