//
//  NewDayViewController.h
//  MyDTUSchedule
//
//  Created by duc nguyen minh on 3/5/13.
//
//

#import <UIKit/UIKit.h>

@interface NewDayViewController : UIViewController{
    IBOutlet UIToolbar *toolbar;
    IBOutlet UILabel *infoLabel;
}


@property (nonatomic, retain) IBOutlet UILabel *infoLabel;
@property (nonatomic,retain) NSMutableArray *scheduleArray;
@property (nonatomic,retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;
- (NSString *)get_time_from_day_string:(NSString*)string;
- (void) show_after_touch_button_left: (UIScrollView*) view;
- (void) show_after_touch_button_right: (UIScrollView*) view;
- (void) create_scheduleView;
- (void) create_daylabel;
@end
