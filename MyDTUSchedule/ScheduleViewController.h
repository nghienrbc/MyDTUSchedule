//
//  ScheduleViewController.h
//  ScheduleManager
//
//  Created by duc nguyen minh on 1/14/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DayScheduleController.h" 
#import "WeekScheduleController.h"
#import "AboutViewController.h" 
#import "SettingViewController.h"
#import "NewDayViewController.h"
#import "scheduleParser.h"
@class MBProgressHUD;

@interface ScheduleViewController : UIViewController{
    MBProgressHUD *progressHud;
    IBOutlet UILabel *update_label;
    IBOutlet UIImageView * background_image;
    IBOutlet UIButton *update_button;
    IBOutlet UIButton *dayschdule_button;
    IBOutlet UIButton *monthschedule_button;
    IBOutlet UIButton *setting_button;
    IBOutlet UIImageView * logo_image;
}

@property (nonatomic, retain) IBOutlet UIImageView *background_image;
@property (nonatomic, retain) IBOutlet UIImageView * logo_image;
@property (nonatomic, retain) IBOutlet UIButton *update_button;
@property (nonatomic, retain) IBOutlet UIButton *dayschdule_button;
@property (nonatomic, retain) IBOutlet UIButton *monthschedule_button;
@property (nonatomic, retain) IBOutlet UIButton *setting_button;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, retain) NSFetchedResultsController    *fetchedResultsController;
@property (nonatomic, retain) DayScheduleController    *dayScheduleController;
@property (nonatomic, retain) WeekScheduleController    *weekScheduleController;
@property (nonatomic, retain) AboutViewController    *aboutViewController;
@property (nonatomic, retain) SettingViewController    *settingViewController;
@property (nonatomic, retain) NewDayViewController     *newdayViewController;

@property (nonatomic, retain) IBOutlet UILabel *update_label;
@property (nonatomic, strong) MBProgressHUD *progressHud;

- (void)showReminder:(NSString *)text;
- (void) copyDatabaseIfNeeded:(NSString*) filename;
- (NSString*) getFilePath:(NSString*) filename;
- (BOOL) connectedToNetwork;
@end
 