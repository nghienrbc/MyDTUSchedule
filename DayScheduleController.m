//
//  DayScheduleController.m
//  MyDTUSchedule
//
//  Created by duc nguyen minh on 1/15/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "DayScheduleController.h"

#import "ScheduleAppDelegate.h"
#import <QuartzCore/QuartzCore.h> 
#import "Schedule.h"

#define USE_CUSTOM_DRAWING 1

@implementation DayScheduleController
@synthesize scheduleArray;
@synthesize managedObjectContext;
@synthesize fetchedResultsController;
@synthesize schedule_table; 
@synthesize infoLabel;
@synthesize toolbar;
@synthesize previous_button;
@synthesize next_button;
NSDate *current_day;
NSMutableArray *scheduleArray_buf;
NSDate *date_begin_on_database;
NSDate *date_end_on_database;
/*-(NSFetchedResultsController *) fetchedResult : (NSString *)entityName : (NSString *) sortby {
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName: entityName]; 
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:sortby
                                                                                     ascending:YES
                                                                                      selector:@selector(localizedCaseInsensitiveCompare:)]];
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
    return self.fetchedResultsController;
}*/

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
    [toolbar setTintColor:[UIColor colorWithRed:20/255.0 green:132.0/255.0 blue:157.0/255.0 alpha:0]];//[UIColor  colorWithRed:148/255.0 green:4.0/255.0 blue:4.0/255.0 alpha:0]];
    
    self.title = @"Lịch ngày";
    //UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg.jpg"]];
    //schedule_table.backgroundColor = [UIColor clearColor];
    [schedule_table setBackgroundView:nil];
    [schedule_table setBackgroundColor:[UIColor clearColor]];
	schedule_table.alpha = 1.0;
    schedule_table.separatorStyle = UITableViewCellSeparatorStyleNone;
	schedule_table.rowHeight = 150;
    
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
    
    
    
    [self show_date_on_label:current_day];
    
    if([scheduleArray count] == 0)
    {
        // thong bao hom nay duoc nghi suong nhe
        infoLabel.hidden = FALSE;
    }
    else  infoLabel.hidden = TRUE;
	/*schedule_table.layer.borderWidth = 3.5;  
	schedule_table.layer.borderColor = [UIColor brownColor].CGColor;*/
    // Do any additional setup after loading the view from its nib.
    
    // lấy hết toàn bộ dữ liệu trong bảng, vì bảng chứa nhiều nhất là dữ liệu của mổ học kỳ
    /*NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"from_Date"
                                                                                     ascending:YES
                                                                                      selector:@selector(localizedCaseInsensitiveCompare:)]];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Schedule" inManagedObjectContext:self.managedObjectContext];
    [request setEntity:entity];
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    NSError *error;
    NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
    scheduleArray_buf = [[NSMutableArray alloc]initWithArray:results];
    
    
    Schedule *schedule = nil;  
    schedule = [scheduleArray_buf objectAtIndex:0];
    date_begin_on_database = [self stringToDate:schedule.from_Date];// lay duoc ngay dau tien 
    schedule = [scheduleArray_buf objectAtIndex:[scheduleArray_buf count] - 1];  
    date_end_on_database = [self stringToDate:schedule.from_Date];// lay duoc ngay cuoi cung*/
}

- (IBAction) previous_day_click: (id) sender{  
    //next_button.enabled = TRUE;
    NSError *error = nil;
    //==========    He dao tao  =============== 
    //2013-01-07T15:15:00+07:00
    //NSDate *day;
    
    //NSDate *date1 = [NSDate date];
    
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
    
    // so sanh ngay dang xet voi ngay dau tien trong database
    /*NSComparisonResult result = [current_day compare:date_begin_on_database];
    if (result == NSOrderedAscending) {  
        // ngay dang xem lich la ngay truoc ngay dau tien trong co so du lieu
        // -> hien thi thong bao ngay nay thuoc ve hoc ky truoc
        infoLabel.hidden = FALSE;
        infoLabel.text = @"Ngày này của học kỳ trước rồi";
        schedule_table.hidden = TRUE;
        // disable previous button
        previous_button.enabled = FALSE;
    }
    else if(result == NSOrderedDescending) { */
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
        
        [schedule_table reloadData];
        if([scheduleArray count] == 0)
        {
            // thong bao hom nay duoc nghi suong nhe
            infoLabel.hidden = FALSE;
            infoLabel.text = @"Hôm nay được nghỉ, sướng nha";
            schedule_table.hidden = TRUE;
        }
        else  {
            infoLabel.hidden = TRUE;
        }
        
        [self show_after_touch_button_left];
        
    //}
    
    [self show_date_on_label:current_day];
    
} 

