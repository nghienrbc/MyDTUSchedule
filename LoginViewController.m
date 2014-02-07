//
//  LoginViewController.m
//  MyDTUSchedule
//
//  Created by duc nguyen minh on 1/24/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//http://stackoverflow.com/questions/12996293/io6-doesnt-call-boolshouldautorotate

#import "LoginViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>

#import "NSString+MD5.h"
#import "NSData+MD5.h"
#import "NSString+MD5.m"
#import "NSData+MD5.m" // khong co hai thang .m nay la bi cai loi duoi nay day
/*2013-02-26 13:46:04.176 MyDTUSchedule[4062:c07] -[__NSCFConstantString MD5]: unrecognized selector sent to instance 0x32ccc
 2013-02-26 13:46:04.177 MyDTUSchedule[4062:c07] *** Terminating app due to uncaught exception 'NSInvalidArgumentException', reason: '-[__NSCFConstantString MD5]: unrecognized selector sent to instance 0x32ccc'*/
#import <CommonCrypto/CommonDigest.h>
//#import "Reachability.h"
@implementation LoginViewController
#define IS_IPAD() ([[UIDevice currentDevice] respondsToSelector:@selector(userInterfaceIdiom)] ? \
[[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad : NO)

@synthesize weekScheduleController;
@synthesize usernameField;
@synthesize passwordField;

@synthesize fetchedResultsController;
@synthesize managedObjectContext;

@synthesize mypwd;
@synthesize myuser;
@synthesize bgImage;
@synthesize loginBtn;
@synthesize titleImage;
@synthesize tableView_login;

@synthesize viewController;
@synthesize myNavigationController;
@synthesize background_image;
@synthesize scroll_view;

NSString  *URLForLogin = @"http://dev.duytan.edu.vn:8085/connectservice.asmx";

NSFileManager *filemgr;
NSMutableArray *event_idArray;

/*
 Mã hóa MD5 - SHA dua tren CommonCrypto/CommonDigest.h
 */
-(NSString *)Base64Encode:(NSData *)data{
    //Point to start of the data and set buffer sizes
    int inLength = [data length];
    int outLength = ((((inLength * 4)/3)/4)*4) + (((inLength * 4)/3)%4 ? 4 : 0);
    const char *inputBuffer = [data bytes];
    char *outputBuffer = malloc(outLength);
    outputBuffer[outLength] = 0;
    
    //64 digit code
    static char Encode[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
    
    //start the count
    int cycle = 0;
    int inpos = 0;
    int outpos = 0;
    char temp;
    
    //Pad the last to bytes, the outbuffer must always be a multiple of 4
    outputBuffer[outLength-1] = '=';
    outputBuffer[outLength-2] = '=';
    
    /* http://en.wikipedia.org/wiki/Base64
     Text content   M           a           n
     ASCII          77          97          110
     8 Bit pattern  01001101    01100001    01101110
     
     6 Bit pattern  010011  010110  000101  101110
     Index          19      22      5       46
     Base64-encoded T       W       F       u
     */
    
    
    while (inpos < inLength){
        switch (cycle) {
            case 0:
                outputBuffer[outpos++] = Encode[(inputBuffer[inpos]&0xFC)>>2];
                cycle = 1;
                break;
            case 1:
                temp = (inputBuffer[inpos++]&0x03)<<4;
                outputBuffer[outpos] = Encode[temp];
                cycle = 2;
                break;
            case 2:
                outputBuffer[outpos++] = Encode[temp|(inputBuffer[inpos]&0xF0)>> 4];
                temp = (inputBuffer[inpos++]&0x0F)<<2;
                outputBuffer[outpos] = Encode[temp];
                cycle = 3;
                break;
            case 3:
                outputBuffer[outpos++] = Encode[temp|(inputBuffer[inpos]&0xC0)>>6];
                cycle = 4;
                break;
            case 4:
                outputBuffer[outpos++] = Encode[inputBuffer[inpos++]&0x3f];
                cycle = 0;
                break;
            default:
                cycle = 0;
                break;
        }
    }
    NSString *pictemp = [NSString stringWithUTF8String:outputBuffer];
    free(outputBuffer);
    return pictemp;
}
- (char) SixBitToChar: (Byte )b
{
    char c;
    if (b < 26)
    {
        c = (char)((int)b + (int)'A');
    }
    else if (b < 52)
    {
        c = (char)((int)b - 26 + (int)'a');
    }
    else if (b < 62)
    {
        c = (char)((int)b - 52 + (int)'0');
    }
    else if (b == 62)
    {
        c = '+';
    }
    else
    {
        c = '/';
    }
    return c;
}

- (NSString*)ToBase64: (NSData*) data {
    int length = data == nil ? 0 : data.length;
    if (length == 0)
        return nil;
    
    int padding = length % 3;
    if (padding > 0)
        padding = 3 - padding;
    int blocks = (length - 1) / 3 + 1;
    
    //char[] s = new char[blocks * 4];
    int inLength = [data length];
    int outLength = ((((inLength * 4)/3)/4)*4) + (((inLength * 4)/3)%4 ? 4 : 0);
    
    char *outputBuffer = malloc(outLength);
    outputBuffer[outLength] = 0;
    
    for (int i = 0; i < blocks; i++)
    {
        bool finalBlock = i == blocks - 1;
        bool pad2 = false;
        bool pad1 = false;
        if (finalBlock)
        {
            pad2 = padding == 2;
            pad1 = padding > 0;
        }
        
        int index = i * 3;
        const char *charData = [data bytes];
        Byte b1 = charData[index];
        Byte b2 = pad2 ? (Byte)0 : charData[index + 1];
        Byte b3 = pad1 ? (Byte)0 : charData[index + 2];
        
        Byte temp1 = (Byte)((b1 & 0xFC) >> 2);
        
        Byte temp = (Byte)((b1 & 0x03) << 4);
        Byte temp2 = (Byte)((b2 & 0xF0) >> 4);
        temp2 += temp;
        
        temp = (Byte)((b2 & 0x0F) << 2);
        Byte temp3 = (Byte)((b3 & 0xC0) >> 6);
        temp3 += temp;
        
        Byte temp4 = (Byte)(b3 & 0x3F);
        
        index = i * 4;
        outputBuffer[index] = [self SixBitToChar:temp1];
        outputBuffer[index+1] = [self SixBitToChar:temp2];
        outputBuffer[index+2] = pad2 ? '=' : [self SixBitToChar:temp3];
        outputBuffer[index+3] = pad1 ? '=' : [self SixBitToChar:temp4];
    }
    NSString *mystring = [NSString stringWithUTF8String:outputBuffer];
    return mystring;
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
- (void)viewWillAppear:(BOOL)animated{
    //[self.navigationController setNavigationBarHidden:NO];
    [super viewWillAppear:animated];
    if([UIScreen mainScreen].bounds.size.height < 500){
        background_image.frame = CGRectMake(0 ,0, 320, 548);
    }
    if(IS_IPAD()){
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) {
            [background_image setImage:[UIImage imageNamed:@"loginbackgroundipad.png"]];
        }
        else{
            [background_image setImage:[UIImage imageNamed:@"loginbackgroundipad_lan.png"]];
        }
            
        tableView_login.frame = CGRectMake(tableView_login.frame.origin.x, 200, tableView_login.frame.size.width,tableView_login.frame.size.height);
        loginBtn.frame = CGRectMake(loginBtn.frame.origin.x, 320, loginBtn.frame.size.width,loginBtn.frame.size.height);
        login_info_label.frame = CGRectMake(login_info_label.frame.origin.x, 400, login_info_label.frame.size.width,login_info_label.frame.size.height);
    }
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //weekScheduleController = [[WeekScheduleController alloc]initWithNibName:@"WeekScheduleController" bundle:nil];
    login_info_label.hidden = TRUE;
    [tableView_login setBackgroundView:nil];
    [tableView_login setBackgroundColor:[UIColor clearColor]];
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}
- (BOOL) connectedToNetwork // kiem tra trang thai network co ket noi hay khong, neu co ket noi tra ve Yes nguoc lai No
{
    return ([NSString stringWithContentsOfURL:[NSURL URLWithString:@"http://www.google.com"]]!=NULL)?YES:NO;
}


- (IBAction)loginSC:(id)sender { 
    
    [usernameField resignFirstResponder]; // ha cai keyboard xuong
    [passwordField resignFirstResponder]; // ha cai keyboard xuong
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *user = [prefs stringForKey:@"keyUserName"];
    NSString *pass = [prefs stringForKey:@"keyPassWord"]; // lay mat khau da ma hoa trong lan dang nhap truoc, neu chua co lan nao dang nhap thi = nil
    NSString *mypass = nil;
    if(![passwordField.text isEqualToString:@""] ) mypass = [self mahoaPass:passwordField.text]; // ma hoa mat khau hien tai
    NSLog(@"%@",mypass);
    // tien hanh kiem tra user, password xem co dung khong
    // truong hop dac biet dung de test, khong can nhap pass word
    if([usernameField.text isEqualToString:@"huynhbadieu"]){
        [prefs setObject:usernameField.text forKey:@"keyUserName"];
        [prefs setObject:@"huynhbadieu" forKey:@"keyPassWord"];
        [prefs setObject:@"true" forKey:@"keyLoginAgain"];
        if(IS_IPAD()) viewController = [[ScheduleViewController alloc] initWithNibName:@"ScheduleViewControlleripad" bundle:nil];
        else viewController = [[ScheduleViewController alloc] initWithNibName:@"ScheduleViewController" bundle:nil];
        viewController.managedObjectContext = self.managedObjectContext;        
        if(myNavigationController == nil)
            myNavigationController = [[UINavigationController alloc]initWithRootViewController:viewController];
        //MyNavigationController *nav = [[MyNavigationController alloc] initWithRootViewController:self.viewController];
        
        login_info_label.hidden = TRUE;
        login_info_label.text = @"";
        //[prefs setObject:@"true" forKey:@"keyRemindSwitch_myDTU"];
        [prefs setObject:@"false" forKey:@"keyRemindSwitch_myDTU"];
        [prefs setObject:@"false" forKey:@"keyCalendarSwitch_myDTU"];
        [prefs setObject:@"15 Phút" forKey:@"keyAlertType_myDTU"];
        [self presentModalViewController:myNavigationController animated:YES];
        return;
    }
    else if([usernameField.text isEqualToString:@""] || [passwordField.text isEqualToString:@""])
    {
        // truong hop chua nhap user hoac password
        // hieu ung lac form user password
        login_info_label.hidden = FALSE;
        login_info_label.text = @"Chưa nhập đầy đủ Username và Password";
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
        [animation setDuration:0.09];
        [animation setRepeatCount:4];
        [animation setAutoreverses:YES];
        [animation setFromValue:[NSValue valueWithCGPoint:CGPointMake([tableView_login center].x - 20.0f, [tableView_login center].y)]];
        [animation setToValue:[NSValue valueWithCGPoint:CGPointMake([tableView_login center].x + 20.0f, [tableView_login center].y)]];
        [[tableView_login layer] addAnimation:animation forKey:@"position"];
        return;
    }
    // kiem tra xem da luu user va password lan nao chua
    else if([prefs stringForKey:@"keyUserName"] == nil || [prefs stringForKey:@"keyPassWord"] == nil){// truong hop lan dau tien dang nhap
        /*Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
        NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
        if (networkStatus == NotReachable) {
            NSLog(@"There IS NO internet connection");
        } else { 
            NSLog(@"There IS internet connection"); 
        }     */
        // kiem tra xem co mang hay khong
        if (self.connectedToNetwork) { // da co mang, kiem tra username va password co dung khong
            NSLog(@"There is internet connection");  
            // kiem tra password va username truc tiep tren webservice 
            NSURL *xmlURL1 = [NSURL URLWithString: [NSString stringWithFormat: @"%@/Login?username=%@&password=%@", URLForLogin, usernameField.text, mypass]];
            NSLog(@"%@",xmlURL1);
            NSString *html = [NSString stringWithContentsOfURL:xmlURL1 encoding:NSUTF8StringEncoding error:nil];
            NSLog(@"%@",html);
            if ([html rangeOfString:@"true"].location == NSNotFound) { // ten user va pass khong hop le
                NSLog(@"string does not contain true");
                // hien thi thong bao dang nhap sai username va password
                login_info_label.hidden = FALSE;
                login_info_label.text = @"Sai tên đăng nhập hoặc password";
                CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
                [animation setDuration:0.09];
                [animation setRepeatCount:4];
                [animation setAutoreverses:YES];
                [animation setFromValue:[NSValue valueWithCGPoint:CGPointMake([tableView_login center].x - 20.0f, [tableView_login center].y)]];
                [animation setToValue:[NSValue valueWithCGPoint:CGPointMake([tableView_login center].x + 20.0f, [tableView_login center].y)]];
                [[tableView_login layer] addAnimation:animation forKey:@"position"]; 
                return;
            }
            else { // ten user va pass hop le, dang nhap dung
                NSLog(@"string contains true!");                
                // luu mot bien de cho biet la lan dang nhap nay voi ten mot user khac lan dang nhap truoc
                [prefs setObject:@"false" forKey:@"keyLoginAgain"];
                
                viewController = [[ScheduleViewController alloc] initWithNibName:@"ScheduleViewController" bundle:nil];
                viewController.managedObjectContext = self.managedObjectContext;
                
                if(myNavigationController == nil)
                    myNavigationController = [[UINavigationController alloc]initWithRootViewController:viewController];
                 
                // luu user name vao password vao key 
                [prefs setObject:usernameField.text forKey:@"keyUserName"];
                [prefs setObject:mypass forKey:@"keyPassWord"]; // luu mat khau da duoc ma hoa
                // thiet lap trang thai cho cac control trong form setting
                [prefs setObject:@"false" forKey:@"keyRemindSwitch_myDTU"];
                [prefs setObject:@"false" forKey:@"keyCalendarSwitch_myDTU"];
                [prefs setObject:@"15 Phút" forKey:@"keyAlertType_myDTU"];
                
                login_info_label.hidden = TRUE;
                login_info_label.text = @"";
                [self presentModalViewController:myNavigationController animated:YES];
            }   
        }
        else { // truong hop khong co ket noi mang
            
            NSLog(@"There IS NO internet connection");
            // hien thi thong bao khong co mang
            login_info_label.hidden = FALSE;
            login_info_label.text = @"Bật kết nối mạng cho lần đăng nhập đầu tiên"; 
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
            [animation setDuration:0.09];
            [animation setRepeatCount:4];
            [animation setAutoreverses:YES];
            [animation setFromValue:[NSValue valueWithCGPoint:CGPointMake([tableView_login center].x - 20.0f, [tableView_login center].y)]];
            [animation setToValue:[NSValue valueWithCGPoint:CGPointMake([tableView_login center].x + 20.0f, [tableView_login center].y)]];
            [[tableView_login layer] addAnimation:animation forKey:@"position"];
            
            return;
        }
    }
    // truong hop da tung dang nhap roi, kiem tra xem lan dang nhap nay co giong lan dang nhap truoc khong
    else if(![usernameField.text isEqualToString:user] || ![mypass isEqualToString:pass]){ // dang nhap khong giong lan truoc
        // kiem tra xem co mang hay khong
        if (self.connectedToNetwork) { // da co mang, kiem tra username va password co dung khong
            NSLog(@"There is internet connection");
            // kiem tra password va username truc tiep tren webservice
            NSURL *xmlURL1 = [NSURL URLWithString: [NSString stringWithFormat: @"%@/Login?username=%@&password=%@", URLForLogin, usernameField.text, mypass]];
            NSLog(@"%@",xmlURL1);
            NSString *html = [NSString stringWithContentsOfURL:xmlURL1 encoding:NSUTF8StringEncoding error:nil];
            NSLog(@"%@",html);
            if ([html rangeOfString:@"true"].location == NSNotFound) { // ten user va pass khong hop le
                NSLog(@"string does not contain true");
                // hien thi thong bao dang nhap sai username va password
                login_info_label.hidden = FALSE;
                login_info_label.text = @"Sai tên đăng nhập hoặc password";
                CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
                [animation setDuration:0.09];
                [animation setRepeatCount:4];
                [animation setAutoreverses:YES];
                [animation setFromValue:[NSValue valueWithCGPoint:CGPointMake([tableView_login center].x - 20.0f, [tableView_login center].y)]];
                [animation setToValue:[NSValue valueWithCGPoint:CGPointMake([tableView_login center].x + 20.0f, [tableView_login center].y)]];
                [[tableView_login layer] addAnimation:animation forKey:@"position"];
                return;
            }
            else { // ten user va pass hop le, dang nhap dung
                NSLog(@"string contains true!");
                // luu mot bien de cho biet la lan dang nhap nay voi ten mot user khac lan dang nhap truoc
                [prefs setObject:@"false" forKey:@"keyLoginAgain"];
                
                viewController = [[ScheduleViewController alloc] initWithNibName:@"ScheduleViewController" bundle:nil];
                viewController.managedObjectContext = self.managedObjectContext;
                
                if(myNavigationController == nil)
                    myNavigationController = [[UINavigationController alloc]initWithRootViewController:viewController];
                
                // luu user name vao password vao key
                [prefs setObject:usernameField.text forKey:@"keyUserName"];
                [prefs setObject:mypass forKey:@"keyPassWord"]; // luu mat khau da duoc ma hoa
                
                // thiet lap trang thai cho cac control trong form setting
                [prefs setObject:@"false" forKey:@"keyRemindSwitch_myDTU"];
                [prefs setObject:@"false" forKey:@"keyCalendarSwitch_myDTU"];
                [prefs setObject:@"15 Phút" forKey:@"keyAlertType_myDTU"];
                
                login_info_label.hidden = TRUE;
                login_info_label.text = @"";
                [self presentModalViewController:myNavigationController animated:YES];
            }
        } else { // truong hop khong co ket noi mang
            
            NSLog(@"There IS NO internet connection");
            // hien thi thong bao khong co mang
            login_info_label.hidden = FALSE;
            login_info_label.text = @"Bật kết nối mạng khi đăng nhập với user mới";
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
            [animation setDuration:0.09];
            [animation setRepeatCount:4];
            [animation setAutoreverses:YES];
            [animation setFromValue:[NSValue valueWithCGPoint:CGPointMake([tableView_login center].x - 20.0f, [tableView_login center].y)]];
            [animation setToValue:[NSValue valueWithCGPoint:CGPointMake([tableView_login center].x + 20.0f, [tableView_login center].y)]];
            [[tableView_login layer] addAnimation:animation forKey:@"position"];
            
            return;
        }
    }
    // truong hop con lai chac chan la truong hop dang nhap dung va trung voi lan dang nhap truoc, khoi can kiem tra co mang hay chua, cung khoi can kiem tra co hop le khong
    // vi co vo mang dau ma kiem tra hop le
    else {
        // luu mot bien de cho biet la lan dang nhap nay voi ten mot user giong lan dang nhap truoc
        [prefs setObject:@"true" forKey:@"keyLoginAgain"];
        viewController = [[ScheduleViewController alloc] initWithNibName:@"ScheduleViewController" bundle:nil];
        viewController.managedObjectContext = self.managedObjectContext;
        
        if(myNavigationController == nil)
            myNavigationController = [[UINavigationController alloc]initWithRootViewController:viewController];
        
        // neu da dung user password
        // luu user name vao password vao key
        [prefs setObject:usernameField.text forKey:@"keyUserName"];
        [prefs setObject:mypass forKey:@"keyPassWord"];
        login_info_label.hidden = TRUE;
        login_info_label.text = @"";
        [self presentModalViewController:myNavigationController animated:YES];
    } 
}

- (NSString *) mahoaPass: (NSString*)passWord{
    
    unsigned char result[CC_SHA1_DIGEST_LENGTH]; // digest length in bytes = 20
    const char *cStr = [[passWord MD5] UTF8String];
    NSLog(@"MD5: %s",cStr);
    CC_SHA1(cStr, strlen(cStr), result);
    NSLog(@"result: %s",result);
    NSData *pwHashData = [[NSData alloc] initWithBytes:result length: sizeof result];
    NSLog(@"MD5 data: %@",pwHashData);
    //NSString *base64 = [pwHashData base64Encoding];
    //    NSString *base64 = [ pwHashData base64Encoding];
    NSString *base64 = [self ToBase64:pwHashData];
    
    //== kết thúc mã lần 2==============
    NSData *pwHashData1 = [base64 dataUsingEncoding:NSUTF8StringEncoding];
    
    //        NSString *cc = [pwHashData1 base64Encoding];
    NSString *cc = [self ToBase64:pwHashData1];
    NSLog(@"Base64_2: %@",cc);
    return cc;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;

}
  
//////// tableview cho login
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}
- (UITableViewCell *)tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [table dequeueReusableCellWithIdentifier:@"Cell"];
    if( cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];   
    //cell.backgroundColor =  [UIColor clearColor];
    if (indexPath.row == 0) {
        usernameField = [[UITextField alloc] initWithFrame:CGRectMake(5, 0, 230, 21)];
        usernameField.text=@"huynhbadieu";
        usernameField.placeholder = @"Tên đăng nhập";
        [usernameField setDelegate:self];
        [usernameField setReturnKeyType:UIReturnKeyDone];
        [usernameField addTarget:self
                          action:@selector(loginSC:)
                forControlEvents:UIControlEventEditingDidEndOnExit]; // goi ham login khi bam nut enter
        
        usernameField.autocorrectionType = UITextAutocorrectionTypeNo;
        [usernameField setClearButtonMode:UITextFieldViewModeWhileEditing];
        cell.accessoryView = usernameField ;
    }
    if (indexPath.row == 1) {
        passwordField = [[UITextField alloc] initWithFrame:CGRectMake(5, 0, 230, 21)];
        
        passwordField.text=@"";
        passwordField.placeholder = @"Mật khẩu";
        [passwordField setDelegate:self];
        [passwordField setReturnKeyType:UIReturnKeyDone];
        [passwordField addTarget:self
                          action:@selector(loginSC:)
                forControlEvents:UIControlEventEditingDidEndOnExit];// goi ham login khi bam nut enter
        
        
        passwordField.secureTextEntry = YES;
        passwordField.autocorrectionType = UITextAutocorrectionTypeNo;
        [passwordField setClearButtonMode:UITextFieldViewModeWhileEditing];
        cell.accessoryView = passwordField;
    }
    //usernameField.delegate = self;
    //passwordField.delegate = self;
    
    
    [tableView_login addSubview:usernameField];
    [tableView_login addSubview:passwordField]; 
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;  
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 2;
}
- (void)setProgress:(NSString *) status {
}
/*- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return [self.viewController preferredInterfaceOrientationForPresentation];
}*/
- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    
    if ((interfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (interfaceOrientation == UIInterfaceOrientationLandscapeRight))
    { 
        isPortrait = FALSE;
//        background_image.frame = CGRectMake(0,0,[[UIScreen mainScreen] bounds].size.height,[[UIScreen mainScreen] bounds].size.width);
        // kiem tra xem ung dung dang chay tren thiet bi nao: ipad hay iPhone
        if(IS_IPAD()){ // neu thiet bi dang su dung la ipad
            [background_image setImage:[UIImage imageNamed: @"loginbackgroundipad_lan.png"]]; 
        }  
    }
    else { 
        isPortrait = TRUE;
        // kiem tra xem ung dung dang chay tren thiet bi nao: ipad hay iPhone
//        background_image.frame = CGRectMake(0,0,[[UIScreen mainScreen] bounds].size.width,[[UIScreen mainScreen] bounds].size.height);
        if(IS_IPAD()){ // neu thiet bi dang su dung la ipad
            [background_image setImage:[UIImage imageNamed: @"loginbackgroundipad.png"]];
        } 
    }
    if(IS_IPAD()) return YES;
    else return NO;
}
- (NSUInteger)supportedInterfaceOrientations{ 
    [self.viewController supportedInterfaceOrientations];
    return UIInterfaceOrientationMaskAll;
}
 
// Determine iOS 6 Autorotation.
- (BOOL)shouldAutorotate{
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    // Return yes to allow the device to load initially.
    if (orientation == UIDeviceOrientationUnknown) return YES;
    // Pass iOS 6 Request for orientation on to iOS 5 code. (backwards compatible)
    BOOL result = [self shouldAutorotateToInterfaceOrientation:orientation];
    [self.viewController shouldAutorotate];
    
    //[self.weekScheduleController shouldAutorotate];
    if(IS_IPAD()) return result;
    else return NO;
    //return YES;
}
//- (void)keyboardWillShow:(NSNotification *)notification {
//	scroll_view.contentSize = CGSizeMake(320.0, 548 + 200);
//}
//- (void)keyboardWillHide:(NSNotification *)notification {
//	scroll_view.contentSize = CGSizeMake(320.0, 420);
//}
@end
