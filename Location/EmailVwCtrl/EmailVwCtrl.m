//
//  EmailVwCtrl.m
//  gps-test
//
//  Created by Theranjali Nilaweera on 19/08/2015.
//  Copyright (c) 2015 SV. All rights reserved.
//

#import "EmailVwCtrl.h"
#import "Constants.h"
#import <MessageUI/MessageUI.h>
#import <CoreLocation/CoreLocation.h>
#import "LocationService.h"
#import "ReachabilityHandler.h"
#import "MBProgressHUD.h"


@interface EmailVwCtrl () <MFMailComposeViewControllerDelegate>
@property (nonatomic, retain) MFMailComposeViewController * emailComposerlVw;
@property (nonatomic, strong) NSString *csvFileName;
@property (nonatomic , strong) CLLocation *prevLocation;
@property (nonatomic , strong) NSDateFormatter *dateFormatter;
@property (nonatomic, retain) NSArray *allFileNames;
@property (nonatomic, retain) ReachabilityHandler *reachHandler;
@property (nonatomic, retain) NSString *networkStatusString;

@end

@implementation EmailVwCtrl


-(void)initCsvFile{
    self.dateFormatter =  [[NSDateFormatter alloc] init];
    [_dateFormatter setDateFormat:@"dd/MM/yyyy HH:mm:ss:SSS"];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd-MM-yyyy-HH-mm"];
    
    [self setNetworkStatus];
    
    NSString *currentDateString =[dateFormatter stringFromDate:[[NSDate alloc] init]];
    self.csvFileName = [NSString stringWithFormat:@"GPS-Test%@.csv",currentDateString];
    
    NSError *error;
    NSString *documentTXTPath = [[self getDocumentPath] stringByAppendingPathComponent:self.csvFileName];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:documentTXTPath]){
        [[self startUpStringForFile] writeToFile:documentTXTPath atomically:NO encoding:NSUTF8StringEncoding error:&error];
    }

}


-(void)setNetworkStatus{
    self.reachHandler = [[ReachabilityHandler alloc] init];
    self.networkStatusString = [self.reachHandler getNetworksAvaialableString];
}

#pragma mark - notification N File write
-(void)receivedWriteNotification:(NSNotification *) notification{
    NSMutableDictionary * contentDictionary = [notification object];
    CLLocation *updatedLocation = [contentDictionary objectForKey:KEY_FOR_LOCATION];
    NSDate *updateDate = [contentDictionary objectForKey:KEY_FOR_DATE];
    NSNumber *currentMode = [contentDictionary objectForKey:KEY_FOR_MODE];
    LocationService *locationService = [contentDictionary objectForKeyedSubscript:KEY_FOR_LOCATION_SERVICE];
    NSDate *modeStartTime = [contentDictionary objectForKeyedSubscript:KEY_FOR_MODE_START_TIME];

    NSString *contentToAppend = [self getDetailsToLogForLocation:updatedLocation withDate:updateDate forCurrentMode:currentMode forLocationService:(LocationService*)locationService modeStartDate:modeStartTime];
    
    [self appendFileWithString:contentToAppend];
}


-(void)receivedRemoveFilesNotification:(NSNotification *) notification{
    [self removeFilesFromPath];
}


#pragma mark - file content generations
-(NSString*)startUpStringForFile{
    return @"Mode,PauseAuto,DistanceFilter,DesiredAccuracy,ActivityType,Coordinate Latitude,Coordinate Longitude,Altitude,Horizontal Accuracy,Vertical Accuracy,Current Date,Location Object Timestamp,Time difference from mode start (s), Time difference previous, Distance to previous (m), Network Status\n";
}


-(CLLocationDistance)locationDifferenceFrom:(CLLocation*)fromLocation{
    if (self.prevLocation == nil) {
        return 0;
    }
    CLLocationDistance diffFromPrev = [self.prevLocation distanceFromLocation:fromLocation];
    return diffFromPrev;
    
}

-(NSTimeInterval)timeDiffFromPrevUpdate:(CLLocation*)updateLocation{
    
    if (self.prevLocation == nil) {
        return 0;
    }
    return [updateLocation.timestamp timeIntervalSinceDate:self.prevLocation.timestamp];
}

