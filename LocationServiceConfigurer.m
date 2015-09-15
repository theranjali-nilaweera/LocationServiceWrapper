//
//  LocationServiceConfigurer.m
//  gps-test
//
//  Created by Theranjali Nilaweera on 11/09/2015.
//  Copyright (c) 2015 SV. All rights reserved.
//

#import "LocationServiceConfigurer.h"
#import "EmailVwCtrl.h"
#import "LocationService.h"
#import "Constants.h"

@interface LocationServiceConfigurer ()

@property (nonatomic, retain) NSNumber *selectedMode;
@property (nonatomic , strong) NSNumber *selectedNumIterations;
@property (nonatomic , strong) NSNumber *selectedAccuracyCriteria;
@property (nonatomic , strong) NSNumber *selectedTimeDifference;
@property (nonatomic, strong) LocationSucessBlock locationSucessBlock;
@property (nonatomic, strong) LocationFailureBlock locationFailureBlock;



@property (nonatomic , strong) NSNumber *currentModeReturnCount;
@property (nonatomic , retain) NSDate *currentModeStartTime;


@property (nonatomic , retain) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) NSNumber *locationServiceIsRunning;
@property (strong, nonatomic) LocationService *locationService;
@property (nonatomic , strong) EmailVwCtrl *emailerVwCtrl;
@end


@implementation LocationServiceConfigurer
#pragma mark - Init location service with given settings
-(void)setConfigurationSelections:(int)locationMode numberOfIterations:(int)iterations accuracyCriteria:(int)requiredAccuracy  timeDifferenceSeconds:(int)timeDifferenceSeconds{

    self.selectedMode = [NSNumber numberWithInt:locationMode];
    self.selectedNumIterations = [NSNumber numberWithInt:iterations];
    self.selectedAccuracyCriteria = [NSNumber numberWithInt:requiredAccuracy];
    self.selectedTimeDifference = [NSNumber numberWithInt:timeDifferenceSeconds];
    [self setupValues];
    NSLog(@"Location service configurations done");
}

#pragma mark - Call Location service
-(void)startLocationServiceWithSuccessCompletion:(LocationSucessBlock)completionBlock failureCompletion:(LocationFailureBlock)failureBlock{
    self.currentModeStartTime = [[NSDate alloc] init];
    self.locationSucessBlock = [completionBlock copy];
    self.locationFailureBlock = [failureBlock copy];
    [self startLocationsUpdate];
    NSLog(@"Starting up location service");
}


#pragma  mark - Remove files CSV and log
-(void)removeAllCSVFiles{
    NSLog(@"Start clearing CSV and log files related to location service");
    [[NSNotificationCenter defaultCenter] postNotificationName:REMOVE_FILES_MSG object:nil];
    NSLog(@"Done clearing CSV and log files related to location service");
}

#pragma mark - Set up

-(void)setupValues{
    
    self.locationService = [[LocationService alloc] init];
    self.locationServiceIsRunning = [NSNumber numberWithBool:NO];
    self.dateFormatter =  [[NSDateFormatter alloc] init];
    [_dateFormatter setDateFormat:@"dd/MM/yyyy HH:mm:ss:SSS"];
    self.emailerVwCtrl = [[EmailVwCtrl alloc] init];
    [self.emailerVwCtrl initCsvFile];
    [self setupNotification];
    [self setupLocationServiceCallBack];
}

-(void)setupLocationServiceCallBack{
    __block LocationServiceConfigurer *blockSelf = self;
    
    [self.locationService setupLocationServiceWithCompletion:^(CLLocation *location, NSDate* updateDate){
         NSLog(@"LocationService>>Updated location recieved %@ at %@ time",location.description,[self.dateFormatter stringFromDate:updateDate]);
        [[NSNotificationCenter defaultCenter] postNotificationName:WRITE_TOFILE_MSG object:[self dictionaryForLocation:location withDate:updateDate]];
        if ([blockSelf isValidLocation:location]) {
            [blockSelf completeLocationSucessUpdateWithObject:location];
            return ;
        }
        //Check if has run required iterations, if yes stop and return null since hasn't got the location meeting criteria
        if (blockSelf.currentModeReturnCount.intValue>blockSelf.selectedNumIterations.intValue) {
            [blockSelf completeLocationFailureUpdateWithObject:nil];
            return;
        }

        
        blockSelf.currentModeReturnCount = [NSNumber numberWithInt:(blockSelf.currentModeReturnCount.intValue+1)];
        
        
    }
     ];
    
}

