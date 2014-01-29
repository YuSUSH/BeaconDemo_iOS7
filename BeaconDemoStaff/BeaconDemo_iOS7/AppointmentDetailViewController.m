//
//  AppointmentDetailViewController.m
//  BeaconDemo_iOS7
//
//  Created by Yu Liu on 21/01/14.
//
//

#import "AppointmentDetailViewController.h"
#import "BeaconDemoAppDelegate.h"

@interface AppointmentDetailViewController ()

@end

@implementation AppointmentDetailViewController
@synthesize appointmentInfo;

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
    self.busyIndicator.hidden=true;
	// Do any additional setup after loading the view.
    if(appointmentInfo!=nil)
    {
        self.labelClientName.text= [appointmentInfo valueForKey:@"client_fullname"];
        self.labelTime.text=[appointmentInfo valueForKey:@"time"];
        self.textDescription.text=[appointmentInfo valueForKey:@"description"];
        self.textDescription.editable=false;
        
        self.labelDepartment.text=[appointmentInfo valueForKey:@"department"];
        
        //set the client ID info
        NSString *clientIDstr;
        clientIDstr= [NSString stringWithFormat:@"Client ID:%@",
                        [appointmentInfo valueForKey:@"client"]];
        self.labelClientID.text=clientIDstr;
        
        //Load the image data
        NSString *iconfilename=[appointmentInfo valueForKey:@"iconfilename"];
        UIImage *img=[self loadIconImage:iconfilename];
        [self.personalImage setImage:img];
    }
}

-(UIImage*) loadIconImage:(NSString*)iconfilename
{
    //show picture
    NSString *picture_url= [NSString stringWithFormat:@"%@%@",
                            @"http://ble.sandbox.net.nz/myforum/upload_image/",
                            iconfilename ];
    
    NSURL *url = [NSURL URLWithString:picture_url];
    NSData *data = [NSData dataWithContentsOfURL:url];
    UIImage *img = [[UIImage alloc] initWithData:data];
    return img;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)OnClickBackButton:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:true];
}

- (IBAction)OnClickConfirmMeeting:(UIButton *)sender
{
    BUSY_INDICATOR_START(self.busyIndicator)
    
    NSURL *requestURL=[NSURL URLWithString:CONFIRM_APPOINTMENT_URL];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];
    
    NSString *appointment_id= [self.appointmentInfo valueForKey:@"id"];
    NSString *client_id= [self.appointmentInfo valueForKey:@"client"];
    
    //Set Post Data
    const char *bytes = [[NSString stringWithFormat:@"appointment=%@&client=%@",
                          appointment_id, client_id] UTF8String];
    //For multiple POST data
    //NSString *key = [NSString stringWithFormat:@"key=%@&key2=%2", keyValue, key2value];
    
    //Send request
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[NSData dataWithBytes:bytes length:strlen(bytes)]];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         BUSY_INDICATOR_STOP(self.busyIndicator)
         
         if(error!=nil)
             return; //error
         
         NSLog(@"responseData: %@", data);
         
         dispatch_async(dispatch_get_main_queue(), ^{
             SHOW_ALERT_WINDOW(@"Successful", @"A confirmation has been sent to the client.")
             
            [self.navigationController popViewControllerAnimated:true];
         });
         
     }];

}
@end
