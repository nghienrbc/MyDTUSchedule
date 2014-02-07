//
//  LoginViewController.h
//  MyDTUSchedule
//
//  Created by duc nguyen minh on 1/24/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScheduleViewController.h"

//@class Reachability; 
@interface LoginViewController : UIViewController <UITextFieldDelegate> {
    
    ScheduleViewController *viewController; 
    UINavigationController *myNavigationController;
    IBOutlet UILabel *login_info_label;
    IBOutlet UIImageView * background_image; 
}

@property (nonatomic, retain) WeekScheduleController    *weekScheduleController;
@property (nonatomic, retain) IBOutlet UIImageView *background_image;
@property (nonatomic, retain) IBOutlet UIScrollView *scroll_view;


@property (nonatomic,retain) IBOutlet UITableView *tableView_login;
@property (nonatomic, retain) IBOutlet UITextField *usernameField;// chua ten user   
@property (nonatomic, retain) IBOutlet UITextField *passwordField;// chua password cua user
@property (nonatomic, retain) IBOutlet UIButton *loginBtn;// button dang nhap

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;// su dung voi Core Data thay the cho sqlite
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext; 
@property (nonatomic, retain) IBOutlet ScheduleViewController *viewController;  

@property (nonatomic, retain) IBOutlet UINavigationController *myNavigationController;


@property (strong, nonatomic) NSString *mypwd;      // string luu ten user
@property (strong, nonatomic) NSString *myuser;     // string luu password cua user
@property(nonatomic,retain) IBOutlet UIImageView *bgImage; // anh nen cua view login
@property(nonatomic,retain) IBOutlet UIImageView *titleImage; // anh title cua view login


- (IBAction)loginSC:(id)sender;         // ham login
- (NSString *) mahoaPass: (NSString*)passWord;  // ham ma hoa Password
- (void) copyDatabaseIfNeeded:(NSString*) filename;
- (NSString*) getFilePath:(NSString*) filename;
@end