#pragma mark - Location validation
-(BOOL)isValidLocation:(CLLocation*)location{

    if ((location.coordinate.longitude == 0.0) && (location.coordinate.latitude == 0.0)) {
        return NO;
    }
    if (location.horizontalAccuracy<0) {
        return NO;
    }
    if(![self isValidTimeForLocation:location]){
        return NO;
    }
    
    return [self isWithinAccuracy:location.horizontalAccuracy];

}

-(BOOL)isWithinAccuracy:(double)currentAccuracy{
    if (currentAccuracy<self.selectedAccuracyCriteria.doubleValue) {
        return YES;
    }
    return NO;
}

-(BOOL)isValidTimeForLocation:(CLLocation*)location{

    NSDate *curentDate = [[NSDate alloc] init];
    double timeFromCurrent = [curentDate  timeIntervalSinceDate:location.timestamp];
    //time difference in seconds
    if(timeFromCurrent<=self.selectedTimeDifference.intValue){
        return YES;
    }
    return NO;
}

-(NSDate *) toLocalTime:(NSDate*)dateTime
{
    NSTimeZone *tz = [NSTimeZone defaultTimeZone];
    NSInteger seconds = [tz secondsFromGMTForDate: dateTime];
    return [NSDate dateWithTimeInterval: seconds sinceDate: dateTime];
}

#pragma mark - Location update handling
-(void)completeLocationSucessUpdateWithObject:(CLLocation*)finalLocation{
    [self stopLocationsUpdates];
    [self performSelectorOnMainThread:@selector(updateWithSucessLocation:) withObject:finalLocation waitUntilDone:YES];
}

-(void)completeLocationFailureUpdateWithObject:(CLLocation*)invalidLocation{
    [self stopLocationsUpdates];
    [self performSelectorOnMainThread:@selector(updateWithFailure) withObject:nil waitUntilDone:YES];
}

-(void)updateWithSucessLocation:(CLLocation*)finalLocation{
    self.locationSucessBlock(finalLocation);

}

-(void)updateWithFailure{
    self.locationFailureBlock();
    
}

#pragma mark - Start/stop location updates
-(void)startLocationsUpdate{
    [self.locationService startLocationServiceForMode:self.selectedMode.intValue];
}
-(void)stopLocationsUpdates{
    [self.locationService stopLocationService];
}


//TODO chk if this emailing is needed to be exposed outside as API
- (IBAction)stopUpdatesNEmail:(id)sender {
    
//    [self.navigationController presentViewController:_emailerVwCtrl animated:YES completion:^{
//        [_emailerVwCtrl sendEmailWithFiles];
//    }];
    
    
    
}


#pragma mark - Setup notifications
-(void)setupNotification{
    [[NSNotificationCenter defaultCenter]
     addObserver:self.emailerVwCtrl
     selector:@selector(receivedWriteNotification:)
     name:WRITE_TOFILE_MSG
     object:nil];
    
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self.emailerVwCtrl
     selector:@selector(receivedRemoveFilesNotification:)
     name:REMOVE_FILES_MSG
     object:nil];
}

-(void)removeNotificaiton{
    [[NSNotificationCenter defaultCenter] removeObserver:self.emailerVwCtrl name:WRITE_TOFILE_MSG object:nil];
}

#pragma mark - Logs related

-(NSMutableDictionary*)dictionaryForLocation:(CLLocation *)locationString withDate:(NSDate*)updateDate{
    NSMutableDictionary *returnDictionary = [[NSMutableDictionary alloc] init];
    [returnDictionary setObject:locationString forKey:KEY_FOR_LOCATION];
    [returnDictionary setObject:updateDate forKey:KEY_FOR_DATE];
    [returnDictionary setObject:self.selectedMode   forKey:KEY_FOR_MODE];
    [returnDictionary setObject:self.locationService forKey:KEY_FOR_LOCATION_SERVICE];
    [returnDictionary setObject:self.currentModeStartTime forKey:KEY_FOR_MODE_START_TIME];
    return returnDictionary;
    
}
@end
