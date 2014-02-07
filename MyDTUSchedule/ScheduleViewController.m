//
//  ScheduleViewController.m
//  ScheduleManager
//
//  Created by duc nguyen minh on 1/14/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//
//http://stackoverflow.com/questions/12260261/shouldautorotatetointerfaceorientation-not-being-called-in-ios-6
#import "ScheduleViewController.h"

#import "ScheduleAppDelegate.h"
#import "MBProgressHUD.h"
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>
@implementation ScheduleViewController 
#define IS_IPAD() ([[UIDevice currentDevice] respondsToSelector:@selector(userInterfaceIdiom)] ? \
[[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad : NO)
@synthesize managedObjectContext;
@synthesize fetchedResultsController;
@synthesize dayScheduleController;
@synthesize newdayViewController;
@synthesize weekScheduleController; 
@synthesize progressHud;
@synthesize aboutViewController;
@synthesize settingViewController;
@synthesize update_label;
@synthesize background_image;
@synthesize update_button;
@synthesize dayschdule_button;
@synthesize monthschedule_button;
@synthesize setting_button;
@synthesize logo_image;
NSFileManager *filemgr;

NSMutableArray *event_idArray;
NSString  *URLBasePath4 = @"http://dev.duytan.edu.vn:8085/connectservice.asmx";//@"http://10.8.0.115:8080/connectservice.asmx";

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

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle
- (void)viewWillAppear:(BOOL)animated{
    //[self.navigationController setNavigationBarHidden:NO];
    [super viewWillAppear:animated];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    NSString *tmp = [prefs stringForKey:@"keyLoginAgain"];
    if([tmp isEqualToString:@"true"]){ // neu dang nhap lai
        if([prefs stringForKey:@"keyDayUpdateSchedule"] != nil) // neu da tung thuc hien cap nhat lich
            update_label.text = [prefs stringForKey:@"keyDayUpdateSchedule"];
        //
    }
    else{ // NEU DANG NHAP MOI.
        [prefs setObject:nil forKey:@"keyDayUpdateSchedule"]; // key nay dung de kiem tra xem lich da duoc cap nhat chua 
        update_label.text = @"Bạn chưa cập nhật lịch MyDTU từ hệ thống";
        [prefs setObject:@"true" forKey:@"keyLoginAgain"];
    }
    /*if(IS_IPAD()){
        if(isPortrait){
            [background_image setImage:[UIImage imageNamed: @"bluebackgroundipad.png"]];
            [update_button setImage:[UIImage imageNamed: @"updatebuttonipad.png"] forState:UIControlStateNormal];
            [dayschdule_button setImage:[UIImage imageNamed: @"dayschedulebuttonipad.png"] forState:UIControlStateNormal];
            [monthschedule_button setImage:[UIImage imageNamed: @"weekschedulebuttonipad.png"] forState:UIControlStateNormal];
            [setting_button setImage:[UIImage imageNamed: @"settingbuttonipad.png"] forState:UIControlStateNormal];
            update_button.frame = CGRectMake([[UIScreen mainScreen] bounds].size.width/2 - update_button.frame.size.width/2, 22, 390, 48);
            dayschdule_button.frame = CGRectMake([[UIScreen mainScreen] bounds].size.width/2 - dayschdule_button.frame.size.width/2, 114, 390, 48);
            monthschedule_button.frame = CGRectMake([[UIScreen mainScreen] bounds].size.width/2 - monthschedule_button.frame.size.width/2, 196, 390, 48);
            setting_button.frame = CGRectMake([[UIScreen mainScreen] bounds].size.width/2 - setting_button.frame.size.width/2, 522, 390, 48);
            
            update_button.frame = CGRectMake([[UIScreen mainScreen] bounds].size.width/2 - update_button.frame.size.width/2, 22, 390, 48);
            dayschdule_button.frame = CGRectMake([[UIScreen mainScreen] bounds].size.width/2 - dayschdule_button.frame.size.width/2, 114, 390, 48);
            monthschedule_button.frame = CGRectMake([[UIScreen mainScreen] bounds].size.width/2 - monthschedule_button.frame.size.width/2, 196, 390, 48);
            setting_button.frame = CGRectMake([[UIScreen mainScreen] bounds].size.width/2 - setting_button.frame.size.width/2,[[UIScreen mainScreen] bounds].size.height - 140, 390, 48);
            
            update_label.frame = CGRectMake(update_label.frame.origin.x, 80, update_label.frame.size.width, update_label.frame.size.height);
            
            logo_image.frame = CGRectMake(logo_image.frame.origin.x, 400, 200, 200);
            logo_image.frame = CGRectMake([[UIScreen mainScreen] bounds].size.width/2 - logo_image.frame.size.width/2, 400, 200, 200);
        }
        else{
            [background_image setImage:[UIImage imageNamed: @"bluebackgroundipad_lan.png"]];
            [update_button setImage:[UIImage imageNamed: @"updatebuttonipad.png"] forState:UIControlStateNormal];
            [dayschdule_button setImage:[UIImage imageNamed: @"dayschedulebuttonipad.png"] forState:UIControlStateNormal];
            [monthschedule_button setImage:[UIImage imageNamed: @"weekschedulebuttonipad.png"] forState:UIControlStateNormal];
            [setting_button setImage:[UIImage imageNamed: @"settingbuttonipad.png"] forState:UIControlStateNormal];
            update_button.frame = CGRectMake([[UIScreen mainScreen] bounds].size.height/2 - update_button.frame.size.width/2, 22, 390, 48);
            dayschdule_button.frame = CGRectMake([[UIScreen mainScreen] bounds].size.height/2 - dayschdule_button.frame.size.width/2, 114, 390, 48);
            monthschedule_button.frame = CGRectMake([[UIScreen mainScreen] bounds].size.height/2 - monthschedule_button.frame.size.width/2, 196, 390, 48);
            setting_button.frame = CGRectMake([[UIScreen mainScreen] bounds].size.height/2 - setting_button.frame.size.width/2, 522, 390, 48);
            
            update_button.frame = CGRectMake([[UIScreen mainScreen] bounds].size.height/2 - update_button.frame.size.width/2, 22, 390, 48);
            dayschdule_button.frame = CGRectMake([[UIScreen mainScreen] bounds].size.height/2 - dayschdule_button.frame.size.width/2, 114, 390, 48);
            monthschedule_button.frame = CGRectMake([[UIScreen mainScreen] bounds].size.height/2 - monthschedule_button.frame.size.width/2, 196, 390, 48);
            setting_button.frame = CGRectMake([[UIScreen mainScreen] bounds].size.height/2 - setting_button.frame.size.width/2,[[UIScreen mainScreen] bounds].size.width - 140, 390, 48);
            
            update_label.frame = CGRectMake(update_label.frame.origin.x, 80, update_label.frame.size.width, update_label.frame.size.height);
            
            logo_image.frame = CGRectMake(logo_image.frame.origin.x, 400, 200, 200);
            logo_image.frame = CGRectMake([[UIScreen mainScreen] bounds].size.height/2 - logo_image.frame.size.width/2, 400, 200, 200);
        }
    }*/
    /*if(!isPortrait){
        //isPortrait = FALSE;
        background_image.frame = CGRectMake(0,0,[[UIScreen mainScreen] bounds].size.height,[[UIScreen mainScreen] bounds].size.width);
        // kiem tra xem ung dung dang chay tren thiet bi nao: ipad hay iPhone
        if(IS_IPAD()){ // neu thiet bi dang su dung la ipad
            [background_image setImage:[UIImage imageNamed: @"bluebackgroundipad_lan.png"]];
            [update_button setImage:[UIImage imageNamed: @"updatebuttonipad.png"] forState:UIControlStateNormal];
            [dayschdule_button setImage:[UIImage imageNamed: @"updatebuttonipad.png"] forState:UIControlStateNormal];
            [monthschedule_button setImage:[UIImage imageNamed: @"updatebuttonipad.png"] forState:UIControlStateNormal];
            [setting_button setImage:[UIImage imageNamed: @"updatebuttonipad.png"] forState:UIControlStateNormal];
            update_button.frame = CGRectMake([[UIScreen mainScreen] bounds].size.height/2 - update_button.frame.size.width/2, 22, 390, 48);
            dayschdule_button.frame = CGRectMake([[UIScreen mainScreen] bounds].size.height/2 - dayschdule_button.frame.size.width/2, 114, 390, 48);
            monthschedule_button.frame = CGRectMake([[UIScreen mainScreen] bounds].size.height/2 - monthschedule_button.frame.size.width/2, 196, 390, 48);
            setting_button.frame = CGRectMake([[UIScreen mainScreen] bounds].size.height/2 - setting_button.frame.size.width/2, 522, 390, 48);
            
            update_button.frame = CGRectMake([[UIScreen mainScreen] bounds].size.height/2 - update_button.frame.size.width/2, 22, 390, 48);
            dayschdule_button.frame = CGRectMake([[UIScreen mainScreen] bounds].size.height/2 - dayschdule_button.frame.size.width/2, 114, 390, 48);
            monthschedule_button.frame = CGRectMake([[UIScreen mainScreen] bounds].size.height/2 - monthschedule_button.frame.size.width/2, 196, 390, 48);
            setting_button.frame = CGRectMake([[UIScreen mainScreen] bounds].size.height/2 - setting_button.frame.size.width/2,[[UIScreen mainScreen] bounds].size.width - 140, 390, 48);
        }
        // bat dau hieu chinh vi tri cac doi tuong trong ung dung
        else{
            [background_image setImage:[UIImage imageNamed: @"bluebackgroundiphone_lan.png"]];
            [update_button setImage:[UIImage imageNamed: @"updatebuttoniphone.png"] forState:UIControlStateNormal];
            [dayschdule_button setImage:[UIImage imageNamed: @"updatebuttoniphone.png"] forState:UIControlStateNormal];
            [monthschedule_button setImage:[UIImage imageNamed: @"updatebuttoniphone.png"] forState:UIControlStateNormal];
            [setting_button setImage:[UIImage imageNamed: @"updatebuttoniphone.png"] forState:UIControlStateNormal];
            update_button.frame = CGRectMake([[UIScreen mainScreen] bounds].size.height/2 - update_button.frame.size.width/2, 22, 264, 37);
            dayschdule_button.frame = CGRectMake([[UIScreen mainScreen] bounds].size.height/2 - dayschdule_button.frame.size.width/2, 114, 264, 37);
            monthschedule_button.frame = CGRectMake([[UIScreen mainScreen] bounds].size.height/2 - monthschedule_button.frame.size.width/2, 176, 264, 37);
            setting_button.frame = CGRectMake([[UIScreen mainScreen] bounds].size.height/2 - setting_button.frame.size.width/2, 522, 264, 37);
            
            update_button.frame = CGRectMake([[UIScreen mainScreen] bounds].size.height/2 - update_button.frame.size.width/2, 22, 264, 37);
            dayschdule_button.frame = CGRectMake([[UIScreen mainScreen] bounds].size.height/2 - dayschdule_button.frame.size.width/2, 114 - 15, 264, 37);
            monthschedule_button.frame = CGRectMake([[UIScreen mainScreen] bounds].size.height/2 - monthschedule_button.frame.size.width/2, 176 - 25, 264, 37);
            setting_button.frame = CGRectMake([[UIScreen mainScreen] bounds].size.height/2 - setting_button.frame.size.width/2,[[UIScreen mainScreen] bounds].size.width - 100, 264, 37);
            
        }
    }
    else{
        //isPortrait = TRUE;
        // kiem tra xem ung dung dang chay tren thiet bi nao: ipad hay iPhone
        background_image.frame = CGRectMake(0,0,[[UIScreen mainScreen] bounds].size.width,[[UIScreen mainScreen] bounds].size.height);
        if(IS_IPAD()){ // neu thiet bi dang su dung la ipad
            [background_image setImage:[UIImage imageNamed: @"bluebackgroundipad.png"]];
            [update_button setImage:[UIImage imageNamed: @"updatebuttonipad.png"] forState:UIControlStateNormal];
            [dayschdule_button setImage:[UIImage imageNamed: @"updatebuttonipad.png"] forState:UIControlStateNormal];
            [monthschedule_button setImage:[UIImage imageNamed: @"updatebuttonipad.png"] forState:UIControlStateNormal];
            [setting_button setImage:[UIImage imageNamed: @"updatebuttonipad.png"] forState:UIControlStateNormal];
            update_button.frame = CGRectMake([[UIScreen mainScreen] bounds].size.width/2 - update_button.frame.size.width/2, 22, 390, 48);
            dayschdule_button.frame = CGRectMake([[UIScreen mainScreen] bounds].size.width/2 - dayschdule_button.frame.size.width/2, 114, 390, 48);
            monthschedule_button.frame = CGRectMake([[UIScreen mainScreen] bounds].size.width/2 - monthschedule_button.frame.size.width/2, 196, 390, 48);
            setting_button.frame = CGRectMake([[UIScreen mainScreen] bounds].size.width/2 - setting_button.frame.size.width/2, 522, 390, 48);
            
            update_button.frame = CGRectMake([[UIScreen mainScreen] bounds].size.width/2 - update_button.frame.size.width/2, 22, 390, 48);
            dayschdule_button.frame = CGRectMake([[UIScreen mainScreen] bounds].size.width/2 - dayschdule_button.frame.size.width/2, 114, 390, 48);
            monthschedule_button.frame = CGRectMake([[UIScreen mainScreen] bounds].size.width/2 - monthschedule_button.frame.size.width/2, 196, 390, 48);
            setting_button.frame = CGRectMake([[UIScreen mainScreen] bounds].size.width/2 - setting_button.frame.size.width/2,[[UIScreen mainScreen] bounds].size.height - 140, 390, 48);
        }
        // bat dau hieu chinh vi tri cac doi tuong trong ung dung
        else{
            [background_image setImage:[UIImage imageNamed: @"bluebackgroundiphone.png"]];
            [update_button setImage:[UIImage imageNamed: @"updatebuttoniphone.png"] forState:UIControlStateNormal];
            [dayschdule_button setImage:[UIImage imageNamed: @"updatebuttoniphone.png"] forState:UIControlStateNormal];
            [monthschedule_button setImage:[UIImage imageNamed: @"updatebuttoniphone.png"] forState:UIControlStateNormal];
            [setting_button setImage:[UIImage imageNamed: @"updatebuttoniphone.png"] forState:UIControlStateNormal];
            update_button.frame = CGRectMake([[UIScreen mainScreen] bounds].size.height/2 - update_button.frame.size.width/2, 22, 264, 37);
            dayschdule_button.frame = CGRectMake([[UIScreen mainScreen] bounds].size.height/2 - dayschdule_button.frame.size.width/2, 114, 264, 37);
            monthschedule_button.frame = CGRectMake([[UIScreen mainScreen] bounds].size.height/2 - monthschedule_button.frame.size.width/2, 176, 264, 37);
            setting_button.frame = CGRectMake([[UIScreen mainScreen] bounds].size.height/2 - setting_button.frame.size.width/2, 522, 264, 37);
            
            update_button.frame = CGRectMake([[UIScreen mainScreen] bounds].size.width/2 - update_button.frame.size.width/2, 22, 264, 37);
            dayschdule_button.frame = CGRectMake([[UIScreen mainScreen] bounds].size.width/2 - dayschdule_button.frame.size.width/2, 114, 264, 37);
            monthschedule_button.frame = CGRectMake([[UIScreen mainScreen] bounds].size.width/2 - monthschedule_button.frame.size.width/2, 176, 264, 37);
            setting_button.frame = CGRectMake([[UIScreen mainScreen] bounds].size.width/2 - setting_button.frame.size.width/2,[[UIScreen mainScreen] bounds].size.height - 44 - 37 - 20 - 20, 264, 37);
        }
    }*/
    if([UIScreen mainScreen].bounds.size.height < 500){
        logo_image.frame = CGRectMake(88 + 7.5, 233 - 15, 130, 130);
    } 
    NSLog(@"witdh: %f",[[UIScreen mainScreen] bounds].size.width);
    NSLog(@"height: %f",[[UIScreen mainScreen] bounds].size.height);
    
    [self.weekScheduleController shouldAutorotate];
}
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
- (void)viewDidLoad{
    [super viewDidLoad];
    //[self.navigationController setNavigationBarHidden:NO];
    [self.navigationController.navigationBar setTintColor:[UIColor colorWithRed:16.0/255.0 green:78.0/255.0 blue:139.0/255.0 alpha:0]];//[UIColor  colorWithRed:148/255.0 green:4.0/255.0 blue:4.0/255.0 alpha:0]];
    self.title = @"Lịch MyDTU";
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithTitle:@"Thông tin"  style:UIBarButtonItemStyleBordered 
                                                                 target:self action:@selector(AboutMe:)];
	self.navigationItem.leftBarButtonItem = addButton;
	// Do any additional setup after loading the view, typically from a nib.
    UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithTitle:@"Đăng xuất" style:UIBarButtonItemStylePlain target:self action:@selector(logout:)];          
    self.navigationItem.rightBarButtonItem = anotherButton;
}
- (IBAction) AboutMe: (id) sender{
    aboutViewController = [[AboutViewController alloc]initWithNibName:@"AboutViewController" bundle:nil];
	[self.navigationController pushViewController:aboutViewController animated:YES];
}
- (IBAction) update_click: (id) sender{
    // thao tac dau tien la lay du lieu tu web service ve
    if (self.connectedToNetwork) { // da co mang, kiem tra username va password co dung khong
        NSLog(@"There is internet connection");
        self.progressHud = [[MBProgressHUD alloc] initWithView:self.view];
        self.progressHud.labelText = @"Cập nhật dữ liệu";
        self.progressHud.detailsLabelText = @"Xin vui lòng chờ trong giây lát";    
        [self.view addSubview:self.progressHud];
        [self.progressHud showWhileExecuting:@selector(getDataforSchedule:) onTarget:self withObject:self.managedObjectContext animated:YES];
    }
    else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Nhắc nhở"
                                                            message:@"Bạn cần kết nối mạng để thực hiện việc cập nhật" delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
        return;
    }
}
- (IBAction) logout: (id) sender{    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Nhắc nhở" message:@"Bạn thực sự muốn đăng xuất" delegate:self cancelButtonTitle:@"Không" otherButtonTitles:@"Đồng ý", nil];
    [alert show];
}
- (IBAction) Setting_click: (id) sender{  
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"from_Date"
                                                                                     ascending:YES
                                                                                      selector:@selector(localizedCaseInsensitiveCompare:)]];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Schedule" inManagedObjectContext:self.managedObjectContext];
    [request setEntity:entity];
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    NSError *error;
    NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    if(IS_IPAD()) settingViewController = [[SettingViewController alloc]initWithNibName:@"SettingViewControlleripad" bundle:nil];
    else settingViewController = [[SettingViewController alloc]initWithNibName:@"SettingViewController" bundle:nil];
    settingViewController.managedObjectContext = self.managedObjectContext;     
    settingViewController.scheduleArray = [[NSMutableArray alloc]initWithArray:results]; 
    
    [self.navigationController pushViewController:settingViewController animated:YES];  
} 
- (IBAction) day_click: (id) sender{
    // dau tien phai kiem tra xem da cap nhat lich chua, neu chua hien thi thong bao yeu cau cap nhat
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    NSString *tmp = [prefs stringForKey:@"keyDayUpdateSchedule"];
    if(tmp == nil){ // neu chua cap nhat
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Nhắc nhở"
                                                            message:@"Bạn phải thực hiện cập nhật lịch từ MyDTU trước khi xem lịch" delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    NSError *error = nil;
    //==========    He dao tao  ===============
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit ) fromDate:[NSDate date]];
    //create a date with these components
    
    NSDate *sourceDate = [NSDate date];
    NSLog(@"%@",sourceDate); //lay ngay va gio theo GMT 00
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    NSTimeZone* destinationTimeZone = [NSTimeZone systemTimeZone];
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:sourceDate];
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:sourceDate];
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    NSDate* destinationDate = [[NSDate alloc] initWithTimeInterval:interval sinceDate:sourceDate];
    NSLog(@"%@",destinationDate);
    
    
    NSDate *startDate = destinationDate;
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
    NSArray *results = [fetchedResultsController fetchedObjects]; // neu khong co loi, lay ket qua tra ve la truong DH Duy tan
    
    newdayViewController = [[NewDayViewController alloc]initWithNibName:@"NewDayViewController" bundle:nil];
    newdayViewController.managedObjectContext = self.managedObjectContext;
    newdayViewController.scheduleArray = [[NSMutableArray alloc]initWithArray:results];
    [self.navigationController pushViewController:newdayViewController animated:YES];    
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
- (void) getDataforSchedule: (id)object{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    @autoreleasepool {
        NSManagedObjectContext *context = [self managedObjectContext];    
        NSError *parseError = nil;     
        NSURL *xmlURL1 = [NSURL URLWithString: [NSString stringWithFormat: @"%@/getLich?username=%@&password=string&type=4", URLBasePath4,[prefs stringForKey:@"keyUserName"]]];
        // Parse the xml and store the results in our object model
        scheduleParser *xmlParse1 = [[scheduleParser alloc] initWithContext:context];
        [xmlParse1 parseXMLFileAtURL:xmlURL1 parseError:&parseError];
    }
    
    NSDate *sourceDate = [NSDate date];
    NSLog(@"%@",sourceDate); //lay ngay va gio theo GMT 00
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    NSTimeZone* destinationTimeZone = [NSTimeZone systemTimeZone];
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:sourceDate];
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:sourceDate];
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    NSDate* destinationDate = [[NSDate alloc] initWithTimeInterval:interval sinceDate:sourceDate];
    NSLog(@"%@",destinationDate);
    
    NSString *string = @"Ngày cập nhật gần nhất: ";
    string = [string stringByAppendingString:[self date_to_string:destinationDate]];
    
    [prefs setObject:string forKey:@"keyDayUpdateSchedule"];
    update_label.text =  string;
}
- (IBAction) week_click: (id) sender{
    // dau tien phai kiem tra xem da cap nhat lich chua, neu chua hien thi thong bao yeu cau cap nhat
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    NSString *tmp = [prefs stringForKey:@"keyDayUpdateSchedule"];
    if(tmp == nil){ // neu chua cap nhat
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Nhắc nhở"
                                                            message:@"Bạn phải thực hiện cập nhật lịch từ MyDTU trước khi xem lịch" delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
        return;
    }
    NSError *error = nil;
    //==========    He dao tao  ===============  
    
    NSDate *sourceDate = [NSDate date]; 
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    NSTimeZone* destinationTimeZone = [NSTimeZone systemTimeZone];
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:sourceDate];
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:sourceDate];
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    NSDate* current_day = [[NSDate alloc] initWithTimeInterval:interval sinceDate:sourceDate];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *startDate;
    NSDate *endDate;
    NSDateComponents * comp = [calendar components:NSWeekdayCalendarUnit fromDate:current_day];
    
    NSDateComponents *components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit ) fromDate:[NSDate date]];
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
    NSDate * endday_toshow = [calendar dateByAddingComponents:components toDate:startDate options:0]; 
    
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
    
    weekScheduleController = [[WeekScheduleController alloc]initWithNibName:@"WeekScheduleController" bundle:nil]; 
    weekScheduleController.managedObjectContext = self.managedObjectContext;
    weekScheduleController.start_date = startDate;
    weekScheduleController.end_date = endDate;
    weekScheduleController.endday_toshow = endday_toshow;
    weekScheduleController.scheduleArray = [[NSMutableArray alloc]initWithArray:results];
    for(Schedule *sche in weekScheduleController.scheduleArray){
        NSString * tam;
        tam = sche.from_Date;
        NSLog(@"%@",tam);
    }
    [self.navigationController pushViewController:weekScheduleController animated:YES];
    
}
- (void)showReminder:(NSString *)text {
        
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Nhắc nhở" 
                                                message:text delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
    [alertView show]; 
}
- (BOOL) connectedToNetwork // kiem tra trang thai network co ket noi hay khong, neu co ket noi tra ve Yes nguoc lai No
{
    return ([NSString stringWithContentsOfURL:[NSURL URLWithString:@"http://www.google.com"]]!=NULL)?YES:NO;
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1){
        [self dismissModalViewControllerAnimated:YES];
    }
}
- (void)viewDidUnload{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}
- (void)viewWillDisappear:(BOOL)animated{
	[super viewWillDisappear:animated];
}
- (void)viewDidDisappear:(BOOL)animated{
	[super viewDidDisappear:animated];
}
 
