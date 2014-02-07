//
//  WeekScheduleController.h
//  MyDTUSchedule
//
//  Created by duc nguyen minh on 1/16/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "scheduleParser.h"

@class MBProgressHUD;
@interface WeekScheduleController : UIViewController{
    MBProgressHUD *progressHud;
    IBOutlet UITableView *schedule_table;
    IBOutlet UILabel *dateCompLabel;
    IBOutlet UILabel *infoLabel;
    IBOutlet UIToolbar *toolbar;
}
@property (nonatomic, retain) NSDate *start_date;
@property (nonatomic, retain) NSDate *end_date;
@property (nonatomic, retain) NSDate *endday_toshow;
@property (nonatomic,retain) NSMutableArray *scheduleArray;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, retain) NSFetchedResultsController    *fetchedResultsController;
@property (nonatomic, strong) MBProgressHUD *progressHud;

@property (nonatomic, retain) IBOutlet UITableView *schedule_table;

@property (nonatomic, retain) IBOutlet UILabel *dateCompLabel;
@property (nonatomic, retain) IBOutlet UILabel *infoLabel;
@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;

//- (void)showReminder:(NSString *)text;

- (NSDate *)stringToDate: (NSString *)string;
- (void) show_date_on_label: (NSDate*) day_show;
- (void) show_after_touch_button_left:(UIScrollView*) view;
- (void) show_after_touch_button_right:(UIScrollView*) view;
- (NSString *)get_time_from_day_string:(NSString*)string;
- (void) create_dayname_array;
- (void) create_scheduleView;
@end

 