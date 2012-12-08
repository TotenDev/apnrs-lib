//
//  privateDefinitions.h
//  apnrs
//
//  Created by Gabriel Pacheco on 12/7/12.
//  Copyright (c) 2012 TotenDev. All rights reserved.
//

//internal storage key definitions
#define APNRSLibraryStorageDeviceTagsKey        @"push_notifications_tags_key"
#define APNRSLibraryStorageDeviceTokenKey       @"push_notifications_token_key"
#define APNRSLibraryStorageDeviceQuietTimeKey   @"push_notifications_quiet_time_key"
#define APNRSLibraryStorageQuietTimeFromHour    @"fromHour"
#define APNRSLibraryStorageQuietTimeFromMinute  @"fromMinute"
#define APNRSLibraryStorageQuietTimeToHour      @"toHour"
#define APNRSLibraryStorageQuietTimeToMinute    @"toMinute"
#define APNRSLibraryStorageFile                 @"soitacifiton_hsup.kab.nosync" //storage files
//internal request
#define APNRSLibraryRequestRegisterRoute @"register"
#define APNRSLibraryRequestUseSSL 1
//register body keys
//https://github.com/TotenDev/apnrs-server/blob/master/docs/rest.md#register-device-post
#define APNRSLibraryRequestSilentTimeKey @"silentTime"
#define APNRSLibraryRequestSilentStartDateKey @"startDate"
#define APNRSLibraryRequestSilentEndDateKey @"endDate"
#define APNRSLibraryRequestSilentTimezoneKey @"timezone"
#define APNRSLibraryRequestTagKey @"tags" 
#define APNRSLibraryRequestTokenKey @"token" 