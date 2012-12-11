//
//  _APNRSConnectionsQueue.m
//  apnrs
//
//  Created by Gabriel Pacheco on 12/8/12.
//  Copyright (c) 2012 TotenDev. All rights reserved.
//

#import "_APNRSConnectionsQueue.h"
#import "APNRSManager.h"
#import "privateDefinitions.h"


@interface _APNRSConnectionsQueue (/*private*/) {
	NSOperationQueue *_queue;
}
@end
@interface _APNRSConnectionsQueue (declarations)
#pragma mark - Push Connections
//Register device with mask and notifications
+(BOOL)__serverRegisterRemoteNotificationsWithToken:(NSString*)token withTags:(NSArray*)tags withQuietTime:(pushQuietTime)quietTime ;
//Format request with params....
+(void)__formatRequest:(NSMutableURLRequest*)request withTags:(NSArray*)tags withQuietTime:(pushQuietTime)quietTime withDeviceToken:(NSString*)deviceToken ;
#pragma mark - Encoder
//Encode nsstring to nsstring
+ (NSString*)encodeStringToBase64:(NSString *)str ;
//Encode nsdata to nsstring
+ (NSString*)encodeToBase64Data:(NSData *)data ;
@end



@implementation _APNRSConnectionsQueue
-(id)init {
	if ((self = [super init])) {
		_queue = [NSOperationQueue new];
		[_queue setMaxConcurrentOperationCount:1];
	} return self;
}
//queue register with storage instance
-(void)__queueRegisterWithStorage:(_APNRSStorage*)storage completionBlock:(void(^)(BOOL isOkay))completionBlock {
  //we can cancel all operations in _queue since all of then are register calls !
  [_queue cancelAllOperations];
  [_queue addOperationWithBlock:^{
    //Try to send a connection to server with new informations
    BOOL response = [[self class] __serverRegisterRemoteNotificationsWithToken:storage.deviceToken
                                                                          withTags:storage.tags
                                                                     withQuietTime:storage.quietTime];
    completionBlock(response);
  }];
}
@end



