//
//  apnrs.h
//  apnrs
//
//  Created by Gabriel Pacheco on 12/6/12.
//  Copyright (c) 2012 TotenDev. All rights reserved.
//
#define APNRSLibraryBuildVersion @"0.0014"

//Push time range
struct pushQuietTime {
	int fromHour;
	int fromMinute;
	int toHour;
	int toMinute;
};
typedef struct pushQuietTime pushQuietTime;
//Helper
pushQuietTime pushQuietTimeMake(int _fromHour,int _fromMinute,int _toHour,int _toMinute) ;
pushQuietTime pushQuietTimeMakeZero(void) ;
BOOL pushQuietTimeIsZero(pushQuietTime quietTime) ;
BOOL pushQuietTimeIsEqual(pushQuietTime quietTime,pushQuietTime quietTime2) ;