- (IBAction) next_day_click: (id) sender{
    // tien hanh chan duoi. neu ngay dang kiem tra la ngay cuoi cung trong database thi dung
    //previous_button.enabled = TRUE;
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
    
    // so sanh ngay dang xet voi ngay dau tien trong database
    /*NSComparisonResult result = [current_day compare:date_end_on_database];
    if (result == NSOrderedDescending) {  
        // ngay dang xem lich la ngay truoc ngay cuoi cung trong co so du lieu
        // -> hien thi thong bao ngay nay thuoc ve hoc ky sau
        infoLabel.hidden = FALSE;
        infoLabel.text = @"Ngày này của học kỳ sau rồi";
        schedule_table.hidden = TRUE;
        // disable previous button
        next_button.enabled = FALSE;
    }
    else if(result == NSOrderedAscending) { */
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
        
        [schedule_table reloadData];
        if([scheduleArray count] == 0)
        {
            // thong bao hom nay duoc nghi suong nhe
            infoLabel.hidden = FALSE;
            infoLabel.text = @"Hôm nay được nghỉ, sướng nha";
            schedule_table.hidden = TRUE;
        }
        else  infoLabel.hidden = TRUE;
        [self show_after_touch_button_right];
        
    //}
    
    [self show_date_on_label:current_day];
} 

- (IBAction) today_click: (id) sender{
    
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
     
    /*NSComparisonResult result = [current_day compare:date_begin_on_database];
    if (result == NSOrderedAscending) {  
        // ngay dang xem lich la ngay truoc ngay dau tien trong co so du lieu
        // -> hien thi thong bao ngay nay thuoc ve hoc ky truoc
        infoLabel.hidden = FALSE;
        infoLabel.text = @"Ngày này của học kỳ trước rồi";
        // disable previous button
        previous_button.enabled = FALSE;
    }
    else{
        result = [current_day compare:date_end_on_database];
        if (result == NSOrderedDescending) {  
            // ngay dang xem lich la ngay truoc ngay dau tien trong co so du lieu
            // -> hien thi thong bao ngay nay thuoc ve hoc ky truoc
            infoLabel.hidden = FALSE;
            infoLabel.text = @"Ngày này của học kỳ sau rồi";
            // disable previous button
            next_button.enabled = FALSE;
        }
        else if(result == NSOrderedAscending) {
            previous_button.enabled = TRUE;
            next_button.enabled = TRUE;*/
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
            
            [schedule_table reloadData];
            if([scheduleArray count] == 0)
            {
                // thong bao hom nay duoc nghi suong nhe
                infoLabel.hidden = FALSE;
                infoLabel.text = @"Hôm nay được nghỉ, sướng nha";
                schedule_table.hidden = TRUE;
            }
            else  infoLabel.hidden = TRUE;
       // }
        
        NSComparisonResult result = [date_buf compare:current_day];
        if (result == NSOrderedAscending) {  
            // ngay dang xem lich la ngay truoc ngay hom nay
            [self show_after_touch_button_right];
        }
        else if(result == NSOrderedDescending) { 
            // ngay dang xem lich la ngay sau ngay hom nay
            [self show_after_touch_button_left];
        }

   // }  
    [self show_date_on_label:current_day];
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
    
	string = [string substringWithRange:NSMakeRange (0, 10)];
    return string;
}
- (void) show_date_on_label: (NSDate*) day_show{
    NSString *tmp = [self date_to_string:day_show];
    self.title = tmp;
}

