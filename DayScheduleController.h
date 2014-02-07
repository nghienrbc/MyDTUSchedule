//
//  DayScheduleController.h
//  MyDTUSchedule
//
//  Created by duc nguyen minh on 1/15/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DayScheduleController : UIViewController{
    IBOutlet UITableView *schedule_table; 
    IBOutlet UILabel *infoLabel;
    IBOutlet UIToolbar *toolbar;
    IBOutlet UIButton *previous_button;
    IBOutlet UIButton *next_button;
}
@property (nonatomic,retain) NSMutableArray *scheduleArray;
@property (nonatomic,retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) IBOutlet UITableView *schedule_table;
 
@property (nonatomic, retain) IBOutlet UILabel *infoLabel;
@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;
@property (nonatomic, retain) IBOutlet UIButton *previous_button;
@property (nonatomic, retain) IBOutlet UIButton *next_button;
 
//- (void)showReminder:(NSString *)text;

- (NSDate *)stringToDate: (NSString *)string;
- (void) show_date_on_label: (NSDate*) day_show;
- (void) show_after_touch_button_left; 
- (void) show_after_touch_button_right;
@end
  