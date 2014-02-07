//
//  WeekScheduleController.m
//  MyDTUSchedule
//
//  Created by duc nguyen minh on 1/16/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "WeekScheduleController.h"

#import "ScheduleAppDelegate.h"
#import "MBProgressHUD.h"
#import <QuartzCore/QuartzCore.h> 
#import "Schedule.h"

#define USE_CUSTOM_DRAWING 1
@implementation WeekScheduleController
#define IS_IPAD() ([[UIDevice currentDevice] respondsToSelector:@selector(userInterfaceIdiom)] ? \
[[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad : NO)
@synthesize scheduleArray;
@synthesize managedObjectContext;
@synthesize fetchedResultsController;
@synthesize schedule_table;
@synthesize dateCompLabel;
@synthesize infoLabel;
@synthesize progressHud;
@synthesize toolbar;
@synthesize start_date;
@synthesize end_date;
@synthesize endday_toshow;


NSDate *current_day;
BOOL cochunhat = FALSE;
BOOL cothu2 = FALSE;
BOOL cothu3 = FALSE;
BOOL cothu4 = FALSE;
BOOL cothu5 = FALSE;
BOOL cothu6 = FALSE;
BOOL cothu7 = FALSE;
NSMutableArray *myArray;
NSMutableArray *thuArray;

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

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    //toolbar.tintColor = [UIColor darkGrayColor]; 16	78	139	
    [toolbar setTintColor:[UIColor colorWithRed:16.0/255.0 green:78.0/255.0 blue:139.0/255.0 alpha:0]];//[UIColor  colorWithRed:148/255.0 green:4.0/255.0 blue:4.0/255.0 alpha:0]];

    
    
    NSDate *sourceDate = [NSDate date];
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    NSTimeZone* destinationTimeZone = [NSTimeZone systemTimeZone];
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:sourceDate];
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:sourceDate];
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    NSDate* destinationDate = [[NSDate alloc] initWithTimeInterval:interval sinceDate:sourceDate];
    current_day = destinationDate;
    
    [self show_date_on_label:start_date];
    
    if([scheduleArray count] == 0)
    {
        // thong bao hom nay duoc nghi suong nhe
        infoLabel.hidden = FALSE;
    }
    else  infoLabel.hidden = TRUE;
    
    myArray = [[NSMutableArray array] init];
    thuArray = [[NSMutableArray array] init];
    
    
    [self create_dayname_array];
    [self create_scheduleView];
    
}

