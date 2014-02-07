//
//  SettingViewController.m
//  MyDTUSchedule
//
//  Created by duc nguyen minh on 3/17/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//
//http://oleb.net/blog/2012/05/creating-and-deleting-calendars-in-ios/
#import "SettingViewController.h"
#import "ScheduleAppDelegate.h"
#import "MBProgressHUD.h"
#import <QuartzCore/QuartzCore.h>  
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h> 
#import "Schedule.h"
#import "MBProgressHUD.h"
//#import "Reachability.h"
@implementation SettingViewController
#define IS_IPAD() ([[UIDevice currentDevice] respondsToSelector:@selector(userInterfaceIdiom)] ? \
[[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad : NO)
@synthesize scheduleArray;
@synthesize managedObjectContext;
@synthesize fetchedResultsController;
@synthesize switch_alert;
@synthesize switch_calendar;
@synthesize textfield_alertType;
@synthesize button_info;
@synthesize progressHud;
@synthesize instructionViewController;
@synthesize background_image;

@synthesize eventsList, defaultCalendar; 
EKEventStore *eventStore;
UIPickerView *myPickerView;
NSString *array[3] = {@"Chuông",@"Rung",@"Im lặng"};

NSFileManager *filemgr;
NSMutableArray *event_idArray;

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
- (void) copyDatabaseIfNeeded:(NSString*) filename{
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSError *error;
	NSString *dbPath = [self getFilePath:filename];
	//[fileManager removeItemAtPath:dbPath error:&error];
	BOOL success = [fileManager fileExistsAtPath:dbPath];
	if(!success)
	{
		NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:filename];
		success = [fileManager copyItemAtPath:defaultDBPath toPath:dbPath error:&error];
		if(!success)
			NSAssert1(0,@"Failed to create writable database file with message '%@'.",[error localizedDescription]);
	}
}
- (NSString*) getFilePath:(NSString*) filename{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDir = [paths objectAtIndex:0];
	NSString *filePath = [documentsDir stringByAppendingPathComponent:filename];
	return filePath;
}
- (IBAction)clearAllEvents:(id)sender {
    
    eventStore = [[EKEventStore alloc] init];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    // Create the start date components
    NSDateComponents *oneDayAgoComponents = [[NSDateComponents alloc] init];
    oneDayAgoComponents.day = -1;
    NSDate *oneDayAgo = [calendar dateByAddingComponents:oneDayAgoComponents
                                                  toDate:[NSDate date]
                                                 options:0];
    
    // Create the end date components
    NSDateComponents *oneYearFromNowComponents = [[NSDateComponents alloc] init];
    oneYearFromNowComponents.year = 1;
    NSDate *oneYearFromNow = [calendar dateByAddingComponents:oneYearFromNowComponents
                                                       toDate:[NSDate date]
                                                      options:0];
    
    
    NSLog(@"%@ - %@", oneDayAgo, oneYearFromNow);
    
    // Create the predicate from the event store's instance method
    NSPredicate *predicate = [eventStore predicateForEventsWithStartDate:oneDayAgo
                                                                      endDate:oneYearFromNow
                                                                    calendars:nil];
    
    // Fetch all events that match the predicate
    NSArray *events = [eventStore eventsMatchingPredicate:predicate];
    NSMutableArray *arr = [[NSMutableArray alloc] initWithArray:events];
    //    for(int i= 0; i < [events count]; i++){
    //        EKEvent* event2 = [arr objectAtIndex:i];  //[store eventWithIdentifier:[events objectAtIndex:i]];
    //    if (event2 != nil) {
    //        NSError* error = nil;
    //        [self.eventStore removeEvent:event2 span:EKSpanThisEvent error:&error];
    //    }
    //    }
    
    for(EKEvent* event1 in arr){
        if (event1 != nil) {
            NSError* error = nil;
            [eventStore removeEvent:event1 span:EKSpanThisEvent error:&error];
        }
    }
}