- (NSDate *)stringToDate: (NSString *)string {
    
    NSArray *arr = [string componentsSeparatedByString:@"T"];
    NSString *str = [arr objectAtIndex:0];
    //    NSLog(@"strdate: %@",str); // strdate: 2011-02-28
    
    NSString *str1 = [arr objectAtIndex:1];
    //    NSLog(@"strdate: %@",str1);
    
    NSArray *arr1 = [str1 componentsSeparatedByString:@"+"]; 
    NSString *str2 = [arr1 objectAtIndex:0];
    //    NSLog(@"strdate: %@",str2);
    
    NSString *resultTime = [NSString stringWithFormat:@"%@ %@", str, str2 ];
    //    NSLog(@"strdate: %@",resultTime);
    
    NSDateFormatter *dFormat = [[NSDateFormatter alloc]init];
    dFormat.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    //  NSTimeZone *tz = [NSTimeZone timeZoneForSecondsFromGMT:(+7 * 3600)];
    [dFormat setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];//
    NSDate *gmtDate = [dFormat dateFromString:resultTime];
    //    NSLog(@"%@",gmtDate);
    return gmtDate;
}
- (void) show_after_touch_button_left{ 
    schedule_table.hidden = FALSE;
	//[schedule_table scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
	[UIView beginAnimations:@"animateImageOff" context:NULL]; // Begin animation
	[schedule_table setFrame:CGRectOffset([schedule_table frame], -schedule_table.frame.size.width, 0)]; // Move imageView off screen
	[UIView commitAnimations]; // End animations
	[UIView beginAnimations:@"animateImageOn" context:NULL]; // Begin animation
	[UIView setAnimationDuration:0.25];
	[schedule_table setFrame:CGRectOffset([schedule_table frame], schedule_table.frame.size.width, 0)]; // Move imageView on screen
	[UIView commitAnimations]; // End animations
	
}
- (void) show_after_touch_button_right{ 
    schedule_table.hidden = FALSE;
	//[schedule_table scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
	[UIView beginAnimations:@"animateImageOff" context:NULL]; // Begin animation
	[schedule_table setFrame:CGRectOffset([schedule_table frame], schedule_table.frame.size.width, 0)]; // Move imageView off screen
	[UIView commitAnimations]; // End animations
	[UIView beginAnimations:@"animateImageOn" context:NULL]; // Begin animation
	[UIView setAnimationDuration:0.25];
	[schedule_table setFrame:CGRectOffset([schedule_table frame], -schedule_table.frame.size.width, 0)]; // Move imageView on screen
	[UIView commitAnimations]; // End animations
}
- (NSString *)get_time_from_day_string:(NSString*)string
{
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
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
 
//
// numberOfSectionsInTableView:
//
// Return the number of sections for the table.
//
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
} 
//
// tableView:numberOfRowsInSection:
//
// Returns the number of rows in a given section.
//
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [scheduleArray count];
}
//
// tableView:cellForRowAtIndexPath:
//
// Returns the cell for a given indexPath.
//
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
#if USE_CUSTOM_DRAWING
	const NSInteger TOP_LABEL_TAG = 1001;
	const NSInteger BOTTOM_LABEL_TAG = 1002;
	UILabel *topLabel;
	UITextView *bottomLabel;
#endif
    
	static NSString *CellIdentifier = @"Cell";
	UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil)
	{
		//
		// Create the cell.
		//
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle 
                                                       reuseIdentifier:CellIdentifier];
        
		//cell = [[UITableViewCell alloc]  initWithFrame:CGRectZero
        //  reuseIdentifier:CellIdentifier];
         
         
        /*if (cell == nil) {
            //cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell = [self CreateMultilinesCell:CellIdentifier];
        }*/
        
        // Configure the cell...
        