- (void) create_dayname_array{
    cochunhat = FALSE;
    cothu2 = FALSE;
    cothu3 = FALSE;
    cothu4 = FALSE;
    cothu5 = FALSE;
    cothu6 = FALSE;
    cothu7 = FALSE;
    // kiem tra xem co bao nhieu ngay hoc trong tuan
    NSLog(@"so buoi hoc: %d",[scheduleArray count]);
    for(Schedule *sche in scheduleArray){
        NSDate *day = [self stringToDate:sche.from_Date];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents * comp = [calendar components:NSWeekdayCalendarUnit fromDate:day];
        
        if([comp weekday] == 1 && cochunhat == FALSE)   { cochunhat = TRUE; [myArray addObject:@"Chủ nhật"]; }
        else if([comp weekday] == 2 && cothu2 == FALSE)   { cothu2 = TRUE; [myArray addObject:@"Thứ hai"]; }
        else if([comp weekday] == 3 && cothu3 == FALSE)   { cothu3 = TRUE; [myArray addObject:@"Thứ ba"]; }
        else if([comp weekday] == 4 && cothu4 == FALSE)   { cothu4 = TRUE; [myArray addObject:@"Thứ tư"]; }
        else if([comp weekday] == 5 && cothu5 == FALSE)   { cothu5 = TRUE; [myArray addObject:@"Thứ năm"]; }
        else if([comp weekday] == 6 && cothu6 == FALSE)   { cothu6 = TRUE; [myArray addObject:@"Thứ sáu"]; }
        else if([comp weekday] == 7 && cothu7 == FALSE)   { cothu7 = TRUE; [myArray addObject:@"Thứ bảy"]; }
    }
}
- (void) create_scheduleView{
    // tao scrollview 
    if (isPortrait) { // chieu thang
        scroll_view = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, [[UIScreen mainScreen] bounds].size.width , [[UIScreen mainScreen] bounds].size.height - 20 - toolbar.frame.size.height * 2)];
        scroll_view.contentSize = CGSizeMake(self.view.frame.size.width,[scheduleArray count] * 120 + [myArray count]*10);
    }
    else{
        scroll_view = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, [[UIScreen mainScreen] bounds].size.height , [[UIScreen mainScreen] bounds].size.width - 20 - toolbar.frame.size.height * 2)];
        scroll_view.contentSize = CGSizeMake(self.view.frame.size.height,[scheduleArray count] * 120 + [myArray count]*10);
    }
    //scroll_view.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [scroll_view setTag:1900];
    [self.view addSubview:scroll_view]; 
    [self.view bringSubviewToFront:toolbar];
    // bat dau hien thi len scrool view
    if([scheduleArray count] != 0){
        int i = 30;
        int j = 0;
        int index = 0;
        
        for(NSString *tmp in myArray){
            UIImage *myImage = [UIImage imageNamed:@"background_header_section1.png"];
            UIImageView *imageView = [[UIImageView alloc] initWithImage:myImage];
            if (isPortrait) imageView.frame = CGRectMake([[UIScreen mainScreen] bounds].size.width/2 - 130/2,i-25,130,20);
            else imageView.frame = CGRectMake([[UIScreen mainScreen] bounds].size.height/2 - 130/2,i-25,130,20);
            [scroll_view addSubview:imageView];
            BOOL is_draw_dayname = FALSE;
            thuArray = [self so_mon_hoc_trong_ngay:index];
            for (Schedule *sche in thuArray) {
                if(is_draw_dayname == FALSE){
                    NSString *day_String = @" ";
                    day_String = [day_String stringByAppendingString:[sche.from_Date substringWithRange:NSMakeRange (8, 2)]];
                    day_String = [day_String stringByAppendingString:@"/"];
                    day_String = [day_String stringByAppendingString:[sche.from_Date substringWithRange:NSMakeRange (5,2)]];
                    UILabel *day_label;
                    if (isPortrait) day_label = [[UILabel alloc] initWithFrame:CGRectMake([[UIScreen mainScreen] bounds].size.width/2 - 80,i - 24, 160, 20)];
                    else day_label = [[UILabel alloc] initWithFrame:CGRectMake([[UIScreen mainScreen] bounds].size.height/2 - 80,i - 24, 160, 20)];
                    day_label.textAlignment = UITextAlignmentCenter;
                    day_label.text = [tmp stringByAppendingString:day_String];
                    day_label.textColor = [UIColor blueColor];
                    day_label.backgroundColor = [UIColor clearColor];
                    [scroll_view addSubview:day_label];
                    is_draw_dayname = TRUE;
                }
                
                UIView *pre_borderup= [[UIView alloc] initWithFrame:CGRectMake(0.0, i, 50.0, 1.0)];
                pre_borderup.backgroundColor = [UIColor grayColor];
                [scroll_view addSubview:pre_borderup];
                
                UILabel *timebegin_label = [[UILabel alloc] initWithFrame:CGRectMake(5.0, pre_borderup.frame.origin.y, 40.0 , 20.0)];
                timebegin_label.text = [self get_time_from_day_string:sche.from_Date];
                timebegin_label.backgroundColor = [UIColor clearColor];
                timebegin_label.minimumFontSize = 8.;
                timebegin_label.adjustsFontSizeToFitWidth = YES;
                [scroll_view addSubview:timebegin_label];
                UIView *schedule_view;
                if (isPortrait) schedule_view= [[UIView alloc] initWithFrame:CGRectMake(50.0, i , [[UIScreen mainScreen] bounds].size.width - 55.0, 100.0)];
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
            i+=10;
            j = 0;
            index++;
        }
    }
    else{
        UILabel *info_label;
        if(isPortrait) info_label = [[UILabel alloc] initWithFrame:CGRectMake(5.0, [[UIScreen mainScreen] bounds].size.height/2, [[UIScreen mainScreen] bounds].size.width - 5 , 20.0)];
        else info_label = [[UILabel alloc] initWithFrame:CGRectMake(5.0, [[UIScreen mainScreen] bounds].size.width/2, [[UIScreen mainScreen] bounds].size.height - 5 , 20.0)];
        info_label.text = @"Tuần này không có lịch";
        info_label.font = [UIFont systemFontOfSize:15.0];
        info_label.backgroundColor = [UIColor clearColor];
        info_label.textAlignment = UITextAlignmentCenter;
        [scroll_view addSubview:info_label];
        
    }
}
- (IBAction) previous_day_click: (id) sender{ 
    UIView *removeView;
    while((removeView = [self.view viewWithTag:1900]) != nil) {
        [removeView removeFromSuperview];
    }
    
    [myArray removeAllObjects];
    [scheduleArray removeAllObjects];
    NSError *error = nil;
    
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit ) fromDate:[NSDate date]];
    //create a date with these components 
    [components setMonth:0];
    [components setDay:-7]; //reset the other components
    [components setYear:0]; //reset the other components
    NSDate *startDate = [calendar dateByAddingComponents:components toDate:start_date options:0];
    
    [components setMonth:0];
    [components setDay:7]; //reset the other components
    [components setYear:0]; //reset the other components
    NSDate *endDate = [calendar dateByAddingComponents:components toDate:startDate options:0];
    
    [components setMonth:0];
    [components setDay:6]; //reset the other components
    [components setYear:0]; //reset the other components
    endday_toshow = [calendar dateByAddingComponents:components toDate:startDate options:0];
    
    start_date = startDate; // cap nhat moi ngay bat dau
    end_date = endDate;
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
    
    [self create_dayname_array];
    
    [self create_scheduleView];
    [self show_after_touch_button_left:scroll_view];
    [self show_date_on_label:start_date];
} 

