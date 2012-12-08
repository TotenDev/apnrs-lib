//
//  _APNRSStorage.h
//  apnrs
//
//  Created by Gabriel Pacheco on 12/8/12.
//  Copyright (c) 2012 TotenDev. All rights reserved.
//
#import "apnrs.h"

@interface _APNRSStorage : NSObject
@property (nonatomic,strong) NSArray *tags;
@property (nonatomic,strong) NSString *deviceToken;
@property (nonatomic) pushQuietTime quietTime;
@end
