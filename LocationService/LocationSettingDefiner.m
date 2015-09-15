//
//  LocationSettingDefiner.m
//  gps-test
//
//  Created by Theranjali Nilaweera on 17/08/2015.
//  Copyright (c) 2015 SV. All rights reserved.
//

#import "LocationSettingDefiner.h"
#import <CoreLocation/CoreLocation.h>
#import "LocationServiceConstants.h"

@implementation LocationSettingDefiner
/*
 Settings 	activityType	desiredAccuracy	distanceFilter	pausesLocationUpdatesAutomatically
 Most accurate for walk	CLActivityTypeFitness 	kCLLocationAccuracyBestForNavigation 	kCLDistanceFilterNone 	YES
 Most accurate for boat	CLActivityTypeOtherNavigation	kCLLocationAccuracyBestForNavigation	kCLDistanceFilterNone	YES
 
 Highest for walk	CLActivityTypeFitness 	kCLLocationAccuracyBest 	kCLDistanceFilterNone 	YES
 Highest for boat	CLActivityTypeOtherNavigation	kCLLocationAccuracyBest	kCLDistanceFilterNone	YES
 
 Nearest 10m for walk	CLActivityTypeFitness	kCLLocationAccuracyNearestTenMeters	kCLDistanceFilterNone	YES
 Nearest 10m for boat	CLActivityTypeOtherNavigation	kCLLocationAccuracyNearestTenMeters	kCLDistanceFilterNone	YES
 */


+(NSUInteger)activityTypeForModeSetting:(int)modeSetting{
    switch (modeSetting) {
        case kAccurateWalk:{
            return CLActivityTypeFitness;
        }
        case kAccurateBoat:{
            return CLActivityTypeOtherNavigation;
            
        }
        case kHighestWalk:{
            return CLActivityTypeFitness;
            
        }
        case kHighestBoat:{
            return CLActivityTypeOtherNavigation;
            
        }
        case kNearestWalk:{
            return CLActivityTypeFitness;
        }
        case kNearestBoat:{
            return CLActivityTypeOtherNavigation;
        }
    }
    return CLActivityTypeOtherNavigation;

}

+(NSUInteger)accuracyForModeSetting:(int)modeSetting{
    switch (modeSetting) {
        case kAccurateWalk:{
            return kCLLocationAccuracyBestForNavigation;
        }
        case kAccurateBoat:{
            return kCLLocationAccuracyBestForNavigation;
            
        }
        case kHighestWalk:{
            return kCLLocationAccuracyBest;
            
        }
        case kHighestBoat:{
            return kCLLocationAccuracyBest;
            
        }
        case kNearestWalk:{
            return kCLLocationAccuracyNearestTenMeters;
        }
        case kNearestBoat:{
           return kCLLocationAccuracyNearestTenMeters;
        }
    }
    return kCLLocationAccuracyBest;

}

+(NSUInteger)distanceFilterForModeSetting:(int)modeSetting{
    return kCLDistanceFilterNone;
}

@end
