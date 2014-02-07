//
//  ScheduleAppDelegate.h
//  MyDTUSchedule
//
//  Created by duc nguyen minh on 1/15/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "ScheduleViewController.h" 
//#import "DayScheduleController.h"
//#import "WeekScheduleController.h" 
//@class DayScheduleController;
#import "LoginViewController.h"

@class ScheduleViewController;
@interface ScheduleAppDelegate : UIResponder <UIApplicationDelegate>{ 
    UIWindow *window;
    IBOutlet ScheduleViewController *viewController; 
    UINavigationController *myNavigationController;
    IBOutlet LoginViewController *loginViewController;
}
 
@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet ScheduleViewController *viewController; 

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

//@property (strong, nonatomic) DayScheduleController *dayviewController; 

@property (nonatomic, retain) IBOutlet UINavigationController *myNavigationController;

@property (nonatomic, retain) IBOutlet LoginViewController *loginViewController;

extern NSString *kRemindMeNotificationDataKey;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

- (void) copyDatabaseIfNeeded;
- (NSString*) getDBPath;

@end