- (void)clearEventCalendar : (NSDate *)fromDay : (NSDate*)toDay {
    
    NSPredicate *predicate = [eventStore predicateForEventsWithStartDate:fromDay
                                                                      endDate:toDay
                                                                    calendars:nil];
    
    NSArray *events = [eventStore eventsMatchingPredicate:predicate];
    NSMutableArray *arr = [[NSMutableArray alloc] initWithArray:events];
    
    for(EKEvent* event1 in arr){
        if (event1 != nil) {
            NSError* error = nil;
            [eventStore removeEvent:event1 span:EKSpanThisEvent error:&error];
        }
    }
    
}

#pragma mark Table view data source

// Fetching events happening in the next 24 hours with a predicate, limiting to the default calendar
- (NSArray *)fetchEventsForToday {
	
	NSDate *startDate = [NSDate date];
	
	// endDate is 1 day = 60*60*24 seconds = 86400 seconds from startDate
	NSDate *endDate = [NSDate dateWithTimeIntervalSinceNow:86400];
	
	// Create the predicate. Pass it the default calendar.
	NSArray *calendarArray = [NSArray arrayWithObject:defaultCalendar];
	NSPredicate *predicate = [eventStore predicateForEventsWithStartDate:startDate endDate:endDate
                                                                    calendars:calendarArray];
	
	// Fetch all events that match the predicate.
	NSArray *events = [eventStore eventsMatchingPredicate:predicate];
    
	return events;
}


#pragma mark -
- (void)viewWillAppear:(BOOL)animated{
    //[self.navigationController setNavigationBarHidden:NO];
    [super viewWillAppear:animated];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *state = [prefs stringForKey:@"keyRemindSwitch_myDTU"];
    if([state isEqualToString:@"true"]){
        // thiet lap trang thai la ON
        switch_alert.on = true;
    }
    else{
        // thiet lap trang thai la OFF cho switch
        switch_alert.on = false;
    }
    NSLog(@"viewdidload debug alert: %@",state);
    // for calendar on off switch
    state = [prefs stringForKey:@"keyCalendarSwitch_myDTU"];
    if([state isEqualToString:@"true"]){
        // thiet lap trang thai la ON
        switch_calendar.on = true;
    }
    else{
        // thiet lap trang thai la OFF cho switch
        switch_calendar.on = false;
    }
    NSLog(@"viewdidload debug calendar: %@",state);
    // trang thai cua kieu nhac nho (chuong, rung, im lang)
    if([prefs stringForKey:@"keyAlertType_myDTU"] == nil){
        textfield_alertType.text = @"15 Phút";
    }
    else {
        textfield_alertType.text = [[prefs stringForKey:@"keyAlertType_myDTU"] stringByAppendingString:@" Phút"];
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];    
    // copy file    
	[self copyDatabaseIfNeeded:@"saveeventid.txt"];
    // Do any additional setup after loading the view from its nib.
    textfield_alertType.delegate = self;
    self.title = @"Các thiết lập";
    
    myPickerView = [[UIPickerView alloc] init] ;
    myPickerView.frame = CGRectMake(0, 160, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height);
    myPickerView.delegate = self;
    myPickerView.showsSelectionIndicator = YES;
    [self.view addSubview:myPickerView];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        // The device is an iPad running iPhone 3.2 or later.
        CGAffineTransform s0 = CGAffineTransformMakeScale(0.3, 0.7);
        CGAffineTransform t1 = CGAffineTransformMakeTranslation(0,0);
        myPickerView.transform = CGAffineTransformConcat(s0, t1);
    }
    else
    {
        // The device is an iPhone or iPod touch.
        CGAffineTransform s0 = CGAffineTransformMakeScale(0.5, 0.7);
        CGAffineTransform t1 = CGAffineTransformMakeTranslation(0,0);
        myPickerView.transform = CGAffineTransformConcat(s0, t1);
    } 
    myPickerView.alpha = 0; 
    //myPickerView.hidden = TRUE;
    // thiet lap lai trang thai cua cac doi tuong da luu lai tu truoc
    // for remind on off switch
      
    
}
- (IBAction)pickerDoneClicked :(id)sender{
    [textfield_alertType resignFirstResponder];
}
int ii = 0;