/*- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    
    if ((interfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (interfaceOrientation == UIInterfaceOrientationLandscapeRight))
    {
        
        //scrollView.contentSize = CGSizeMake([[UIScreen mainScreen] bounds].size.height,[[UIScreen mainScreen] bounds].size.height);
        isPortrait = FALSE;
        //background_image.frame = CGRectMake(0,0,[[UIScreen mainScreen] bounds].size.height,[[UIScreen mainScreen] bounds].size.width);
        // kiem tra xem ung dung dang chay tren thiet bi nao: ipad hay iPhone
        if(IS_IPAD()){ // neu thiet bi dang su dung la ipad
            [background_image setImage:[UIImage imageNamed: @"bluebackgroundipad_lan.png"]];
            [update_button setImage:[UIImage imageNamed: @"updatebuttonipad.png"] forState:UIControlStateNormal];
            [dayschdule_button setImage:[UIImage imageNamed: @"dayschedulebuttonipad.png"] forState:UIControlStateNormal];
            [monthschedule_button setImage:[UIImage imageNamed: @"weekschedulebuttonipad.png"] forState:UIControlStateNormal];
            [setting_button setImage:[UIImage imageNamed: @"settingbuttonipad.png"] forState:UIControlStateNormal];
            update_button.frame = CGRectMake([[UIScreen mainScreen] bounds].size.height/2 - update_button.frame.size.width/2, 22, 390, 48);
            dayschdule_button.frame = CGRectMake([[UIScreen mainScreen] bounds].size.height/2 - dayschdule_button.frame.size.width/2, 114, 390, 48);
            monthschedule_button.frame = CGRectMake([[UIScreen mainScreen] bounds].size.height/2 - monthschedule_button.frame.size.width/2, 196, 390, 48);
            setting_button.frame = CGRectMake([[UIScreen mainScreen] bounds].size.height/2 - setting_button.frame.size.width/2, 522, 390, 48);
            
            update_button.frame = CGRectMake([[UIScreen mainScreen] bounds].size.height/2 - update_button.frame.size.width/2, 22, 390, 48);
            dayschdule_button.frame = CGRectMake([[UIScreen mainScreen] bounds].size.height/2 - dayschdule_button.frame.size.width/2, 114, 390, 48);
            monthschedule_button.frame = CGRectMake([[UIScreen mainScreen] bounds].size.height/2 - monthschedule_button.frame.size.width/2, 196, 390, 48);
            setting_button.frame = CGRectMake([[UIScreen mainScreen] bounds].size.height/2 - setting_button.frame.size.width/2,[[UIScreen mainScreen] bounds].size.width - 140, 390, 48);
            
            update_label.frame = CGRectMake(update_label.frame.origin.x, 80, update_label.frame.size.width, update_label.frame.size.height);
            
            logo_image.frame = CGRectMake(logo_image.frame.origin.x, 400, 200, 200);
            logo_image.frame = CGRectMake([[UIScreen mainScreen] bounds].size.height/2 - logo_image.frame.size.width/2, 400, 200, 200);
        }    
    }
    else { 
        isPortrait = TRUE;
        // kiem tra xem ung dung dang chay tren thiet bi nao: ipad hay iPhone
        //background_image.frame = CGRectMake(0,0,[[UIScreen mainScreen] bounds].size.width,[[UIScreen mainScreen] bounds].size.height);
        if(IS_IPAD()){ // neu thiet bi dang su dung la ipad
            [background_image setImage:[UIImage imageNamed: @"bluebackgroundipad.png"]];
            [update_button setImage:[UIImage imageNamed: @"updatebuttonipad.png"] forState:UIControlStateNormal];
            [dayschdule_button setImage:[UIImage imageNamed: @"dayschedulebuttonipad.png"] forState:UIControlStateNormal];
            [monthschedule_button setImage:[UIImage imageNamed: @"weekschedulebuttonipad.png"] forState:UIControlStateNormal];
            [setting_button setImage:[UIImage imageNamed: @"settingbuttonipad.png"] forState:UIControlStateNormal];
            update_button.frame = CGRectMake([[UIScreen mainScreen] bounds].size.width/2 - update_button.frame.size.width/2, 22, 390, 48);
            dayschdule_button.frame = CGRectMake([[UIScreen mainScreen] bounds].size.width/2 - dayschdule_button.frame.size.width/2, 114, 390, 48);
            monthschedule_button.frame = CGRectMake([[UIScreen mainScreen] bounds].size.width/2 - monthschedule_button.frame.size.width/2, 196, 390, 48);
            setting_button.frame = CGRectMake([[UIScreen mainScreen] bounds].size.width/2 - setting_button.frame.size.width/2, 522, 390, 48);
            
            update_button.frame = CGRectMake([[UIScreen mainScreen] bounds].size.width/2 - update_button.frame.size.width/2, 22, 390, 48);
            dayschdule_button.frame = CGRectMake([[UIScreen mainScreen] bounds].size.width/2 - dayschdule_button.frame.size.width/2, 114, 390, 48);
            monthschedule_button.frame = CGRectMake([[UIScreen mainScreen] bounds].size.width/2 - monthschedule_button.frame.size.width/2, 196, 390, 48);
            setting_button.frame = CGRectMake([[UIScreen mainScreen] bounds].size.width/2 - setting_button.frame.size.width/2,[[UIScreen mainScreen] bounds].size.height - 140, 390, 48);
            
            update_label.frame = CGRectMake(update_label.frame.origin.x, 80, update_label.frame.size.width, update_label.frame.size.height);
            
            logo_image.frame = CGRectMake(logo_image.frame.origin.x, 400, 200, 200);
            logo_image.frame = CGRectMake([[UIScreen mainScreen] bounds].size.width/2 - logo_image.frame.size.width/2, 400, 200, 200);
        } 
    }
    if(IS_IPAD()) return YES;
    else return NO;
}
*/