#if USE_CUSTOM_DRAWING
		UIImage *indicatorImage = [UIImage imageNamed:@"indicator.png"];
		cell.accessoryView =
        [[UIImageView alloc]
          initWithImage:indicatorImage];
		
		const CGFloat LABEL_HEIGHT = 20; 
        
		//
		// Create the label for the top row of text
		//
		topLabel = [[UILabel alloc] initWithFrame: CGRectMake(
                    2.0 * cell.indentationWidth,15,
                     aTableView.bounds.size.width -
                      4.0 * cell.indentationWidth
                     - indicatorImage.size.width,
                     LABEL_HEIGHT)];
		[cell.contentView addSubview:topLabel];
        
		//
		// Configure the properties for the text that are the same on every row
		//
		topLabel.tag = TOP_LABEL_TAG;
		topLabel.backgroundColor = [UIColor clearColor];
		topLabel.textColor = [UIColor colorWithRed:(125/255.f) green:(38/255.f) blue:(205/255.f) alpha:1.0];
		topLabel.highlightedTextColor = [UIColor colorWithRed:1.0 green:1.0 blue:0.9 alpha:1.0];
		topLabel.font = [UIFont systemFontOfSize:[UIFont labelFontSize]];
        
        
		//
		// Create the label for the top row of text
		//
		bottomLabel = [[UITextView alloc] initWithFrame: CGRectMake( 
                     2.0 * cell.indentationWidth, 35, aTableView.bounds.size.width -
                     4.0 * cell.indentationWidth - indicatorImage.size.width, 120)];
		[cell.contentView addSubview:bottomLabel]; 
        
		//
		// Configure the properties for the text that are the same on every row
		//
		bottomLabel.tag = BOTTOM_LABEL_TAG;
		bottomLabel.backgroundColor = [UIColor clearColor];
		bottomLabel.textColor = [UIColor colorWithRed:0.25 green:0.0 blue:0.0 alpha:1.0]; 
		bottomLabel.font = [UIFont systemFontOfSize:[UIFont labelFontSize] - 4];
        bottomLabel.editable = FALSE;
        bottomLabel.scrollEnabled = FALSE; 
        
        		//
		// Create a background image view.
		//
		cell.backgroundView = [[UIImageView alloc] init];
		cell.selectedBackgroundView = [[UIImageView alloc] init];
#endif
	}
    
#if USE_CUSTOM_DRAWING
	else
	{
		topLabel = (UILabel *)[cell viewWithTag:TOP_LABEL_TAG];
		bottomLabel = (UITextView *)[cell viewWithTag:BOTTOM_LABEL_TAG];
	}
    
    
    Schedule *schedule = nil;  
    schedule = [scheduleArray objectAtIndex:indexPath.row];
    
    topLabel.text = schedule.course_Name;
    
    NSString *tmp = @"Tên Lớp: ";
    tmp = [tmp stringByAppendingString:schedule.class_Name];
    tmp = [tmp stringByAppendingString:@"\nCơ sở: "]; 
    tmp = [tmp stringByAppendingString:schedule.facility_RootName];
    tmp = [tmp stringByAppendingString:@" - "]; 
    tmp = [tmp stringByAppendingString:schedule.facility_Name];    
    tmp = [tmp stringByAppendingString:@"\nThời gian: "];
    
    
    tmp = [tmp stringByAppendingString:[self get_time_from_day_string:schedule.from_Date]];
    tmp = [tmp stringByAppendingString:@" - "];
    tmp = [tmp stringByAppendingString:[self get_time_from_day_string:schedule.thru_Date]]; 
    tmp = [tmp stringByAppendingString:@"\nGiảng viên: "]; 
    tmp = [tmp stringByAppendingString:schedule.instructor_Name]; 
    
    bottomLabel.text = tmp; 

	//
	// Set the background and selected background images for the text.
	// Since we will round the corners at the top and bottom of sections, we
	// need to conditionally choose the images based on the row index and the
	// number of rows in the section.
	//
	UIImage *rowBackground;
	UIImage *selectionBackground;
	NSInteger sectionRows = [aTableView numberOfRowsInSection:[indexPath section]];
	NSInteger row = [indexPath row];
	if (row == 0 && row == sectionRows - 1)
	{
		rowBackground = [UIImage imageNamed:@"topAndBottomRow.png"];
		selectionBackground = [UIImage imageNamed:@"topAndBottomRowSelected.png"];
	}
	else if (row == 0)
	{
		rowBackground = [UIImage imageNamed:@"topRow.png"];
		selectionBackground = [UIImage imageNamed:@"topRowSelected.png"];
	}
	else if (row == sectionRows - 1)
	{
		rowBackground = [UIImage imageNamed:@"bottomRow.png"];
		selectionBackground = [UIImage imageNamed:@"bottomRowSelected.png"];
	}
	else
	{
		rowBackground = [UIImage imageNamed:@"middleRow.png"];
		selectionBackground = [UIImage imageNamed:@"middleRowSelected.png"];
	}
	((UIImageView *)cell.backgroundView).image = rowBackground;
	((UIImageView *)cell.selectedBackgroundView).image = selectionBackground;
	