- (IBAction)button_info_click :(id)sender{
    /*Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        NSLog(@"There IS NO internet connection");
    } else {
        
        NSLog(@"There IS internet connection");
        
        
    }*/
    instructionViewController = [[InstructionViewController alloc]initWithNibName:@"InstructionViewController" bundle:nil];
    [self.navigationController pushViewController:instructionViewController animated:YES];
    // khai bao một biến string để lưu toan bo noi dung file
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
     NSTimeZone *tz = [NSTimeZone timeZoneForSecondsFromGMT:(+7 * 3600)];
    [dFormat setTimeZone:tz];//
    NSDate *gmtDate = [dFormat dateFromString:resultTime];
    //    NSLog(@"%@",gmtDate);
    return gmtDate;
}

- (IBAction) switch_alertChanged :(id)sender{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    /*NSString *tmp = [prefs stringForKey:@"keyDayUpdateSchedule"];
    if(tmp == nil){ // neu chua cap nhat
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Nhắc nhở"
                                                            message:@"Bạn phải thực hiện cập nhật lịch từ MyDTU trước khi xem lịch" delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
        [switch_alert setOn:FALSE];
        return;
    }*/
    if(switch_alert.on){
        [prefs setObject:@"true" forKey:@"keyRemindSwitch_myDTU"];
        /*self.progressHud = [[MBProgressHUD alloc] initWithView:self.view];
        self.progressHud.labelText = @"Đang thiết lập nhắc nhở";
        self.progressHud.detailsLabelText = @"Xin vui lòng chờ trong giây lát";    
        [self.view addSubview:self.progressHud];
        [self.progressHud showWhileExecuting:@selector(setAlertSchedule:) onTarget:self withObject:self.managedObjectContext animated:YES];*/

        // bat che do tu dong nhac nho 
    }
    else{
        // luu trang thai cua switch
        [prefs setObject:@"false"  forKey:@"keyRemindSwitch_myDTU"];
        // tat che do tu dong nhac nho 
        /*[[UIApplication sharedApplication] cancelAllLocalNotifications];
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Thông báo" message:@"Đã tắt chế độ nhắc nhở" 
                                                           delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];*/
    }
    
    NSLog(@"debug %@",[prefs stringForKey:@"keyRemindSwitch_myDTU"]);
}

- (void) setAlertSchedule: (id)object
{
    @autoreleasepool {
        // cac viec can lam
        // 1. lay toan bo du lieu trong bang scchedule: da co trong mang scheduleArray
        // 2. Lay toan bo thoi gian bat dau cua mon hoc
        // 3. dat nhac nho lan luot cho tung mon hoc, chi dat nhac nho cho nhung mon chuan bi hoc, cac mon da hoc thi khôi
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        for(Schedule *sche in scheduleArray){ 
            NSDate *date_to_fire; 
            date_to_fire = [self stringToDate:sche.from_Date];
            
            
            // kiem tra xem mon hien tai da hoc hay chua bang cach so sanh thoi gian cua mon nay voi thoi gian hien tai
            NSComparisonResult result = [date_to_fire compare:[NSDate date]];
            if(result == NSOrderedDescending) {
                // de bao truoc gio lam viec 
                
                NSDate *date_alarm = [date_to_fire dateByAddingTimeInterval:-([[prefs stringForKey:@"keyAlertType_myDTU"] intValue] * 60)];
               // NSLog(@"%@",date_to_fire);
                //NSLog(@"day to alarm: %@",date_alarm);
                // ngay dang xet la ngay sau ngay hom nay 
                Class cls = NSClassFromString(@"UILocalNotification");
                if (cls != nil) {
                    UILocalNotification *notif = [[cls alloc] init];  
                    notif.fireDate = date_alarm;
                    
                    notif.timeZone = [NSTimeZone defaultTimeZone];
                    notif.alertBody = @"Bạn đã gần đến giờ làm việc?"; 
                    notif.alertAction = @"Xem sao";
                    notif.soundName = UILocalNotificationDefaultSoundName;
                    notif.applicationIconBadgeNumber = 1; 
                    //notif.repeatInterval = NSMinuteCalendarUnit;
                    
                    NSDictionary *userDict = [NSDictionary dictionaryWithObject:sche.course_Name forKey:kRemindMeNotificationDataKey];
                    notif.userInfo = userDict;
                    [[UIApplication sharedApplication] scheduleLocalNotification:notif]; 
                }
                //break;
            }
        }
    } 
 // hien thi message thong bao da thiet lap nhac nho thanh cong
//    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Thông báo" message:@"Đã hoàn tất thiết lập chế độ nhắc nhở"
//                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
//	//[alertView show];
//    [alertView performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
}

