//
//  LocationServiceConfigurer.h
//  gps-test
//
//  Created by Theranjali Nilaweera on 11/09/2015.
//  Copyright (c) 2015 SV. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CLLocation;
typedef void (^LocationSucessBlock)(CLLocation*);
typedef void (^LocationFailureBlock)();

@interface LocationServiceConfigurer : NSObject
#pragma Call only once
-(void)setConfigurationSelections:(int)locationMode numberOfIterations:(int)iterations accuracyCriteria:(int)requiredAccuracy
                   timeDifferenceSeconds:(int)timeDifferenceSeconds;

-(void)startLocationServiceWithSuccessCompletion:(LocationSucessBlock)completionBlock failureCompletion:(LocationFailureBlock)failureBlock;

-(void)removeAllCSVFiles;

@end
