//
//  EmailVwCtrl.h
//  gps-test
//
//  Created by Theranjali Nilaweera on 19/08/2015.
//  Copyright (c) 2015 SV. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EmailVwCtrl : UIViewController
-(void)sendEmailWithFiles;
-(void)receivedWriteNotification:(NSNotification *) notification;
-(void)receivedRemoveFilesNotification:(NSNotification *) notification;
-(void)initCsvFile;
@end