-(IBAction) switch_calendarChanged :(id)sender{
    EKEventStore *eventStore = [[EKEventStore alloc] init];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults]; 
    
    NSString *tmp = [prefs stringForKey:@"keyDayUpdateSchedule"];
    if(tmp == nil){ // neu chua cap nhat
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Nhắc nhở"
                                                            message:@"Bạn phải thực hiện cập nhật lịch từ MyDTU trước khi tích hợp vào Calendar" delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
        
        [switch_calendar setOn:FALSE];
        return;
    }
    
    if(switch_calendar.on){
        // kiem tra xem truoc do da tung tich hop lich vao calendar hay chua
        // deu da tung tich hop thi phai xoa tat ca cac lich tich hop truoc khi cap nhat lich moi
        if([eventStore respondsToSelector:@selector(requestAccessToEntityType:completion:)]){
        [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
            if (granted){ 
            } 
            else
            {
                //----- codes here when user NOT allow your app to access the calendar.
                // thong bao chua cho phep su dung calendar doi voi ung dung nay
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Remind"
                                                                    message:@"You should enable privacy app to use calendar" delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                [alertView show];
                return;
            }
            
        }];
        }
        [prefs setObject:@"true" forKey:@"keyCalendarSwitch_myDTU"];
        
        self.progressHud = [[MBProgressHUD alloc] initWithView:self.view];
        self.progressHud.labelText = @"Đang tích hợp lịch vào ứng dụng Calendar";
        self.progressHud.detailsLabelText = @"Xin vui lòng chờ trong giây lát";
        [self.view addSubview:self.progressHud];
        [self.progressHud showWhileExecuting:@selector(integratetocalendar:) onTarget:self withObject:self.managedObjectContext animated:YES];
    }
    else{
        [prefs setObject:@"false" forKey:@"keyCalendarSwitch_myDTU"];
        self.progressHud = [[MBProgressHUD alloc] initWithView:self.view];
        self.progressHud.labelText = @"Đang xoá lịch đã tích hợp trong calendar";
        self.progressHud.detailsLabelText = @"Xin vui lòng chờ trong giây lát";
        [self.view addSubview:self.progressHud];
        [self.progressHud showWhileExecuting:@selector(clear_all_schedule_in_calendar:) onTarget:self withObject:self.managedObjectContext animated:YES];
    }
    NSLog(@"aaaaaaaaaaa %@",[prefs stringForKey:@"keyCalendarSwitch_myDTU"]);
}

