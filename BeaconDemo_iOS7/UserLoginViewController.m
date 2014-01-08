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

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.useridText.delegate=self;
    self.passwordText.delegate=self;
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
    [self ValidateLoginAccount];
}

-(void) ValidateLoginAccount
{
    
    NSURL *requestURL=[NSURL URLWithString:QUERY_LOGIN_URL];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];
    
    //Set Post Data
    const char *bytes = [[NSString stringWithFormat:@"userid=%@&password=%@", self.useridText.text, self.passwordText.text] UTF8String];
    //For multiple POST data
    //NSString *key = [NSString stringWithFormat:@"key=%@&key2=%2", keyValue, key2value];
    
    //Send request
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[NSData dataWithBytes:bytes length:strlen(bytes)]];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
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
