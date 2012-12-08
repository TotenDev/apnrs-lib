//
//  _APNRSStorage.m
//  apnrs
//
//  Created by Gabriel Pacheco on 12/8/12.
//  Copyright (c) 2012 TotenDev. All rights reserved.
#import "_APNRSStorage.h"
#import "privateDefinitions.h"
#include "TargetConditionals.h"

@interface _APNRSStorage (/*private*/) {
	NSString *_storageFile;
}
@end
//Declarations Interface
@interface _APNRSStorage (declarations)
#pragma mark - Helpers
//String from quiet time param
+(NSDictionary*)__dictFromQuietTime:(pushQuietTime)quietTime ;
//String from quiet time param
+(pushQuietTime)__quietTimeFromDict:(NSDictionary*)dict ;
#pragma mark - Disk IO
//return default file path
-(NSString*)__remoteNotificationsFilePath ;
-(BOOL)__saveDictionary ;
-(void)__restoreDictionary ;
@end



@implementation _APNRSStorage
@synthesize tags ,deviceToken ,quietTime;
-(id)init {
	if ((self = [super init])) {
		[self __restoreDictionary];
	} return self;
}
-(void)setDeviceToken:(NSString*)_deviceToken {
#if TARGET_IPHONE_SIMULATOR
	deviceToken = @"iPhoneSimulator" ;
#else
	if (deviceToken != _deviceToken) {
		deviceToken = _deviceToken;
		[self __saveDictionary];
	}
#endif
}
-(void)setTags:(NSArray*)_tags {
	if (tags != _tags) {
		tags = _tags;
		[self __saveDictionary];
	}
}
-(void)setQuietTime:(pushQuietTime)_quietTime {
	if (!pushQuietTimeIsEqual(quietTime,_quietTime)) {
		quietTime = _quietTime;
		[self __saveDictionary];
	}
}
@end



@implementation _APNRSStorage (helpers)
//String from quiet time param
+(NSDictionary*)__dictFromQuietTime:(pushQuietTime)quietTime {
	return [NSDictionary dictionaryWithObjectsAndKeys:
					[NSString stringWithFormat:@"%i",quietTime.fromHour],APNRSLibraryStorageQuietTimeFromHour,
					[NSString stringWithFormat:@"%i",quietTime.fromMinute],APNRSLibraryStorageQuietTimeFromMinute,
					[NSString stringWithFormat:@"%i",quietTime.toHour],APNRSLibraryStorageQuietTimeToHour,
					[NSString stringWithFormat:@"%i",quietTime.toMinute],APNRSLibraryStorageQuietTimeToMinute, nil];
}
//String from quiet time param
+(pushQuietTime)__quietTimeFromDict:(NSDictionary*)dict {
  if (dict) { return pushQuietTimeMake([[dict objectForKey:APNRSLibraryStorageQuietTimeFromHour] intValue],
                                       [[dict objectForKey:APNRSLibraryStorageQuietTimeFromMinute] intValue],
                                       [[dict objectForKey:APNRSLibraryStorageQuietTimeToHour] intValue],
                                       [[dict objectForKey:APNRSLibraryStorageQuietTimeToMinute] intValue]); }
  else { return pushQuietTimeMakeZero(); }
}
@end



@implementation _APNRSStorage (diskIO)
-(NSString*)__remoteNotificationsFilePath {
  if (!_storageFile) {
    NSString *dir = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    _storageFile = [[dir stringByAppendingPathComponent:APNRSLibraryStorageFile] copy];
  } return _storageFile ;
}
-(BOOL)__saveDictionary {
  NSDictionary * dict = [NSDictionary dictionaryWithObjectsAndKeys:
                         deviceToken,APNRSLibraryStorageDeviceTokenKey,
                         tags,APNRSLibraryStorageDeviceTagsKey,
                         [[self class] __dictFromQuietTime:quietTime],APNRSLibraryStorageDeviceQuietTimeKey,nil];
  return [dict writeToFile:[self __remoteNotificationsFilePath] atomically:YES];
}
-(void)__restoreDictionary {
	NSDictionary * dict = [NSDictionary dictionaryWithContentsOfFile:[self __remoteNotificationsFilePath]];
	deviceToken = [dict objectForKey:APNRSLibraryStorageDeviceTokenKey];
	quietTime = [[self class] __quietTimeFromDict:[dict objectForKey:APNRSLibraryStorageDeviceQuietTimeKey]];
	tags = [dict objectForKey:APNRSLibraryStorageDeviceTagsKey];
}
@end