- (IBAction) next_day_click: (id) sender{ 
    UIView *removeView;
    while((removeView = [self.view viewWithTag:1900]) != nil) {
        [removeView removeFromSuperview];
    }
    
    [myArray removeAllObjects];
    [scheduleArray removeAllObjects];
    NSError *error = nil;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit ) fromDate:[NSDate date]];
    //create a date with these components 
    [components setMonth:0];
    [components setDay:7]; //reset the other components
    [components setYear:0]; //reset the other components
    NSDate *startDate = [calendar dateByAddingComponents:components toDate:start_date options:0];
    
    [components setMonth:0];
    [components setDay:7]; //reset the other components
    [components setYear:0]; //reset the other components
    NSDate *endDate = [calendar dateByAddingComponents:components toDate:startDate options:0];
    start_date = startDate; // cap nhat moi ngay bat dau
    end_date = endDate;
    
    [components setMonth:0];
    [components setDay:6]; //reset the other components
    [components setYear:0]; //reset the other components
    endday_toshow = [calendar dateByAddingComponents:components toDate:startDate options:0];
    
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
    
    [self create_dayname_array];
    
    [self create_scheduleView];
    [self show_after_touch_button_right:scroll_view];
    
    [self show_date_on_label:start_date];
} 

- (IBAction) today_click: (id) sender{
    UIView *removeView;
    while((removeView = [self.view viewWithTag:1900]) != nil) {
        [removeView removeFromSuperview];
    }
    [myArray removeAllObjects];
    [scheduleArray removeAllObjects];
    
    NSError *error = nil;
    //==========    He dao tao  ===============  
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *startDate;
    NSDate *endDate;
    NSDateComponents * comp = [calendar components:NSWeekdayCalendarUnit fromDate:[NSDate date]];
    
    NSDateComponents *components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit ) fromDate:[NSDate date]];
    
    NSDate *sourceDate = [NSDate date];
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    NSTimeZone* destinationTimeZone = [NSTimeZone systemTimeZone];
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:sourceDate];
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:sourceDate];
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    NSDate* current_day = [[NSDate alloc] initWithTimeInterval:interval sinceDate:sourceDate];
    
    if([comp weekday] == 1) // chu nhat
    {
        // ngay dau tuan la chu nhat
        startDate = current_day;
    }
    else if([comp weekday] == 2) // thu hai
    {
        // ngay dau tuan la chu nhat
        [components setMonth:0];
        [components setDay:-1]; //reset the other components
        [components setYear:0]; //reset the other components
        
        startDate = [calendar dateByAddingComponents:components toDate:current_day options:0];
    }
    else if([comp weekday] == 3) // thu 3
    {
        // ngay dau tuan la chu nhat
        [components setMonth:0];
        [components setDay:-2]; //reset the other components
        [components setYear:0]; //reset the other components
        
        startDate = [calendar dateByAddingComponents:components toDate:current_day options:0];
    }
    else if([comp weekday] == 4) // thu 4
    {
        // ngay dau tuan la chu nhat
        [components setMonth:0];
        [components setDay:-3]; //reset the other components
        [components setYear:0]; //reset the other components
        
        startDate = [calendar dateByAddingComponents:components toDate:current_day options:0];
    }
    else if([comp weekday] == 5) // thu 5
    {
        // ngay dau tuan la chu nhat
        [components setMonth:0];
        [components setDay:-4]; //reset the other components
        [components setYear:0]; //reset the other components
        
        startDate = [calendar dateByAddingComponents:components toDate:current_day options:0];
    }
    else if([comp weekday] == 6) // thu 6
    {
        // ngay dau tuan la chu nhat
        [components setMonth:0];
        [components setDay:-5]; //reset the other components
        [components setYear:0]; //reset the other components
        
        startDate = [calendar dateByAddingComponents:components toDate:current_day options:0];
    }
    else if([comp weekday] == 7) // thu 7
    {
        // ngay dau tuan la chu nhat
        [components setMonth:0];
        [components setDay:-6]; //reset the other components
        [components setYear:0]; //reset the other components
        
        startDate = [calendar dateByAddingComponents:components toDate:current_day options:0];
    }
    
    //create a date with these components 
    [components setMonth:0];
    [components setDay:7]; //reset the other components
    [components setYear:0]; //reset the other components
    endDate = [calendar dateByAddingComponents:components toDate:startDate options:0];     
    
    [components setMonth:0];
    [components setDay:6]; //reset the other components
    [components setYear:0]; //reset the other components
    endday_toshow = [calendar dateByAddingComponents:components toDate:startDate options:0];
    
    [self fetchedResult:@"Schedule" :@"from_Date"]; // requet toan bo ten truong trong core data
    NSPredicate *predicateHDT =[NSPredicate predicateWithFormat:@"(from_Date > %@) AND (from_Date <= %@)",startDate,endDate];    // truy van theo ten truong
    [fetchedResultsController.fetchRequest setPredicate:predicateHDT];
    if (![[self fetchedResultsController] performFetch:&error])
    {
        // Handle error
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        exit(-1);  // Fail 
    }
    NSArray *results = [fetchedResultsController fetchedObjects]; // neu khong co loi, lay ket qua tra ve la truong DH Duy tan
     
    
    scheduleArray = [[NSMutableArray alloc]initWithArray:results];
    
    // thiet lap cac chi so truoc khi load lai table view
    [self create_dayname_array];
    [self create_scheduleView];
    NSComparisonResult result = [start_date compare:[NSDate date]];
    if (result == NSOrderedAscending) {  
        // ngay dang xem lich la ngay truoc ngay hom nay
        [self show_after_touch_button_right:scroll_view];
    }
    else if(result == NSOrderedDescending) { 
        // ngay dang xem lich la ngay sau ngay hom nay
        [self show_after_touch_button_left:scroll_view];
    }
    start_date = startDate;
    end_date = endDate;
    
    [self show_date_on_label:start_date];
} 