//
//#else
//	cell.text = [NSString stringWithFormat:@"Cell at row %ld.", [indexPath row]];
#endif
	
	return cell;
}


// Tao UITableView voi multi-lines
//======================
/*#pragma mark 
#pragma mark Helpers

#define CONST_Cell_height 44.0f
#define CONST_Cell_width 270.0f

#define CONST_textLabelFontSize     16
#define CONST_detailLabelFontSize   12

static UIFont *subFont;
static UIFont *titleFont;

- (UIFont*) TitleFont;{
	if (!titleFont) titleFont = [UIFont fontWithName:@"Arial" size:CONST_textLabelFontSize];//[UIFont boldSystemFontOfSize:CONST_textLabelFontSize];
	return titleFont;
}
- (UIFont*) SubFont;{
	if (!subFont) subFont = [UIFont fontWithName:@"Georgia" size:CONST_detailLabelFontSize];//[UIFont systemFontOfSize:CONST_detailLabelFontSize];
	return subFont;
}
- (UITableViewCell*) CreateMultilinesCell :(NSString*)cellIdentifier{
	UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle 
                                                   reuseIdentifier:cellIdentifier];
	
	cell.textLabel.numberOfLines = 0;
	cell.textLabel.font = [self TitleFont];
	
	cell.detailTextLabel.numberOfLines = 0;
	cell.detailTextLabel.font = [self SubFont];
	cell.detailTextLabel.textColor  =  [UIColor redColor];
	return cell;
}
- (int) heightOfCellWithTitle :(NSString*)titleText andSubtitle:(NSString*)subtitleText{
	CGSize titleSize = {0, 0};
	CGSize subtitleSize = {0, 0};
	
	if (titleText && ![titleText isEqualToString:@""]) 
		titleSize = [titleText sizeWithFont:[self TitleFont] 
						  constrainedToSize:CGSizeMake(CONST_Cell_width, 1000) 
							  lineBreakMode:UILineBreakModeWordWrap];
	
	if (subtitleText && ![subtitleText isEqualToString:@""]) 
		subtitleSize = [subtitleText sizeWithFont:[self SubFont] 
								constrainedToSize:CGSizeMake(CONST_Cell_width, 1000) 
									lineBreakMode:UILineBreakModeWordWrap];
	
	return titleSize.height + subtitleSize.height + 20;
}
#pragma mark 
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{ 
        return [scheduleArray count]; 
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        //cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell = [self CreateMultilinesCell:CellIdentifier];
    }
    Schedule *schedule = nil;  
        schedule = [scheduleArray objectAtIndex:indexPath.row];
    
    // Configure the cell...
    cell.textLabel.text = schedule.course_Name;
    NSString *tmp = @"Tên Lớp: ";
    tmp = [tmp stringByAppendingString:schedule.class_Name];
    tmp = [tmp stringByAppendingString:@"\nCơ sở: "]; 
    tmp = [tmp stringByAppendingString:schedule.facility_RootName];
    tmp = [tmp stringByAppendingString:@" - "]; 
    tmp = [tmp stringByAppendingString:schedule.facility_Name];    
    tmp = [tmp stringByAppendingString:@"\nThời gian: "]; 
    tmp = [tmp stringByAppendingString:schedule.from_Date];
    
    tmp = [tmp stringByAppendingString:@"\nGiảng viên: "]; 
    tmp = [tmp stringByAppendingString:schedule.instructor_Name];
    
    
    cell.detailTextLabel.text = tmp;
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    Schedule*scheduleObj = [scheduleArray objectAtIndex:indexPath.row];
	NSString *title1 = scheduleObj.course_Name;
	NSString *subtitle = scheduleObj.class_Name;	
	int height = 40 + [self heightOfCellWithTitle:title1 andSubtitle:subtitle];
	return (height < CONST_Cell_height ? CONST_Cell_height : height);
} 

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}
*/
@end