- (void) clear_all_schedule_in_calendar: (id)object
{
    @autoreleasepool {
        // xoa lich da add truoc vao truoc khi them moi
        [self delete_schedule_in_calender];
    }
//    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Thông báo" message:@"Đã xóa lịch học đã tích hợp vào ứng dụng Calendar"
//                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
//    [alertView show];
}
- (void) delete_schedule_in_calender {
    // thuc hien xoa toan bo lich MyDTU
    EKEventStore *eventStore = [[EKEventStore alloc] init];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];  
        
    EKCalendar *cal = [eventStore calendarWithIdentifier:[defaults objectForKey:@"Calendar"]];
    if (cal) {
        NSError *error = nil;
        BOOL result = [eventStore removeCalendar:cal commit:YES error:&error];
        if (result) {
            NSLog(@"Deleted calendar from event store.");
        } else {
            NSLog(@"Deleting calendar failed: %@.", error);
        }
    }
    
    /* khai bao một biến string để lưu toan bo noi dung file
    NSString *tam =  @"";
    filemgr = [NSFileManager defaultManager];
    //lay duong dan file
    NSString *filePath = [self getFilePath:@"saveeventid.txt"];
    NSFileHandle *inFile;
    //mo file de doc
    inFile = [NSFileHandle fileHandleForReadingAtPath:filePath];
    NSData *dataFile;
    dataFile = [inFile readDataToEndOfFile]; //doc den cuoi file
    //chuyen NSData sang NSString
    NSString *tmp =  @"";
    tmp = [NSString stringWithCharacters:[dataFile bytes] length:[dataFile length]/sizeof(unichar)];
    if(![tmp isEqualToString:@""]){
        //loai bo 2byte dau tien
        tmp = [tmp substringFromIndex:1];
        // lay cac ki tu cho toi khi gap enter
        event_idArray = [[NSMutableArray alloc] init];
        int j = 0;
        while (![tmp isEqualToString:@""]){
            //for(int  i = 0; i < [scheduleArray count]; i++){
            int index_find_string = [tmp rangeOfString:@"\n"].location;
            tam = [tmp substringWithRange:NSMakeRange(0, index_find_string)]; // tam chinh la event id
            // luu event id vao mang
            [event_idArray addObject:tam];
            //NSLog(@"index: %d Event id: %@", j, tam);
            tmp = [tmp substringFromIndex:index_find_string + 1];	// cat luon ra khoi tmp
            //j++;
        }
        
        // thuc hien xoa tat ca cac event da add vao
        EKEventStore* store = [[EKEventStore alloc] init];
        j = 0;
        for(NSString *eventid in event_idArray){
           
            EKEvent* event2 = [store eventWithIdentifier:eventid];
            if (event2 != nil) {
                 NSLog(@"log: %d log id: %@", j, eventid);
                NSError* error = nil;
                [store removeEvent:event2 span:EKSpanThisEvent error:&error];
            }
            j++;
        }
        // ghi lai file moi
        //xoa file cu 
        [filemgr removeItemAtPath:filePath error:nil]; 
    }*/
}
- (void) integratetocalendar: (id)object
{
    @autoreleasepool {
        EKEventStore *eventStore = [[EKEventStore alloc] init]; 
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        EKCalendar* cal;
         
        // xoa lich da ton tai truoc khi them lich moi vao calendar
        cal = [eventStore calendarWithIdentifier:[defaults objectForKey:@"Calendar"]];
        if (cal) {
            NSError *error = nil;
            BOOL result = [eventStore removeCalendar:cal commit:YES error:&error];
            [defaults setObject:@"" forKey:@"Calendar"];
            if (result) {
                NSLog(@"Deleted calendar from event store.");
            } else {
                NSLog(@"Deleting calendar failed: %@.", error);
            }
        }
        // 
        if ([defaults objectForKey:@"Calendar"] == nil || ![eventStore calendarWithIdentifier:[defaults objectForKey:@"Calendar"]]) // Create Calendar if Needed
        {
            NSString* calendarName = @"MyDTU Calendar";
            EKSource *defaultSource = [eventStore defaultCalendarForNewEvents].source;
            
            NSLog(@"source title: %@",defaultSource.title);
            NSLog(@"source type: %u",defaultSource.sourceType);
            NSLog(@"source identifier: %@",defaultSource.sourceIdentifier); 
            if (defaultSource.sourceType == EKSourceTypeLocal)
                NSLog(@"iCloud Enable");
            else
                NSLog(@"iCloud Disable");
            cal = [EKCalendar calendarWithEventStore:eventStore];
            cal.source = defaultSource;
            cal.title = calendarName;
            
            NSError* error;
            bool success= [eventStore saveCalendar:cal commit:YES error:&error];
            if (error != nil)
            {
                NSLog(@"%@",error.description);
                // TODO: error handling here
            }
            NSLog(@"cal id = %@", cal.calendarIdentifier);
            NSString *calendar_id = cal.calendarIdentifier;
            [defaults setObject:calendar_id forKey:@"Calendar"];
            
            //NSArray *calendars = [eventStore calendarsForEntityType:EKEntityTypeEvent];
            
            //for (EKCalendar* cal in calendars){
            //    NSLog(@"%@: %@",cal.title,cal.calendarIdentifier);
            //}
        }
        else {
            cal = [eventStore calendarWithIdentifier:[defaults objectForKey:@"Calendar"]];
            if (!cal) {
                NSLog(@"This calendar is deleted by user");
                
            }
            else NSLog(@"Calendar Existed");
        }
        int i = 0;
        for(Schedule *sche in scheduleArray){
            
            EKEvent *addEvent=[EKEvent eventWithEventStore:eventStore];
            addEvent.title=sche.course_Name;
            addEvent.startDate = [self stringToDate:sche.from_Date];
            addEvent.endDate = [self stringToDate:sche.thru_Date];
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            NSString *tmp1 = @"Lịch của: ";
            tmp1 = [tmp1 stringByAppendingString:[prefs stringForKey:@"keyUserName"]];
            tmp1 = [tmp1 stringByAppendingString:[NSString stringWithFormat: @" %d",i]];
            addEvent.notes = tmp1;
            NSDate *date_alarm = [addEvent.startDate dateByAddingTimeInterval:-(10*60)]; // dat nhac nho truoc 10 phut
            addEvent.alarms=[NSArray arrayWithObject:[EKAlarm alarmWithAbsoluteDate:date_alarm]];
            addEvent.calendar = cal;
            //[addEvent setCalendar:[eventStore defaultCalendarForNewEvents]];
            
            NSError *err;
            [eventStore saveEvent:addEvent span:EKSpanThisEvent error:&err];
            if (err == nil) {
                NSString* str = [[NSString alloc] initWithFormat:@"%@", addEvent.eventIdentifier];
                NSLog(@"String %d: %@ ngay:%@ ",i, str,addEvent.startDate);
            }
            else {
                NSLog(@"Error %@",err);
            }
            i++;
        }
    }
}
-(IBAction) textfield_alertType_click :(id)sender{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4];
    //CGAffineTransform transfrom = CGAffineTransformMakeTranslation(0, 200);
   // myPickerView.transform = transfrom;
    myPickerView.alpha = 1;
    //myPickerView.hidden = FALSE;
    [UIView commitAnimations];
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
} 
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    return NO;
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow: (NSInteger)row inComponent:(NSInteger)component {
    int irow = row * 5 + 5;
    NSString *str;
    str = [NSString stringWithFormat:@"%d",irow];
    
    
    [textfield_alertType setText:[str stringByAppendingString:@" Phút"]];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults]; 
    [prefs setObject:str forKey:@"keyAlertType_myDTU"];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4];
    //CGAffineTransform transfrom = CGAffineTransformMakeTranslation(0, 200);
    // myPickerView.transform = transfrom;
    myPickerView.alpha = 0;
    [UIView commitAnimations];
    // Handle the selection
}