- (IBAction) AddToCalendar_click: (id) sender{
    
	[[UIApplication sharedApplication] cancelAllLocalNotifications];
}

- (NSString *) date_to_string:(NSDate *)day{
    NSString * string;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"MM-dd-yyyy HH:mm"];
	//[formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:-18000]];
    
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	string = [formatter stringFromDate:day];
    
    NSString *buf;
    buf = [string substringWithRange:NSMakeRange (3, 2)];
    buf = [buf stringByAppendingString:@"/"];
    buf = [buf stringByAppendingString:[string substringWithRange:NSMakeRange (0,2)]];
    buf = [buf stringByAppendingString:@"-"];
    
    string = [formatter stringFromDate:endday_toshow];
    buf = [buf stringByAppendingString:[string substringWithRange:NSMakeRange (3,2)]];
    buf = [buf stringByAppendingString:@"/"];
    buf = [buf stringByAppendingString:[string substringWithRange:NSMakeRange (0,2)]];
     
    return buf;
}
- (void) show_date_on_label: (NSDate*) day_show{
    NSString *tmp = [self date_to_string:day_show];
    self.title = tmp;
}

- (NSDate *)stringToDate: (NSString *)string {
    //2013-01-07T15:15:00+07:00
    //NSArray *arr = [string componentsSeparatedByString:@"T"];
    //NSString *str = [arr objectAtIndex:0];
    //    NSLog(@"strdate: %@",str); // strdate: 2011-02-28
    //NSString *str1 = [arr objectAtIndex:1];
    //    NSLog(@"strdate: %@",str1);
    
    //NSArray *arr1 = [str1 componentsSeparatedByString:@"-"];
    //NSString *str2 = [arr1 objectAtIndex:0];
    //    NSLog(@"strdate: %@",str2);
    
    NSString *tmp1 = [string substringWithRange:NSMakeRange (0, 10)];
    NSString *tmp2 = [string substringWithRange:NSMakeRange (11, 8)];
    NSString *resultTime = [NSString stringWithFormat:@"%@ %@", tmp1, tmp2 ];
    //    NSLog(@"strdate: %@",resultTime);
    
    NSDateFormatter *dFormat = [[NSDateFormatter alloc]init];
    dFormat.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    //  NSTimeZone *tz = [NSTimeZone timeZoneForSecondsFromGMT:(+7 * 3600)];
    [dFormat setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];//
    NSDate *gmtDate = [dFormat dateFromString:resultTime];
    //    NSLog(@"%@",gmtDate);
    return gmtDate;
}
- (int) so_ngay_hoc_trong_tuan{
    int dem = 0;
    if(cochunhat == TRUE) dem++;
    if(cothu2 == TRUE) dem++;
    if(cothu3 == TRUE) dem++;
    if(cothu4 == TRUE) dem++;
    if(cothu5 == TRUE) dem++;
    if(cothu6 == TRUE) dem++;
    if(cothu7 == TRUE) dem++;
    return dem;
}
- (void) show_after_touch_button_left:(UIScrollView*) view{
	[UIView beginAnimations:@"animateImageOff" context:NULL]; // Begin animation
	[view setFrame:CGRectOffset([view frame], -view.frame.size.width, 0)]; // Move imageView off screen
	[UIView commitAnimations]; // End animations
	[UIView beginAnimations:@"animateImageOn" context:NULL]; // Begin animation
	[UIView setAnimationDuration:0.25];
	[view setFrame:CGRectOffset([view frame], view.frame.size.width, 0)]; // Move imageView on screen
	[UIView commitAnimations]; // End animations
	
}
- (void) show_after_touch_button_right:(UIScrollView*)view{
	//[schedule_table scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
	[UIView beginAnimations:@"animateImageOff" context:NULL]; // Begin animation
	[view setFrame:CGRectOffset([view frame], view.frame.size.width, 0)]; // Move imageView off screen
	[UIView commitAnimations]; // End animations
	[UIView beginAnimations:@"animateImageOn" context:NULL]; // Begin animation
	[UIView setAnimationDuration:0.25];
	[view setFrame:CGRectOffset([view frame], -view.frame.size.width, 0)]; // Move imageView on screen
	[UIView commitAnimations]; // End animations
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
// ham lay so mon hoc trong mot ngay
// tra ve mot mang cac schedule
- (NSMutableArray *) so_mon_hoc_trong_ngay:(NSInteger)section{
    NSMutableArray *buf_array = [[NSMutableArray alloc]init];
    NSString * string = [myArray objectAtIndex:section];
    int thu_from_section = 0;
    if([string isEqualToString:@"Chủ nhật"]) // lay thu co buoi hoc trong tuan
    {
        thu_from_section = 1;
    }
    else if([string isEqualToString:@"Thứ hai"]) // lay thu co buoi hoc trong tuan
    {
        thu_from_section = 2;
    }
    else if([string isEqualToString:@"Thứ ba"]) // lay thu co buoi hoc trong tuan
    {
        thu_from_section = 3;
    }
    else if([string isEqualToString:@"Thứ tư"]) // lay thu co buoi hoc trong tuan
    {
        thu_from_section = 4;
    }
    else if([string isEqualToString:@"Thứ năm"]) // lay thu co buoi hoc trong tuan
    {
        thu_from_section = 5;
    }
    else if([string isEqualToString:@"Thứ sáu"]) // lay thu co buoi hoc trong tuan
    {
        thu_from_section = 6;
    }
    else if([string isEqualToString:@"Thứ bảy"]) // lay thu co buoi hoc trong tuan
    {
        thu_from_section = 7;
    }
    
    for(Schedule *sche in scheduleArray){
        NSDate *day = [self stringToDate:sche.from_Date];
        NSCalendar *calendar = [NSCalendar currentCalendar]; 
        NSDateComponents * comp = [calendar components:NSWeekdayCalendarUnit fromDate:day];
        
        if([comp weekday] == thu_from_section)   { [buf_array addObject:sche]; } 
    } 
    return buf_array;
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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
        [self create_scheduleView];
    }
    if(IS_IPAD()) return YES;
    else return NO;
}
- (BOOL)shouldAutorotate {
    /*if(IS_IPAD()){
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        NSLog(@"%u",orientation);
        if (orientation==UIInterfaceOrientationPortraitUpsideDown || orientation==UIInterfaceOrientationPortrait) {
            isPortrait = TRUE;
        }
        else if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight) {
            isPortrait = FALSE;
        }
        UIView *removeView;
        while((removeView = [self.view viewWithTag:1900]) != nil) {
            [removeView removeFromSuperview];
        }
        [self create_scheduleView];
    }*/
    if(IS_IPAD()) return YES;
    else return NO;
}
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)  interfaceOrientation duration:(NSTimeInterval)duration
{
    if (IS_IPAD()) {
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
        [self create_scheduleView];
    }
        
}
@end
