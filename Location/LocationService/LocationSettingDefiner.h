//
//  LocationSettingDefiner.h
//  gps-test
//
//  Created by Theranjali Nilaweera on 17/08/2015.
//  Copyright (c) 2015 SV. All rights reserved.
//
//
//#import <Foundation/Foundation.h>

@interface LocationSettingDefiner : NSObject


+(NSUInteger)activityTypeForModeSetting:(int)modeSetting;

+(NSUInteger)accuracyForModeSetting:(int)modeSetting;

+(NSUInteger)distanceFilterForModeSetting:(int)modeSetting;
@end
