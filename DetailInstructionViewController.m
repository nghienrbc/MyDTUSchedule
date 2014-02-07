//
//  DetailInstructionViewController.m
//  MyDTUSchedule
//
//  Created by Nguyen Minh Duc on 4/30/13.
//
//

#import "DetailInstructionViewController.h"

@interface DetailInstructionViewController ()

@end 

@implementation DetailInstructionViewController
@synthesize help_number;

UIScrollView *scroll_view;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewWillAppear:(BOOL)animated{
    //[self.navigationController setNavigationBarHidden:NO];
    [super viewWillAppear:animated];
    if(help_number == 1){ 
        //tao moi 1 scrollview chua cac text view va cac image
        scroll_view = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, [[UIScreen mainScreen] bounds].size.width , [[UIScreen mainScreen] bounds].size.height - 20 - 44)];
        scroll_view.contentSize = CGSizeMake(self.view.frame.size.width,120 + 10);// chua biet chac
        [scroll_view setTag:1900];
        [self.view addSubview:scroll_view];
        UILabel *help_label;
        help_label = [[UILabel alloc] initWithFrame:CGRectMake(0,10, 320, 20)];
        help_label.textAlignment = UITextAlignmentCenter;
        help_label.text = @"Đăng nhập";
        help_label.textColor = [UIColor whiteColor];
        help_label.backgroundColor = [UIColor clearColor];
        [scroll_view addSubview:help_label];
        
        UITextView *help_context;
        help_context = [[UITextView alloc] initWithFrame:CGRectMake(0,40, 320, 150)];
        help_context.textAlignment = UITextAlignmentCenter;
        help_context.text = @"Đăng nhập Đăng nhập Đăng nhập Đăng nhập Đăng nhập \n dsfsfs sdfsdf \n\n agag";
        help_context.textColor = [UIColor whiteColor];
        help_context.backgroundColor = [UIColor clearColor];
        NSLog(@"%f",help_context.contentSize.height);
        UITextView *help_context1;
        help_context1 = [[UITextView alloc] initWithFrame:CGRectMake(0, 40, 320, help_context.contentSize.height)];
        help_context1.textAlignment = UITextAlignmentCenter;
        help_context1.text = @"Đăng nhập Đăng nhập Đăng nhập Đăng nhập Đăng nhập \n dsfsfs sdfsdf \n\n agag";
        help_context1.textColor = [UIColor whiteColor];
        help_context1.backgroundColor = [UIColor clearColor];
        [scroll_view addSubview:help_context1];

        
        UIImageView *help_image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"imagehelp1.png"]];
        help_image.frame = CGRectMake(320/2 - 250/2, 40 + 10 + help_context.contentSize.height, 250, 292);
        [scroll_view addSubview:help_image];
    }
    else if(help_number == 2){
        self.title = @"2";
    }
    else if(help_number == 3){
        self.title = @"3";
    }
    else if(help_number == 4){
        self.title = @"4";
    }
    else if(help_number == 5){
        self.title = @"5";
    }
    else if(help_number == 6){
        self.title = @"6";
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
