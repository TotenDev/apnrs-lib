//
//  APNRSManager.h
//  apnrs
//
//  Created by Gabriel Pacheco on 12/6/12.
//  Copyright 2011 TotenDev. All rights reserved.
//

#import <UIKit/UIApplication.h>
#import "apnrs.h"

//Main Interface
@interface APNRSManager : NSObject
+ (APNRSManager *)sharedPushNotifications ;

#pragma mark - Fowarders
//Start Remote noticiation app services (MUST BE CALLED IN APP INITIALIZATION)
- (void)startRemoteNotificationServicesWithLaunchOptions:(NSDictionary *)dictionary ;
- (void)application:(UIApplication *)_app didReceiveRemoteNotification:(NSDictionary *)userInfo ;
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error ;
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken ;

#pragma mark - Quiet Time
//Set quiet time
- (void)setQuietTime:(pushQuietTime)quietTime withCompletionBlock:(void(^)(BOOL success))completion ;
//Return current quiet time, or default one
- (pushQuietTime)currentQuietTime ;
#pragma mark - Tag
//Is Tag enabled
- (BOOL)isTagEnabled:(NSString*)tag ;
//Set tag(s) that you want to enable ,if you want to disable,simply do not insert it !
- (void)setTags:(NSArray *)tags withCompletionBlock:(void(^)(BOOL success))completion ;
#pragma mark - Badging
- (void)resetBadges ;
@end