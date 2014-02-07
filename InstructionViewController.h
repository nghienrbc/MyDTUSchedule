//
//  InstructionViewController.h
//  MyDTUSchedule
//
//  Created by Nguyen Minh Duc on 2/24/13.
//
//

#import <UIKit/UIKit.h>
#import "DetailInstructionViewController.h"
@interface InstructionViewController : UIViewController{
    IBOutlet UIWebView *webView;
    IBOutlet UIButton *help1_button;
    IBOutlet UIButton *help2_button;
    IBOutlet UIButton *help3_button;
    IBOutlet UIButton *help4_button;
    IBOutlet UIButton *help5_button;
    IBOutlet UIButton *help6_button;
}

@property (nonatomic,retain) IBOutlet UIButton *help1_button;
@property (nonatomic,retain) IBOutlet UIButton *help2_button;
@property (nonatomic,retain) IBOutlet UIButton *help3_button;
@property (nonatomic,retain) IBOutlet UIButton *help4_button;
@property (nonatomic,retain) IBOutlet UIButton *help5_button;
@property (nonatomic,retain) IBOutlet UIButton *help6_button;
@property (nonatomic,retain) DetailInstructionViewController *detailInstructionView;
- (IBAction)help1_button_click:(id)sender;
- (IBAction)help2_button_click:(id)sender;
- (IBAction)help3_button_click:(id)sender;
- (IBAction)help4_button_click:(id)sender;
- (IBAction)help5_button_click:(id)sender;
- (IBAction)help6_button_click:(id)sender;
@end
