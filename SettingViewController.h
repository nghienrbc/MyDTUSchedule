//
//  SettingViewController.h
//  MyDTUSchedule
//
//  Created by duc nguyen minh on 3/17/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h> 
#import "InstructionViewController.h"
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>
@class MBProgressHUD;

@interface SettingViewController : UIViewController<UIPickerViewDelegate, UITextFieldDelegate>{
    MBProgressHUD *progressHud;
    IBOutlet UIImageView * background_image;
    
} 

@property (nonatomic, retain) IBOutlet UIImageView *background_image;

@property (nonatomic, strong) MBProgressHUD *progressHud;
@property (nonatomic,retain) NSMutableArray *scheduleArray;
@property (nonatomic,retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) IBOutlet UISwitch *switch_alert;
@property (nonatomic, retain) IBOutlet UISwitch *switch_calendar;
@property (nonatomic, retain) InstructionViewController *instructionViewController;

@property (nonatomic, retain) IBOutlet UITextField *textfield_alertType;

@property (nonatomic, retain) IBOutlet UIButton *button_info; 


//@property (nonatomic, retain) EKEventStore *eventStore;
@property (nonatomic, retain) EKCalendar *defaultCalendar;
@property (nonatomic, retain) NSMutableArray *eventsList;
@property (nonatomic, retain) EKEventViewController *detailViewController;

- (NSArray *)fetchEventsForToday;
- (void) copyDatabaseIfNeeded:(NSString*) filename;
- (NSString*) getFilePath:(NSString*) filename;
- (NSDate *)stringToDate: (NSString *)string;
- (void) delete_schedule_in_calender;
- (IBAction)button_info_click :(id)sender;
- (IBAction) switch_calendarChanged :(id)sender;
- (IBAction) switch_alertChanged :(id)sender;
- (IBAction) textfield_alertType_click :(id)sender;
- (IBAction)clearAllEvents:(id)sender;

@end