@implementation _APNRSConnectionsQueue (connections)
#pragma mark - Push Connections
//Register device with mask and notifications
+(BOOL)__serverRegisterRemoteNotificationsWithToken:(NSString*)token withTags:(NSArray*)tags withQuietTime:(pushQuietTime)quietTime {
  //Check all values
  if (!token || [token length] <= 0) { return NO; }
  //Autorelease
  @autoreleasepool {
    //Format URL
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/%@/",(APNRSLibraryRequestUseSSL?@"https":@"http"),[[APNRSManager sharedPushNotifications] APNRSLibraryRequestEntrypoint], APNRSLibraryRequestRegisterRoute];
    NSURL *url = [NSURL URLWithString:urlString];
    //Format request
    NSMutableURLRequest * request = [[NSMutableURLRequest alloc] initWithURL:url];
    [self __formatRequest:request withTags:tags withQuietTime:quietTime withDeviceToken:token];
    //Responses
    NSHTTPURLResponse * response = nil ;
    NSError * error = nil ;
    //Make connection
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if (error == nil && response != nil && [response statusCode] == 200) { return YES ; }
    else { return NO ; }
  }
}
//Format request with params....
+(void)__formatRequest:(NSMutableURLRequest*)request withTags:(NSArray*)tags withQuietTime:(pushQuietTime)quietTime withDeviceToken:(NSString*)deviceToken {
	//Connection preferences
	{
		[request setTimeoutInterval:30];
		[request setCachePolicy:NSURLCacheStorageNotAllowed];
		[request setHTTPMethod:@"POST"];
		
		//FUCKING AUTHENTICATION
		[request setValue:
		 [NSString stringWithFormat:@"Basic %@",
		  [self encodeStringToBase64:
		   [NSString stringWithFormat:@"%@:%@",
				[[APNRSManager sharedPushNotifications] APNRSLibraryRequestUsername],
				[[APNRSManager sharedPushNotifications] APNRSLibraryRequestPassword]]]]
			forHTTPHeaderField:@"Authorization"];
	}
  
	//Insert params
	{
    //Quiet Time
    //{"silentTime":{"startDate":"22:00","endDate":"08:00","timezone":"-0200"}}
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		[formatter setDateFormat:@"ZZZ"];
		NSString *timezoneString = [formatter stringFromDate:[NSDate date]];
		
    NSString *quietValue = (pushQuietTimeIsZero(quietTime)) ? nil :
		[NSString stringWithFormat:@"\"%@\":{\"%@\":\"%02i:%02i\",\"%@\":\"%02i:%02i\",\"%@\":\"%@\"}", APNRSLibraryRequestSilentTimeKey,
		 APNRSLibraryRequestSilentStartDateKey,quietTime.fromHour,quietTime.fromMinute,
		 APNRSLibraryRequestSilentEndDateKey,quietTime.toHour,quietTime.toMinute,
		 APNRSLibraryRequestSilentTimezoneKey,timezoneString];
    //Tags
    //{"tags": ["tag1", "tag2"]}
    NSMutableString *tagsValue = nil;
    if (tags) {
      tagsValue = [NSMutableString stringWithFormat:@"\"%@\":[",APNRSLibraryRequestTagKey];
      for (NSString *tag in tags) {
        ([tag isEqual:[tags objectAtIndex:0]] ? [tagsValue appendFormat:@"\"%@\"",tag] : [tagsValue appendFormat:@",\"%@\"",tag]);
      } [tagsValue appendString:@"]"];
    }
    //Token
    NSMutableString *tokenValue = [NSMutableString stringWithFormat:@"\"%@\":\"%@\"",APNRSLibraryRequestTokenKey,deviceToken];
    
    //Finish
    NSString *bodyString = [NSString stringWithFormat:@"{%@",tokenValue];
    if (quietValue) { bodyString = [bodyString stringByAppendingFormat:@",%@",quietValue]; }
    if (tagsValue) { bodyString = [bodyString stringByAppendingFormat:@",%@",tagsValue]; }
    bodyString = [bodyString stringByAppendingString:@"}"];
    
    //Little clean
		formatter = nil, timezoneString = nil, quietValue = nil, tagsValue = nil, tokenValue = nil;
		//Set body
		[request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
		[request setHTTPBody:[bodyString dataUsingEncoding:NSUTF8StringEncoding]];
		bodyString = nil ;
	}
}
@end



@implementation _APNRSConnectionsQueue (encoder)
static const char _APNRSConnectionsQueue_base64EncodingTable[64] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
static const short _APNRSConnectionsQueue_base64DecodingTable[256] = {
  -2, -2, -2, -2, -2, -2, -2, -2, -2, -1, -1, -2, -1, -1, -2, -2,
  -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
  -1, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, 62, -2, -2, -2, 63,
  52, 53, 54, 55, 56, 57, 58, 59, 60, 61, -2, -2, -2, -2, -2, -2,
  -2,  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14,
  15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, -2, -2, -2, -2, -2,
  -2, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
  41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, -2, -2, -2, -2, -2,
  -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
  -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
  -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
  -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
  -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
  -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
  -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
  -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2
};
//Encode nsstring to nsstring
+ (NSString*)encodeStringToBase64:(NSString *)str {
	//
	return [self encodeToBase64Data:[str dataUsingEncoding:NSUTF8StringEncoding]];
}
//Encode nsdata to nsstring
+ (NSString*)encodeToBase64Data:(NSData *)data {
	
	NSData *objData = data;
	if ([objData length] == 0)return @"";
  
  char *characters = malloc((([objData length] + 2) / 3) * 4);
	if (characters == NULL)
		return nil;
	NSUInteger length = 0;
	
	NSUInteger i = 0;
	while (i < [objData length])
	{
		char buffer[3] = {0,0,0};
		short bufferLength = 0;
		while (bufferLength < 3 && i < [objData length])
			buffer[bufferLength++] = ((char *)[objData bytes])[i++];
		
		//  Encode the bytes in the buffer to four characters, including padding "=" characters if necessary.
		characters[length++] = _APNRSConnectionsQueue_base64EncodingTable[(buffer[0] & 0xFC) >> 2];
		characters[length++] = _APNRSConnectionsQueue_base64EncodingTable[((buffer[0] & 0x03) << 4) | ((buffer[1] & 0xF0) >> 4)];
		if (bufferLength > 1)
			characters[length++] = _APNRSConnectionsQueue_base64EncodingTable[((buffer[1] & 0x0F) << 2) | ((buffer[2] & 0xC0) >> 6)];
		else characters[length++] = '=';
		if (bufferLength > 2)
			characters[length++] = _APNRSConnectionsQueue_base64EncodingTable[buffer[2] & 0x3F];
		else characters[length++] = '=';
	}
	
	return [[NSString alloc] initWithBytesNoCopy:characters length:length encoding:NSASCIIStringEncoding freeWhenDone:YES];
	
}
@end