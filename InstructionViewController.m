//
//  InstructionViewController.m
//  MyDTUSchedule
//
//  Created by Nguyen Minh Duc on 2/24/13.
//
//

#import "InstructionViewController.h"

@interface InstructionViewController ()

@end

@implementation InstructionViewController
@synthesize detailInstructionView;
@synthesize help1_button, help2_button, help3_button, help4_button, help5_button, help6_button; 
UIScrollView *scroll_view;

//@synthesize webView;
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
  
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Hướng dẫn";
    /*UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0,
                                                                     self.view.frame.size.width,self.view.frame.size.height)];
    
    NSString *indexPath = [NSBundle pathForResource:@"about" ofType:@"html" inDirectory:nil];
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:indexPath]]];*/
    //NSURL *url = [[NSBundle mainBundle] URLForResource:@"about" withExtension:@"html"];
    //NSString *html = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    
    //[webView loadHTMLString:html baseURL:[url URLByDeletingLastPathComponent]];
    //[webView setBackgroundColor:[UIColor clearColor]];
    //[webView setOpaque:NO];
}


- (IBAction)help1_button_click:(id)sender{
    
    detailInstructionView = [[DetailInstructionViewController alloc]initWithNibName:@"DetailInstructionViewController" bundle:nil];
    detailInstructionView.help_number = 1;
    [self.navigationController pushViewController:detailInstructionView animated:YES];
    
   // [self show_after_touch_button_left:help3_button];
}
- (IBAction)help2_button_click:(id)sender{
    detailInstructionView = [[DetailInstructionViewController alloc]initWithNibName:@"DetailInstructionViewController" bundle:nil];
    detailInstructionView.help_number = 2;
    [self.navigationController pushViewController:detailInstructionView animated:YES];
}
- (IBAction)help3_button_click:(id)sender{
    detailInstructionView = [[DetailInstructionViewController alloc]initWithNibName:@"DetailInstructionViewController" bundle:nil];
    detailInstructionView.help_number = 3;
    [self.navigationController pushViewController:detailInstructionView animated:YES];
}
- (IBAction)help4_button_click:(id)sender{
    detailInstructionView = [[DetailInstructionViewController alloc]initWithNibName:@"DetailInstructionViewController" bundle:nil];
    detailInstructionView.help_number = 4;
    [self.navigationController pushViewController:detailInstructionView animated:YES];
}
- (IBAction)help5_button_click:(id)sender{
    detailInstructionView = [[DetailInstructionViewController alloc]initWithNibName:@"DetailInstructionViewController" bundle:nil];
    detailInstructionView.help_number = 5;
    [self.navigationController pushViewController:detailInstructionView animated:YES];
}
- (IBAction)help6_button_click:(id)sender{
    detailInstructionView = [[DetailInstructionViewController alloc]initWithNibName:@"DetailInstructionViewController" bundle:nil];
    detailInstructionView.help_number = 6;
    [self.navigationController pushViewController:detailInstructionView animated:YES];
}

- (void) show_after_touch_button_left:(UIView*) view{
	[UIView beginAnimations:@"animateImageOff" context:NULL]; // Begin animation
	[view setFrame:CGRectOffset([view frame], -view.frame.size.width, 0)]; // Move imageView off screen
    [UIView setAnimationDuration:2.25];
	[UIView commitAnimations]; // End animations
	[UIView beginAnimations:@"animateImageOn" context:NULL]; // Begin animation
	[UIView setAnimationDuration:0.25];
	[view setFrame:CGRectOffset([view frame], view.frame.size.width, 0)]; // Move imageView on screen
	//[UIView commitAnimations]; // End animations
	
}
- (void) show_after_touch_button_right:(UIView*)view{
	//[schedule_table scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
	[UIView beginAnimations:@"animateImageOff" context:NULL]; // Begin animation
	[view setFrame:CGRectOffset([view frame], view.frame.size.width, 0)]; // Move imageView off screen
    [UIView setAnimationDuration:2.25];
	[UIView commitAnimations]; // End animations
	/*[UIView beginAnimations:@"animateImageOn" context:NULL]; // Begin animation
	[UIView setAnimationDuration:0.25];
	[view setFrame:CGRectOffset([view frame], -view.frame.size.width, 0)]; // Move imageView on screen
	[UIView commitAnimations]; // End animations*/
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