// tell the picker how many rows are available for a given component
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    NSUInteger numRows = 12;
    
    return numRows;
}

// tell the picker how many components it will have
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}
 
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component
           reusingView:(UIView *)view {
    
    UILabel *pickerLabel = (UILabel *)view;
    CGRect frame;
    int font_number;
    if (pickerLabel == nil) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            // The device is an iPad running iPhone 3.2 or later.
            frame = CGRectMake(0.0, 0.0, 350, 182);
            font_number = 35;
        }
        else
        {
            // The device is an iPhone or iPod touch.
            frame = CGRectMake(0.0, 0.0, 150, 32);
            font_number = 22;
        }
        
        
        pickerLabel = [[UILabel alloc] initWithFrame:frame];
        [pickerLabel setTextAlignment:UITextAlignmentCenter];
        [pickerLabel setBackgroundColor:[UIColor clearColor]];
        [pickerLabel setTextColor:[UIColor blueColor]];
        [pickerLabel setFont:[UIFont boldSystemFontOfSize:font_number]];
    }
    int irow = row * 5 + 5;
    NSString *str;
    str = [NSString stringWithFormat:@"%d",irow]; 
    [pickerLabel setText:[str stringByAppendingString:@" Phút"]];
//    if(row == 0) [pickerLabel setText:@"Chuông"]; 
//    if(row == 1) [pickerLabel setText:@"Rung"]; 
//    if(row == 2) [pickerLabel setText:@"Im lặng"]; 
    
    return pickerLabel;
    
} 

