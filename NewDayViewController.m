//
//  NewDayViewController.m
//  MyDTUSchedule
//
//  Created by duc nguyen minh on 3/5/13.
//
//

#import "NewDayViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Schedule.h"


@interface NewDayViewController ()

@end 
@implementation NewDayViewController
#define IS_IPAD() ([[UIDevice currentDevice] respondsToSelector:@selector(userInterfaceIdiom)] ? \
[[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad : NO)
@synthesize scheduleArray;
@synthesize managedObjectContext;
@synthesize fetchedResultsController;
@synthesize toolbar;
@synthesize infoLabel;
NSDate *current_day;
UIScrollView *scroll_view;
-(NSFetchedResultsController *) fetchedResult : (NSString *)entityName : (NSString *) sortby {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortby ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortDescriptors];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.managedObjectContext];
    [request setEntity:entity];
    fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    return self.fetchedResultsController;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [toolbar setTintColor:[UIColor colorWithRed:16.0/255.0 green:78.0/255.0 blue:139.0/255.0 alpha:0]];//[UIColor  colorWithRed:148/255.0 green:4.0/255.0 blue:4.0/255.0 alpha:0]];
    
    NSDate *sourceDate = [NSDate date];
    NSLog(@"%@",sourceDate); //lay ngay va gio theo GMT 00
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    NSTimeZone* destinationTimeZone = [NSTimeZone systemTimeZone];
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:sourceDate];
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:sourceDate];
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    NSDate* destinationDate = [[NSDate alloc] initWithTimeInterval:interval sinceDate:sourceDate];
    NSLog(@"%@",destinationDate);
    
    current_day = destinationDate;
    
    [self create_daylabel];
    [self create_scheduleView];
    //[self show_after_touch_button_left:scroll_view];
    [self show_date_on_label:current_day]; 
}
- (NSString *)get_time_from_day_string:(NSString*)string{
    NSString * result = @"";
    NSArray *arr = [string componentsSeparatedByString:@"T"];
    //NSString *str = [arr objectAtIndex:0];
    //    NSLog(@"strdate: %@",str); // strdate: 2011-02-28
    
    NSString *str1 = [arr objectAtIndex:1];
    //    NSLog(@"strdate: %@",str1);
    
    NSArray *arr1 = [str1 componentsSeparatedByString:@"+"];
    NSString *str2 = [arr1 objectAtIndex:0];
    //    NSLog(@"strdate: %@",str2);
    str2 = [str2 substringToIndex:5];
    result = str2;
    return result;
    
}
- (NSString *) date_to_string:(NSDate *)day{
    NSString * string;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"MM-dd-yyyy HH:mm"];
	//[formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:-18000]];
    
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	string = [formatter stringFromDate:day];
    
	string = [string substringWithRange:NSMakeRange (0, 10)];
    return string;
}
- (void) show_date_on_label: (NSDate*) day_show{
    NSString *tmp = [self date_to_string:day_show];
    self.title = tmp;
}
- (IBAction) previous_day_click: (id) sender{
    UIView *removeView;
    while((removeView = [self.view viewWithTag:1900]) != nil) {
        [removeView removeFromSuperview];
    }
    //next_button.enabled = TRUE;
    NSError *error = nil;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit ) fromDate:[NSDate date]];
    //create a date with these components
    [components setMonth:0];
    [components setDay:-1]; //reset the other components
    [components setYear:0]; //reset the other components
    NSDate *startDate = [calendar dateByAddingComponents:components toDate:current_day options:0];
    
    [components setMonth:0];
    [components setDay:1]; //reset the other components
    [components setYear:0]; //reset the other components
    NSDate *endDate = [calendar dateByAddingComponents:components toDate:startDate options:0];
    current_day = startDate;

    // ngay dang xem lich la ngay sau ngay hom nay
    [self fetchedResult:@"Schedule" :@"from_Date"]; // requet toan bo ten truong trong core data
    NSPredicate *predicateHDT =[NSPredicate predicateWithFormat:@"(from_Date > %@) AND (from_Date <= %@)",startDate,endDate];    // truy van theo ten truong
    [fetchedResultsController.fetchRequest setPredicate:predicateHDT];
    if (![[self fetchedResultsController] performFetch:&error])
    {
        // Handle error
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        exit(-1);  // Fail
    }
    NSArray *results = [fetchedResultsController fetchedObjects];    
    scheduleArray = [[NSMutableArray alloc]initWithArray:results];    
    [self create_daylabel];
    [self create_scheduleView];     
    [self show_after_touch_button_left:scroll_view];
    [self show_date_on_label:current_day];
    
}
- (IBAction) next_day_click: (id) sender{
    // tien hanh chan duoi. neu ngay dang kiem tra la ngay cuoi cung trong database thi dung
    UIView *removeView;
    while((removeView = [self.view viewWithTag:1900]) != nil) {
        [removeView removeFromSuperview];
    }

    NSError *error = nil;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit ) fromDate:[NSDate date]];
    //create a date with these components
    [components setMonth:0];
    [components setDay:1]; //reset the other components
    [components setYear:0]; //reset the other components
    NSDate *startDate = [calendar dateByAddingComponents:components toDate:current_day options:0];
    
    [components setMonth:0];
    [components setDay:1]; //reset the other components
    [components setYear:0]; //reset the other components
    NSDate *endDate = [calendar dateByAddingComponents:components toDate:startDate options:0];
    current_day = startDate;
    
    
    [self fetchedResult:@"Schedule" :@"from_Date"]; // requet toan bo ten truong trong core data
    NSPredicate *predicateHDT =[NSPredicate predicateWithFormat:@"(from_Date > %@) AND (from_Date <= %@)",startDate,endDate];    // truy van theo ten truong
    [fetchedResultsController.fetchRequest setPredicate:predicateHDT];
    if (![[self fetchedResultsController] performFetch:&error])
    {
        // Handle error
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        exit(-1);  // Fail
    }
    NSArray *results = [fetchedResultsController fetchedObjects];
    
    scheduleArray = [[NSMutableArray alloc]initWithArray:results];
    [self create_daylabel];
    [self create_scheduleView];    
    [self show_after_touch_button_right:scroll_view];
    [self show_date_on_label:current_day];
}
- (void) show_after_touch_button_left: (UIScrollView*) view{
    view.hidden = FALSE;
	//[schedule_table scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
	[UIView beginAnimations:@"animateImageOff" context:NULL]; // Begin animation
	[view setFrame:CGRectOffset([view frame], -view.frame.size.width, 0)]; // Move imageView off screen
	[UIView commitAnimations]; // End animations
	[UIView beginAnimations:@"animateImageOn" context:NULL]; // Begin animation
	[UIView setAnimationDuration:0.25];
	[view setFrame:CGRectOffset([view frame], view.frame.size.width, 0)]; // Move imageView on screen
	[UIView commitAnimations]; // End animations
	
}
- (void) show_after_touch_button_right: (UIScrollView*) view{
    view.hidden = FALSE;
	//[schedule_table scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
	[UIView beginAnimations:@"animateImageOff" context:NULL]; // Begin animation
	[view setFrame:CGRectOffset([view frame], view.frame.size.width, 0)]; // Move imageView off screen
	[UIView commitAnimations]; // End animations
	[UIView beginAnimations:@"animateImageOn" context:NULL]; // Begin animation
	[UIView setAnimationDuration:0.25];
	[view setFrame:CGRectOffset([view frame], -view.frame.size.width, 0)]; // Move imageView on screen
	[UIView commitAnimations]; // End animations
}
- (void) create_daylabel{
    // add scrool view
    int count = [scheduleArray count]; 
    
    //UIScrollView *scroll_view;
    if (isPortrait) {
        scroll_view = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, [[UIScreen mainScreen] bounds].size.width , [[UIScreen mainScreen] bounds].size.height - 20 - toolbar.frame.size.height * 2)];
        scroll_view.contentSize = CGSizeMake(self.view.frame.size.width,count * 120 + 20);
    }
    else {
        scroll_view = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, [[UIScreen mainScreen] bounds].size.height , [[UIScreen mainScreen] bounds].size.width - 20 - toolbar.frame.size.height * 2)];
        scroll_view.contentSize = CGSizeMake(self.view.frame.size.height,count * 120 + 20);
    }
    [scroll_view setTag:1900];
    [self.view addSubview:scroll_view];
    [self.view bringSubviewToFront:toolbar];
    
    UIImage *myImage = [UIImage imageNamed:@"background_header_section.png"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:myImage];
    
    if (isPortrait) imageView.frame = CGRectMake([[UIScreen mainScreen] bounds].size.width/2 - 80/2,5,80,20);
    else imageView.frame = CGRectMake([[UIScreen mainScreen] bounds].size.height/2 - 80/2,5,80,20);
    [scroll_view addSubview:imageView];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents * comp = [calendar components:NSWeekdayCalendarUnit fromDate:current_day];
    
    NSString *thu = @"";
    if([comp weekday] == 1) // chu nhat
    {
        // ngay dau tuan la chu nhat
        thu = @"Chủ nhật";
    }
    else if([comp weekday] == 2)
    {
        thu = @"Thứ hai";
    }
    else if([comp weekday] == 3)
    {
        thu = @"Thứ ba";
    }
    else if([comp weekday] == 4)
    {
        thu = @"Thứ tư";
    }
    else if([comp weekday] == 5)
    {
        thu = @"Thứ năm";
    }
    else if([comp weekday] == 6)
    {
        thu = @"Thứ sáu";
    }
    else if([comp weekday] == 7)
    {
        thu = @"Thứ bảy";
    }
    // Do any additional setup after loading the view from its nib.
    UILabel *day_label;
    if(isPortrait) day_label = [[UILabel alloc] initWithFrame:CGRectMake([[UIScreen mainScreen] bounds].size.width/2 - 40, 6, 80, 20)];
    else day_label = [[UILabel alloc] initWithFrame:CGRectMake([[UIScreen mainScreen] bounds].size.height/2 - 40, 6, 80, 20)];
    day_label.textAlignment = UITextAlignmentCenter;
    day_label.text = thu;
    day_label.textColor = [UIColor blueColor];
    day_label.backgroundColor = [UIColor clearColor];
    [scroll_view addSubview:day_label];
}
- (void) create_scheduleView{
    if([scheduleArray count] != 0){
        int i = 30;
        int j = 0;
        // add cac doi tuong giua vao so buoi hoc co trong ngay
        for (Schedule *sche in scheduleArray) {
            UIView *pre_borderup= [[UIView alloc] initWithFrame:CGRectMake(0.0, i, 50.0, 1.0)];
            pre_borderup.backgroundColor = [UIColor grayColor];
            [scroll_view addSubview:pre_borderup];
            
            //        UIView *borderup= [[UIView alloc] initWithFrame:CGRectMake(50.0, i, 5.0, 1.0)];
            //        borderup.backgroundColor = [UIColor grayColor];
            //        [scroll_view addSubview:borderup];
            
            UILabel *timebegin_label = [[UILabel alloc] initWithFrame:CGRectMake(5.0, pre_borderup.frame.origin.y, 40.0 , 20.0)];
            timebegin_label.text = [self get_time_from_day_string:sche.from_Date];
            timebegin_label.backgroundColor = [UIColor clearColor];
            timebegin_label.minimumFontSize = 8.;
            timebegin_label.adjustsFontSizeToFitWidth = YES;
            [scroll_view addSubview:timebegin_label];
            ////////////////////////
            UIView *schedule_view;
            if(isPortrait)
                schedule_view= [[UIView alloc] initWithFrame:CGRectMake(50.0, i , [[UIScreen mainScreen] bounds].size.width - 55.0, 100.0)];
            else schedule_view= [[UIView alloc] initWithFrame:CGRectMake(50.0, i , [[UIScreen mainScreen] bounds].size.height - 55.0, 100.0)];
            if(j == 0)schedule_view.backgroundColor = [UIColor colorWithRed:(0/255.f) green:(250/255.f) blue:(154/255.f) alpha:0.8];
            else if(j == 1)schedule_view.backgroundColor = [UIColor colorWithRed:(240/255.f) green:(128/255.f) blue:(128/255.f) alpha:0.8];
            else if(j == 2)schedule_view.backgroundColor = [UIColor colorWithRed:(255/255.f) green:(128/255.f) blue:(0/255.f) alpha:0.8];
            else if(j == 3)schedule_view.backgroundColor = [UIColor colorWithRed:(193/255.f) green:(205/255.f) blue:(205/255.f) alpha:0.8];
            else schedule_view.backgroundColor = [UIColor colorWithRed:(193/255.f) green:(205/255.f) blue:(205/255.f) alpha:0.8];
            schedule_view.layer.cornerRadius = 5;
            schedule_view.layer.masksToBounds = YES;
            schedule_view.layer.borderColor = [UIColor blueColor].CGColor;
            schedule_view.layer.borderWidth = 2.0f;
            [scroll_view addSubview:schedule_view];
            
            UILabel *course_name = [[UILabel alloc] initWithFrame:CGRectMake(5.0, 3.0, schedule_view.frame.size.width - 5 , 20.0)];
            course_name.text = sche.course_Name;
            //        course_name.minimumFontSize = 8.;
            //        course_name.adjustsFontSizeToFitWidth = YES;
            //course_name.font = [UIFont systemFontOfSize:12.0];
            [course_name setFont:[UIFont boldSystemFontOfSize:12]];
            course_name.textColor = [UIColor redColor];
            course_name.backgroundColor = [UIColor clearColor];
            [schedule_view addSubview:course_name];
            
            NSString *tmp = @"Tên lớp: ";
            tmp = [tmp stringByAppendingString:sche.class_Name];
            UILabel *class_name = [[UILabel alloc] initWithFrame:CGRectMake(5.0, 25.0, schedule_view.frame.size.width - 5 , 20.0)];
            class_name.text = tmp;
            class_name.font = [UIFont systemFontOfSize:13.0];
            class_name.backgroundColor = [UIColor clearColor];
            [schedule_view addSubview:class_name];
            
            tmp = sche.facility_TypeName;
            tmp = [tmp stringByAppendingString:@": "];
            tmp = [tmp stringByAppendingString:sche.facility_Name];
            UILabel *room = [[UILabel alloc] initWithFrame:CGRectMake(5.0, 42.0, schedule_view.frame.size.width - 5 , 20.0)];
            room.text = tmp;
            room.font = [UIFont systemFontOfSize:13.0];
            room.backgroundColor = [UIColor clearColor];
            [schedule_view addSubview:room];
            
            tmp = @"Cơ sở: ";
            tmp = [tmp stringByAppendingString:sche.facility_RootName];
            UILabel *fac_root = [[UILabel alloc] initWithFrame:CGRectMake(5.0, 59.0, schedule_view.frame.size.width - 5 , 20.0)];
            fac_root.text = tmp;
            fac_root.font = [UIFont systemFontOfSize:13.0];
            fac_root.backgroundColor = [UIColor clearColor];
            [schedule_view addSubview:fac_root];
            
            tmp = @"Giảng viên: ";
            tmp = [tmp stringByAppendingString:sche.instructor_Name];
            UILabel *instructor = [[UILabel alloc] initWithFrame:CGRectMake(5.0, 76.0, schedule_view.frame.size.width - 5 , 20.0)];
            instructor.text = tmp;
            instructor.font = [UIFont systemFontOfSize:13.0];
            instructor.backgroundColor = [UIColor clearColor];
            [schedule_view addSubview:instructor];
            
            /////////////////////////
            UIView *pre_borderbottom= [[UIView alloc] initWithFrame:CGRectMake(0.0, i + 100, 50.0, 1.0)];
            pre_borderbottom.backgroundColor = [UIColor grayColor];
            [scroll_view addSubview:pre_borderbottom];
            
            UILabel *timeend_label = [[UILabel alloc] initWithFrame:CGRectMake(5.0, pre_borderbottom.frame.origin.y - 20, 40.0 , 20.0)];
            timeend_label.text = [self get_time_from_day_string:sche.thru_Date];
            timeend_label.textColor = [UIColor redColor];
            timeend_label.backgroundColor = [UIColor clearColor];
            timeend_label.minimumFontSize = 8.;
            timeend_label.adjustsFontSizeToFitWidth = YES;
            [scroll_view addSubview:timeend_label];
            
            
            i+=120;
            j++;
        }
    }
    else{
        UILabel *info_label;
        if(isPortrait) info_label = [[UILabel alloc] initWithFrame:CGRectMake(5.0, [[UIScreen mainScreen] bounds].size.height/2, [[UIScreen mainScreen] bounds].size.width - 5 , 20.0)];
        else info_label = [[UILabel alloc] initWithFrame:CGRectMake(5.0, [[UIScreen mainScreen] bounds].size.width/2, [[UIScreen mainScreen] bounds].size.height - 5 , 20.0)];
        info_label.text = @"Hôm nay không có lịch";
        info_label.font = [UIFont systemFontOfSize:15.0];
        info_label.backgroundColor = [UIColor clearColor];
        info_label.textAlignment = UITextAlignmentCenter;
        [scroll_view addSubview:info_label];

    }
}
- (IBAction) today_click: (id) sender{
    UIView *removeView;
    while((removeView = [self.view viewWithTag:1900]) != nil) {
        [removeView removeFromSuperview];
    }
    NSError *error = nil;
    NSDate * date_buf = current_day;
    
    NSDate *sourceDate = [NSDate date];
    NSLog(@"%@",sourceDate); //lay ngay va gio theo GMT 00
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    NSTimeZone* destinationTimeZone = [NSTimeZone systemTimeZone];
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:sourceDate];
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:sourceDate];
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    NSDate* destinationDate = [[NSDate alloc] initWithTimeInterval:interval sinceDate:sourceDate];
    NSLog(@"%@",destinationDate);
    
    current_day = destinationDate;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit ) fromDate:[NSDate date]];
    //create a date with these components
    NSDate *startDate = current_day;
    
    [components setMonth:0];
    [components setDay:1]; //reset the other components
    [components setYear:0]; //reset the other components
    NSDate *endDate = [calendar dateByAddingComponents:components toDate:startDate options:0];
    [self fetchedResult:@"Schedule" :@"from_Date"]; // requet toan bo ten truong trong core data
    NSPredicate *predicateHDT =[NSPredicate predicateWithFormat:@"(from_Date > %@) AND (from_Date <= %@)",startDate,endDate];    // truy van theo ten truong
    [fetchedResultsController.fetchRequest setPredicate:predicateHDT];
    if (![[self fetchedResultsController] performFetch:&error])
    {
        // Handle error
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        exit(-1);  // Fail
    }
    NSArray *results = [fetchedResultsController fetchedObjects];
    
    scheduleArray = [[NSMutableArray alloc]initWithArray:results];
    
    [self create_daylabel];
    [self create_scheduleView];
    NSComparisonResult result = [date_buf compare:current_day];
    if (result == NSOrderedAscending) {
        // ngay dang xem lich la ngay truoc ngay hom nay
        [self show_after_touch_button_right:scroll_view];
    }
    else if(result == NSOrderedDescending) {
        // ngay dang xem lich la ngay sau ngay hom nay
        [self show_after_touch_button_left:scroll_view];
    }    
    [self show_date_on_label:current_day];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskAll;
}
- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if(IS_IPAD()){
        UIView *removeView;
        while((removeView = [self.view viewWithTag:1900]) != nil) {
            [removeView removeFromSuperview];
        }
        [self create_daylabel];
        [self create_scheduleView];
    }
    if(IS_IPAD()) return YES;
    else return NO;
}
- (BOOL)shouldAutorotate {
    /*if(IS_IPAD()){
        UIView *removeView;
        while((removeView = [self.view viewWithTag:1900]) != nil) {
            [removeView removeFromSuperview];
        }
        [self create_daylabel];
        [self create_scheduleView];
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
         NSLog(@"%u",orientation);
         if (orientation==UIInterfaceOrientationPortraitUpsideDown || orientation==UIInterfaceOrientationPortrait) {
         isPortrait = TRUE;
         
         }
         
         else if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight) {
         isPortrait = FALSE;
         
         }
    }*/
    if(IS_IPAD()) return YES;
    else return NO;
}
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)  interfaceOrientation duration:(NSTimeInterval)duration
{
    
    if(IS_IPAD()){
        switch (interfaceOrientation) {
            case UIInterfaceOrientationPortrait:
                isPortrait = TRUE;
                break;
                
            case UIInterfaceOrientationPortraitUpsideDown:
                isPortrait = TRUE;
                break;
                
            case UIInterfaceOrientationLandscapeLeft:
                isPortrait = FALSE;
                break;
                
            case UIInterfaceOrientationLandscapeRight:
                isPortrait = FALSE;
                break;
                
            default:
                break;
        }
        UIView *removeView;
        while((removeView = [self.view viewWithTag:1900]) != nil) {
            [removeView removeFromSuperview];
        }
        [self create_daylabel];
        [self create_scheduleView];
    }
}
@end
