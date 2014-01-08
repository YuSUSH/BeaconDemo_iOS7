//
//  UserLoginViewController.m
//  BeaconDemo_iOS7
//
//  Created by Yu Liu on 8/01/14.
//
//

#import "UserLoginViewController.h"
#import "BeaconDemoAppDelegate.h"

@interface UserLoginViewController ()

@end

@implementation UserLoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#define SAVE_FILE_NAME @"kkk.txt"

bool Auto_login;

- (void)viewDidLoad
{
    Auto_login=false;
    
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.useridText.delegate=self;
    self.passwordText.delegate=self;
    
    //Try to read out the user info stored in the file
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:SAVE_FILE_NAME];
    
    NSMutableDictionary *account;
    account=[NSMutableDictionary dictionaryWithContentsOfFile:filePath];
    if(account!=nil)
    {
        NSString *userid=[account valueForKey:@"userid"];
        NSString *password=[account valueForKey:@"password"];
        if(userid!=nil)
        {
            if(userid.length>0)
            {
                //Validate the account
                Auto_login=true;
                [self SetBusyState];
                [self ValidateLoginAccount:userid AndPassword:password];
            }
        }
    }
}

-(void) viewWillAppear:(BOOL)animated
{
    if(!Auto_login)
    {
        [self SetNormalState];
        [self SaveAccountInfo:nil]; //don't save any account info
    }
}

-(void) SetNormalState
{
    [self.titileLabel setText:@"Login Window"];
    self.useridText.enabled=true;
    self.passwordText.enabled=true;
}

-(void) SetBusyState
{
    [self.titileLabel setText:@"Loggin in ..."];
    self.useridText.enabled=false;
    self.passwordText.enabled=false;
}


-(void) SaveAccountInfo:(NSDictionary*)personalInfo
{
    NSMutableDictionary *account;
    account=[[NSMutableDictionary alloc] init];
    //create the account object based on PersonalInfo
    NSString *userid, *password;
    userid=[personalInfo valueForKey:@"userid"];
    password=[personalInfo valueForKey:@"password"];
    [account setValue:userid forKey:@"userid"];
    [account setValue:password forKey:@"password"];
    
    //Save into file
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:SAVE_FILE_NAME];
    
    [account writeToFile:filePath atomically:YES];
}


- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.view.frame  =CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y-90,
                                 self.view.frame.size.width, self.view.frame.size.height);
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.view.frame  =CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y+90,
                                 self.view.frame.size.width, self.view.frame.size.height);
     [textField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)OnClickedLoginButton:(UIButton *)sender
{
    [self ValidateLoginAccount: self.useridText.text AndPassword:self.passwordText.text];
}

-(void) ValidateLoginAccount:(NSString*)userid AndPassword:(NSString *)password
{
    
    NSURL *requestURL=[NSURL URLWithString:QUERY_LOGIN_URL];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];
    
    //Set Post Data
    const char *bytes = [[NSString stringWithFormat:@"userid=%@&password=%@", userid, password] UTF8String];
    //For multiple POST data
    //NSString *key = [NSString stringWithFormat:@"key=%@&key2=%2", keyValue, key2value];
    
    //Send request
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[NSData dataWithBytes:bytes length:strlen(bytes)]];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         Auto_login=false; //Auto Login state ends here
         
         NSLog(@"responseData: %@", data);
         
         //decode the response data
         NSMutableArray *jsonObjects = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
         
        NSMutableDictionary *dataDict=[jsonObjects objectAtIndex:0];
        NSString *result = [dataDict objectForKey:@"result"];
        if(result!=nil)
        {
            if([result isEqualToString:@"OK"])
            {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    //Save the current userid and personal info
                    GET_APPDELEGATE
                    appDelegate.CurrentUserID = self.useridText.text;
                    appDelegate.CurrentPersonalInfo=dataDict;
                    
                    //Save this account info into local file
                    [self SaveAccountInfo:appDelegate.CurrentPersonalInfo];
                    
                    //Switch to next ViewController
                    [self performSegueWithIdentifier:@"SegueToBLEClient" sender:self]; //transfer to Client View
                });
                return;
            }
        }
         
         dispatch_async(dispatch_get_main_queue(), ^{
             UIAlertView *helloWorldAlert = [[UIAlertView alloc]
                                             initWithTitle:@"Error" message:@"User ID or Password Error!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
             // Display the Hello WorldMessage
             [helloWorldAlert show];
         });


     }];
    
    
}
@end