-(NSString*)getDetailsToLogForLocation:(CLLocation *)updateLocation withDate:(NSDate*)updateDate forCurrentMode:(NSNumber*)currentMode forLocationService:(LocationService*)locationService modeStartDate:(NSDate*)modeStartDate{
    
    
    
    NSString *stringToPrint = [NSString stringWithFormat:@"%@,%@,distance%.0f,%.0f,%@,%.6f,%.6f,%.3f,%.3f,%.3f,%@,%@,%.6f,%.6f,%.3f,%@\n",
                               ModeDisplayStrings(currentMode.intValue),
                               locationService.locationManager.pausesLocationUpdatesAutomatically?@"No":@"Yes",
                               locationService.locationManager.distanceFilter,
                               locationService.locationManager.desiredAccuracy,
                               locationService.locationManager.activityType==3?@"Fitness":@"otherNav",
                               updateLocation.coordinate.latitude,
                               updateLocation.coordinate.longitude,
                               updateLocation.altitude,
                               updateLocation.horizontalAccuracy,
                               updateLocation.verticalAccuracy,
                               [self.dateFormatter stringFromDate:updateDate],
                               [self.dateFormatter stringFromDate:updateLocation.timestamp],
                               [updateLocation.timestamp timeIntervalSinceDate:modeStartDate],
                               [self timeDiffFromPrevUpdate:updateLocation],
                               [self locationDifferenceFrom:updateLocation],
                               self.networkStatusString
                               
                               ];
    
    self.prevLocation = updateLocation;
    
    return stringToPrint;
}



-(void)appendFileWithString:(NSString*)appendContent{
    
    NSString *documentTXTPath = [[self getDocumentPath] stringByAppendingPathComponent:self.csvFileName];
    NSFileHandle *myHandle = [NSFileHandle fileHandleForWritingAtPath:documentTXTPath];
    
    [myHandle seekToEndOfFile];
    [myHandle writeData:[appendContent dataUsingEncoding:NSUTF8StringEncoding]];
    
    
}

-(NSString*)getDocumentPath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
    
    
}


-(void)getAllDocumentsInPath{
    self.allFileNames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self getDocumentPath] error:NULL];
    NSLog(@"LocationService>>Total # files found %lu",(unsigned long)self.allFileNames.count);
}

-(void)attachAllFiles{
    [self getAllDocumentsInPath];
    if (self.allFileNames==nil || self.allFileNames.count<1) {
        NSLog(@"LocationService>>No files to attach in email");
        return;
    }
    for (NSString *fileName in self.allFileNames) {
        NSString *fullFileName = [[self getDocumentPath] stringByAppendingPathComponent:fileName];
        NSData *fileData = [NSData dataWithContentsOfFile:fullFileName];
        if ([fileName hasSuffix:@"csv"]) {
           [self.emailComposerlVw addAttachmentData:fileData mimeType:@"text/csv" fileName:fileName];
           
        }
    }
    NSString *fullFileName = [[self getDocumentPath] stringByAppendingPathComponent:LOG_FILE_NAME];
    NSData *fileData = [NSData dataWithContentsOfFile:fullFileName];
    [self.emailComposerlVw addAttachmentData:fileData mimeType:@"text/plain" fileName:LOG_FILE_NAME];
}

#pragma mark - emailing

-(void)sendEmailWithFiles{
    
    if (![MFMailComposeViewController canSendMail]) {
        NSLog(@"LocationService>>Can not compose email");
        UIAlertView *errorAlert = [self getErrorEmailAlert];
        [errorAlert show];
        return;
    }
    
    
    
    self.emailComposerlVw  = [[MFMailComposeViewController alloc] init];
    self.emailComposerlVw.mailComposeDelegate = self;
    [self.emailComposerlVw setSubject:@"GPS Tester Results"];
    [self.emailComposerlVw setMessageBody:@"Please supply coordinates for test site." isHTML:YES];
    [self.emailComposerlVw setToRecipients:[NSArray arrayWithObjects:@"uat@spatialvision.com.au", nil]];
    
    [self attachAllFiles];
   
    [self presentViewController:self.emailComposerlVw animated:YES completion:nil];



}


- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    NSLog(@"LocationService>>Email sending finished with code %u",result);
    
    if (result == MFMailComposeResultSent) {
        [self removeFilesFromPath];
    }
    
    if( NSFoundationVersionNumber >NSFoundationVersionNumber_iOS_7_1){
        [self.emailComposerlVw dismissViewControllerAnimated:NO completion:nil];
        [self dismissViewControllerAnimated:NO completion:nil];

        return;
    }
    [self.emailComposerlVw dismissViewControllerAnimated:NO completion:nil];
    [self dismissViewControllerAnimated:YES completion:nil] ;

}

-(void)removeFilesFromPath{

    NSError *error;
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    for (NSString *fileName in self.allFileNames) {
        if (![fileName hasSuffix:@"csv"]) {
            continue;
        }
        NSString *fullFileName = [[self getDocumentPath] stringByAppendingPathComponent:fileName];
        if ([fileManager fileExistsAtPath:fullFileName]) {
            [fileManager removeItemAtPath:fullFileName error:&error];
            if (error) {
                NSLog(@"LocationService>>Error in removing file %@ error %@",fullFileName,error.description);
            }
        }
    }
    
    
}


#pragma mark - error alerts


- (UIAlertView *)getErrorEmailAlert {
    UIAlertView *emailErrorAlert = [[UIAlertView alloc] initWithTitle:@"Email error" message:@"Email cannot be sent from your device. File has been saved on device." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
    
    return emailErrorAlert;
}




@end
