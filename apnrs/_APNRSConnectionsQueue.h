//
//  _APNRSConnectionsQueue.h
//  apnrs
//
//  Created by Gabriel Pacheco on 12/8/12.
//  Copyright (c) 2012 TotenDev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "_APNRSStorage.h"

@interface _APNRSConnectionsQueue : NSObject
//queue register with storage instance
-(void)__queueRegisterWithStorage:(_APNRSStorage*)storage completionBlock:(void(^)(BOOL isOkay))completionBlock ;
@end
