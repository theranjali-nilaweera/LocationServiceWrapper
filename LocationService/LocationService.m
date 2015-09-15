//
//  LocationService.m
//  gps-test
//
//  Created by Theranjali Nilaweera on 13/08/2015.
//  Copyright (c) 2015 SV. All rights reserved.
//

#import "LocationService.h"
#import "LocationSettingDefiner.h"
#import "LocationServiceConstants.h"

@interface LocationService ()
@property (nonatomic , retain) NSDateFormatter * dateFormatter;
@end

@implementation LocationService



-(void)setupLocationServiceWithCompletion:(LocationCompletionBlock)completionHandler{
    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager setDelegate:self];
    self.completionHandler = [completionHandler copy];
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [_dateFormatter setDateFormat:@"dd/MM/yyyy HH:mm:ss:SSS"];
    
}

-(void)stopLocationService{
    [self.locationManager stopUpdatingLocation];
}


-(void)startLocationServiceForMode:(int)currentMode{

    if(![self canCallLocationService]){
        return;
    }
    
    [self setConfigForLocationMngrForMode:currentMode];
    
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    
    [self.locationManager performSelectorOnMainThread:@selector(startUpdatingLocation) withObject:nil waitUntilDone:YES];
    
}

-(void)setConfigForLocationMngrForMode:(int)currentMode{
    [self.locationManager setPausesLocationUpdatesAutomatically:NO];
    [self.locationManager setActivityType:[LocationSettingDefiner activityTypeForModeSetting:currentMode]];
    [self.locationManager setDesiredAccuracy:[LocationSettingDefiner accuracyForModeSetting:currentMode]];
    [self.locationManager setDistanceFilter:[LocationSettingDefiner distanceFilterForModeSetting:currentMode]];
    
}

-(Boolean)canCallLocationService{
    int authorizationState = [CLLocationManager authorizationStatus];
    if((authorizationState==kCLAuthorizationStatusRestricted) || (authorizationState==kCLAuthorizationStatusDenied)){
        return NO;
    }
    return YES;
}


#pragma mark - location update events
-(void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    
    if ( self.completionHandler==nil) {
        return;
    }
    CLLocation *newLocation = locations[locations.count-1];
    [self updateUiWithLocation:newLocation];
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    if ( self.completionHandler==nil) {
        return;
    }
    [self updateUiWithLocation:newLocation];
}

-(void)updateUiWithLocation:(CLLocation*)currentLocation{
    NSDate *currentDate = [[NSDate alloc] init];
    self.completionHandler(currentLocation,currentDate);
}

#pragma mark - location pause
-(void)locationManagerDidPauseLocationUpdates:(CLLocationManager *)manager{
    NSLog(@"LocationService>>Pausing location services %@ ",[self.dateFormatter stringFromDate:[[NSDate alloc] init]]);
}

-(void)locationManagerDidResumeLocationUpdates:(CLLocationManager *)manager{
    NSLog(@"LocationService>>Resuming location services %@ ",[self.dateFormatter stringFromDate:[[NSDate alloc] init]]);
}

#pragma mark - location fails
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSLog(@"LocationService>>DidFailWithError at %@ error code %ld and desc %@",[self.dateFormatter stringFromDate:[[NSDate alloc] init]],(long)error.code,error.description);
    /* Uncomment if need to show alert for any sort of warning in retrieving location
    UIAlertView *locaitonFailedAlertView = [[UIAlertView alloc] initWithTitle:@"Location Service Failed" message:@"Could not get the location. Try enabling location services in device settings and try again." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
    [locaitonFailedAlertView show];
     */
    
}

@end