/*- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortraitUpsideDown;
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
    //return [[self.viewControllers lastObject] supportedInterfaceOrientations];
    //return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight | UIInterfaceOrientationMaskPortraitUpsideDown;
    return UIInterfaceOrientationMaskAll;
}
/*By default, an app and a view controller’s supported interface orientations are set to UIInterfaceOrientationMaskAll for the iPad idiom and UIInterfaceOrientationMaskAllButUpsideDown for the iPhone idiom. so thats work only specific orientation , if you want to allow all orientation for iphone you'll have allow as i have done in my answer
 */
/*- (BOOL)shouldAutorotate {
    
   // UIInterfaceOrientation orientation = [[UIDevice currentDevice] orientation];
    if(IS_IPAD()){
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    NSLog(@"%u",orientation);
    if (orientation==UIInterfaceOrientationPortraitUpsideDown || orientation==UIInterfaceOrientationPortrait) {
        isPortrait = TRUE;
        [background_image setImage:[UIImage imageNamed: @"bluebackgroundipad.png"]];
        [update_button setImage:[UIImage imageNamed: @"updatebuttonipad.png"] forState:UIControlStateNormal];
        [dayschdule_button setImage:[UIImage imageNamed: @"dayschedulebuttonipad.png"] forState:UIControlStateNormal];
        [monthschedule_button setImage:[UIImage imageNamed: @"weekschedulebuttonipad.png"] forState:UIControlStateNormal];
        [setting_button setImage:[UIImage imageNamed: @"settingbuttonipad.png"] forState:UIControlStateNormal];
        update_button.frame = CGRectMake([[UIScreen mainScreen] bounds].size.width/2 - update_button.frame.size.width/2, 22, 390, 48);
        dayschdule_button.frame = CGRectMake([[UIScreen mainScreen] bounds].size.width/2 - dayschdule_button.frame.size.width/2, 114, 390, 48);
        monthschedule_button.frame = CGRectMake([[UIScreen mainScreen] bounds].size.width/2 - monthschedule_button.frame.size.width/2, 196, 390, 48);
        setting_button.frame = CGRectMake([[UIScreen mainScreen] bounds].size.width/2 - setting_button.frame.size.width/2, 522, 390, 48);
        
        update_button.frame = CGRectMake([[UIScreen mainScreen] bounds].size.width/2 - update_button.frame.size.width/2, 22, 390, 48);
        dayschdule_button.frame = CGRectMake([[UIScreen mainScreen] bounds].size.width/2 - dayschdule_button.frame.size.width/2, 114, 390, 48);
        monthschedule_button.frame = CGRectMake([[UIScreen mainScreen] bounds].size.width/2 - monthschedule_button.frame.size.width/2, 196, 390, 48);
        setting_button.frame = CGRectMake([[UIScreen mainScreen] bounds].size.width/2 - setting_button.frame.size.width/2,[[UIScreen mainScreen] bounds].size.height - 140, 390, 48);
        
        update_label.frame = CGRectMake(update_label.frame.origin.x, 80, update_label.frame.size.width, update_label.frame.size.height);
        
        logo_image.frame = CGRectMake(logo_image.frame.origin.x, 400, 200, 200);
        logo_image.frame = CGRectMake([[UIScreen mainScreen] bounds].size.width/2 - logo_image.frame.size.width/2, 400, 200, 200);
        
    }
 
    else if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight) {
        isPortrait = FALSE;
        [background_image setImage:[UIImage imageNamed: @"bluebackgroundipad_lan.png"]];
        [update_button setImage:[UIImage imageNamed: @"updatebuttonipad.png"] forState:UIControlStateNormal];
        [dayschdule_button setImage:[UIImage imageNamed: @"dayschedulebuttonipad.png"] forState:UIControlStateNormal];
        [monthschedule_button setImage:[UIImage imageNamed: @"weekschedulebuttonipad.png"] forState:UIControlStateNormal];
        [setting_button setImage:[UIImage imageNamed: @"settingbuttonipad.png"] forState:UIControlStateNormal];
        update_button.frame = CGRectMake([[UIScreen mainScreen] bounds].size.height/2 - update_button.frame.size.width/2, 22, 390, 48);
        dayschdule_button.frame = CGRectMake([[UIScreen mainScreen] bounds].size.height/2 - dayschdule_button.frame.size.width/2, 114, 390, 48);
        monthschedule_button.frame = CGRectMake([[UIScreen mainScreen] bounds].size.height/2 - monthschedule_button.frame.size.width/2, 196, 390, 48);
        setting_button.frame = CGRectMake([[UIScreen mainScreen] bounds].size.height/2 - setting_button.frame.size.width/2, 522, 390, 48);
        
        update_button.frame = CGRectMake([[UIScreen mainScreen] bounds].size.height/2 - update_button.frame.size.width/2, 22, 390, 48);
        dayschdule_button.frame = CGRectMake([[UIScreen mainScreen] bounds].size.height/2 - dayschdule_button.frame.size.width/2, 114, 390, 48);
        monthschedule_button.frame = CGRectMake([[UIScreen mainScreen] bounds].size.height/2 - monthschedule_button.frame.size.width/2, 196, 390, 48);
        setting_button.frame = CGRectMake([[UIScreen mainScreen] bounds].size.height/2 - setting_button.frame.size.width/2,[[UIScreen mainScreen] bounds].size.width - 140, 390, 48);
        
        update_label.frame = CGRectMake(update_label.frame.origin.x, 80, update_label.frame.size.width, update_label.frame.size.height);
        
        logo_image.frame = CGRectMake(logo_image.frame.origin.x, 400, 200, 200);
        logo_image.frame = CGRectMake([[UIScreen mainScreen] bounds].size.height/2 - logo_image.frame.size.width/2, 400, 200, 200);
    }
    }
    if(IS_IPAD()) return YES;
    else return NO;
}*/
- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if(IS_IPAD()) return YES;
    else return NO;
}
// Determine iOS 6 Autorotation.
- (BOOL)shouldAutorotate{
    /*UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    //UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    //    // Return yes to allow the device to load initially.
    //if (orientation == UIDeviceOrientationUnknown) return YES;
    //    // Pass iOS 6 Request for orientation on to iOS 5 code. (backwards compatible)
    BOOL result = [self shouldAutorotateToInterfaceOrientation:orientation];*/
    
    //NSLog(@"%u",orientation);
    [self.settingViewController shouldAutorotate];
    [self.weekScheduleController shouldAutorotate];
    [self.newdayViewController shouldAutorotate];
    //if(IS_IPAD()) return result;
    //else
        return NO;
    
    //return YES;
}
//- (BOOL)shouldAutorotate
//{
//    return [self.visibleViewController shouldAutorotate];
//}
/*- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)  interfaceOrientation duration:(NSTimeInterval)duration
{
        switch (interfaceOrientation) {
            case UIInterfaceOrientationPortrait:
 
                break;
                
            case UIInterfaceOrientationPortraitUpsideDown: 
                break;
                
            case UIInterfaceOrientationLandscapeLeft: 
                break;
                
            case UIInterfaceOrientationLandscapeRight: 
                break;
                
            default:
                break;
        }     
}*/
@end
