//
//  LocationServiceConstants.h
//  gps-test
//
//  Created by Theranjali Nilaweera on 17/08/2015.
//  Copyright (c) 2015 SV. All rights reserved.
//

#ifndef gps_test_Constants_h
#define gps_test_Constants_h

typedef enum{
    kAccurateWalk=0,
    kAccurateBoat,
    kHighestWalk,
    kHighestBoat,
    kNearestWalk,
    kNearestBoat,
    kWrapperLoaction,
    kModeEnumCount
    
}LocationModes;

#define ModeDisplayStrings(intVal) [@[@"Best for Navigation Walk",@"Best for Navigation Boat",@"Best for walk - No Nav",@"Best for Boat - No Nav",@"Nearest 10m for Walk",@"Nearest 10m for Boat",@"Wrapper based location"] objectAtIndex:intVal]

#define segueIdShowVarValueOptions @"ShowServiceVwSegueId"
#define LOG_FILE_NAME @"GPS-Tester-log.txt"

#define WRITE_TOFILE_MSG @"WriteToFileNotification"
#define REMOVE_FILES_MSG @"RemoveFilesNotification"

#define KEY_FOR_LOCATION @"LocationKey"
#define KEY_FOR_DATE @"DateKey"
#define KEY_FOR_MODE @"ModeKey"
#define KEY_FOR_LOCATION_SERVICE @"LocationServiceKey"
#define KEY_FOR_MODE_START_TIME @"ModeStartTimeKey"



#endif
