//
//  LocationService.h
//  gps-test
//
//  Created by Theranjali Nilaweera on 13/08/2015.
//  Copyright (c) 2015 SV. All rights reserved.
//


#import <CoreLocation/CoreLocation.h>


typedef void (^LocationCompletionBlock)(CLLocation*,NSDate*);


@interface LocationService : NSObject <CLLocationManagerDelegate>

@property (copy) LocationCompletionBlock completionHandler;
@property (nonatomic, strong) CLLocationManager *locationManager;
-(void)setupLocationServiceWithCompletion:(LocationCompletionBlock)completionHandler;
-(void)startLocationServiceForMode:(int)currentMode;

-(void)stopLocationService;
//-(void)startWithCompletionHandler:(LocationCompletionBlock)completionHandler forParentView:(UIView*)view;
@end