// tell the picker the width of each row for a given component
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    int sectionWidth = [[UIScreen mainScreen] bounds].size.width - 20;
    return sectionWidth; 
}

/*- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    
    if ((interfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (interfaceOrientation == UIInterfaceOrientationLandscapeRight))
    {
        
        //scrollView.contentSize = CGSizeMake([[UIScreen mainScreen] bounds].size.height,[[UIScreen mainScreen] bounds].size.height);
        //isPortrait = FALSE;
        background_image.frame = CGRectMake(0,0,[[UIScreen mainScreen] bounds].size.height,[[UIScreen mainScreen] bounds].size.width);
        // kiem tra xem ung dung dang chay tren thiet bi nao: ipad hay iPhone
        if(IS_IPAD()){ // neu thiet bi dang su dung la ipad
            [background_image setImage:[UIImage imageNamed: @"bluebackgroundipad_lan.png"]];
            
        }
        // bat dau hieu chinh vi tri cac doi tuong trong ung dung
        else{
            [background_image setImage:[UIImage imageNamed: @"bluebackgroundiphone_lan.png"]];
        }
        
    }
    else {
        //.contentSize = CGSizeMake([[UIScreen mainScreen] bounds].size.width,[[UIScreen mainScreen] bounds].size.height - 20);
        
        //isPortrait = TRUE;
        // kiem tra xem ung dung dang chay tren thiet bi nao: ipad hay iPhone
        background_image.frame = CGRectMake(0,0,[[UIScreen mainScreen] bounds].size.width,[[UIScreen mainScreen] bounds].size.height);
        if(IS_IPAD()){ // neu thiet bi dang su dung la ipad
            [background_image setImage:[UIImage imageNamed: @"bluebackgroundipad.png"]];
        }
        // bat dau hieu chinh vi tri cac doi tuong trong ung dung
        else{
            [background_image setImage:[UIImage imageNamed: @"bluebackgroundiphone.png"]];
        }
        
    }
    return YES;
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationLandscapeRight | UIInterfaceOrientationLandscapeLeft | UIInterfaceOrientationPortrait | UIInterfaceOrientationPortraitUpsideDown;
}*/
- (NSUInteger)supportedInterfaceOrientations{
    //    if (self.presentedViewController != nil){
    //        return [self.presentedViewController supportedInterfaceOrientations];
    //        //return [[self presentedViewController] supportedInterfaceOrientations];
    //    }
    //    else {
    //        if (IS_IPAD()){
    //            return UIInterfaceOrientationMaskLandscapeRight;
    //        }
    //        else {
    //            return UIInterfaceOrientationMaskAll;
    //        }
    //    }
    //    return YES;
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight | UIInterfaceOrientationMaskPortraitUpsideDown;
}
 - (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
 {
     if(IS_IPAD()) return YES;
     else return NO;
 }
// Determine iOS 6 Autorotation.
- (BOOL)shouldAutorotate{
//    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
//    //    // Return yes to allow the device to load initially.
//    if (orientation == UIDeviceOrientationUnknown) return YES;
//    //    // Pass iOS 6 Request for orientation on to iOS 5 code. (backwards compatible)
//    BOOL result = [self shouldAutorotateToInterfaceOrientation:orientation];
//    return result;
    return NO;
}
@end
