//
//  APNRSManager.m
//  apnrs
//
//  Created by Gabriel Pacheco on 12/6/12.
//  Copyright 2011 TotenDev. All rights reserved.
//

#import "APNRSManager.h"
#import "_APNRSStorage.h"
#import "_APNRSConnectionsQueue.h"
#import "privateDefinitions.h"

//Helper Functions
pushQuietTime pushQuietTimeMake(int _fromHour,int _fromMinute,int _toHour,int _toMinute) {
	pushQuietTime time; time.fromHour = _fromHour; time.fromMinute = _fromMinute; time.toHour = _toHour; time.toMinute = _toMinute;
	return time;
}
pushQuietTime pushQuietTimeMakeZero(void) {
	pushQuietTime time; time.fromHour = 0; time.fromMinute = 0; time.toHour = 0; time.toMinute = 0;
	return time;
}
BOOL pushQuietTimeIsZero(pushQuietTime quietTime) {
	if (quietTime.toHour == 0 && quietTime.fromHour == 0 &&
      quietTime.toMinute == 0 && quietTime.fromMinute == 0) { return YES ; }
	return NO;
}
BOOL pushQuietTimeIsEqual(pushQuietTime quietTime,pushQuietTime quietTime2) {
	if (quietTime.toHour == quietTime2.toHour && quietTime.fromHour == quietTime2.fromHour &&
      quietTime.toMinute == quietTime2.toMinute && quietTime.fromMinute == quietTime2.fromMinute) { return YES ; }
	return NO;
}



//Private Interface
@interface APNRSManager (/*private*/) {
	_APNRSStorage *_apnrsStorage ;
	_APNRSConnectionsQueue *_apnrsQueue;
} @end



//Main Implementation
@implementation APNRSManager
@synthesize server_entrypoint, server_password, server_username, errorInRegisterNotificationsString, notificationTypes, shouldUseSSL;
+ (void)resetStorage {
  [[NSFileManager defaultManager] removeItemAtPath:APNRSLibraryStorageFile error:nil];
}
#pragma mark - Initialization
static APNRSManager *_sharedPushNotifications = nil ;
//shared push notifications
+ (APNRSManager *)sharedPushNotifications {
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{ _sharedPushNotifications = [[self alloc] init]; });
	return _sharedPushNotifications;
}
- (id)init {
	if ((self = [super init])) {
    //Ivars
		_apnrsStorage = [_APNRSStorage new];
		_apnrsQueue = [_APNRSConnectionsQueue new];
		//defaults
		errorInRegisterNotificationsString = @"Could not register your device to recieve push notifications, try again later.";
		notificationTypes = UIRemoteNotificationTypeAlert;
    shouldUseSSL = NO ;
    //Register app for notifications
    [[UIApplication sharedApplication]registerForRemoteNotificationTypes:notificationTypes];
	}
	return self ;
}
#pragma mark - Badging
- (void)resetBadges {
	//Reset app badge
	[[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}
#pragma mark - Quiet Time
//Set quiet time
- (void)setQuietTime:(pushQuietTime)quietTime withCompletionBlock:(void(^)(BOOL success))completion {
	_apnrsStorage.quietTime = quietTime;
	[_apnrsQueue __queueRegisterWithStorage:_apnrsStorage completionBlock:^(BOOL isOkay) { completion(isOkay); }];
}
//Return current quiet time, or default one
- (pushQuietTime)currentQuietTime { return [_apnrsStorage quietTime]; }
#pragma mark - Tag
//Is Tag enabled
- (BOOL)isTagEnabled:(NSString*)tag { return [[_apnrsStorage tags] containsObject:tag]; }
//Set tag(s) that you want to enable ,if you want to disable,simply do not insert it !
- (void)setTags:(NSArray *)tags withCompletionBlock:(void(^)(BOOL success))completion {
	_apnrsStorage.tags = tags;
	[_apnrsQueue __queueRegisterWithStorage:_apnrsStorage completionBlock:^(BOOL isOkay) { completion(isOkay); }];
}
#pragma mark - Fowarders
- (void)startRemoteNotificationServicesWithLaunchOptions:(NSDictionary *)dictionary {
	//Checks
	if (!server_entrypoint || [server_entrypoint length] <= 0) {
		[[NSException exceptionWithName:@"APNRSLibraryRequestEntrypoint isn't set." reason:@"APNRSLibraryRequestEntrypoint isn't set." userInfo:nil] raise];
	}else if (!server_username || [server_username length] <= 0) {
		[[NSException exceptionWithName:@"APNRSLibraryRequestUsername isn't set." reason:@"APNRSLibraryRequestUsername isn't set." userInfo:nil] raise];
	}else if (!server_password || [server_password length] <= 0) {
		[[NSException exceptionWithName:@"APNRSLibraryRequestPassword isn't set." reason:@"APNRSLibraryRequestPassword isn't set." userInfo:nil] raise];
	}
	
	//Check if contains push key dict
	if ([dictionary objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]) {
		//Get payload
		NSDictionary *payload = [dictionary objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
		//Process it after little
		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
		dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
			[self __application:nil didReceiveRemoteNotification:payload isLaunch:YES];
		});
	}
}
- (void)application:(UIApplication *)_app didReceiveRemoteNotification:(NSDictionary *)userInfo {
  [self __application:_app didReceiveRemoteNotification:userInfo isLaunch:(_app.applicationState != UIApplicationStateActive)];
}
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
#if !TARGET_IPHONE_SIMULATOR
	//Notifications are disabled for this application. Not registering with Urban Airship
	if ([application enabledRemoteNotificationTypes] == 0) { return; }
  //Show alert ?
  if (errorInRegisterNotificationsString && [errorInRegisterNotificationsString length] > 0) {
    [[[UIAlertView alloc] initWithTitle:@"Error" message:errorInRegisterNotificationsString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    if (DEBUG) { NSLog(@"Error in push notification %@",[error description]); }
  }else {
    NSLog(@"Not showing error alert because the ivar 'errorInRegisterNotificationsString' is invalid (error is :%@)",[error description]);
  }
#endif
}
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
  // Get a hex string from the device token with no spaces or < >
	NSString * _deviceToken = [[[[deviceToken description] stringByReplacingOccurrencesOfString:@"<"withString:@""] 
						 stringByReplacingOccurrencesOfString:@">" withString:@""] 
						stringByReplacingOccurrencesOfString: @" " withString: @""];
	//Notifications are disabled for this application. Not registering with Urban Airship
	if ([application enabledRemoteNotificationTypes] == 0 ) { return; }
	//Check device token
	if (_deviceToken && [_deviceToken length] > 0) {
		_apnrsStorage.deviceToken = _deviceToken;
		[_apnrsQueue __queueRegisterWithStorage:_apnrsStorage completionBlock:^(BOOL isOkay) { }];
	}
}
#pragma mark - Private Fowarder
//Did recieve notification
- (void)__application:(UIApplication *)_app didReceiveRemoteNotification:(NSDictionary *)userInfo isLaunch:(BOOL)launch  {
	[[NSNotificationCenter defaultCenter] postNotificationName:
	 (launch ? APNRSLibraryReceivedNotificationClosed : APNRSLibraryReceivedNotificationOpened) object:userInfo];
}
@end