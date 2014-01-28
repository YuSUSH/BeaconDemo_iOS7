//
//  AppointmentDetailViewController.m
//  BeaconDemo_iOS7
//
//  Created by Yu Liu on 21/01/14.
//
//

#import "AppointmentDetailViewController.h"

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
	// Do any additional setup after loading the view.
    if(appointmentInfo!=nil)
    {
        self.labelClientName.text= [appointmentInfo valueForKey:@"client_fullname"];
        self.labelTime.text=[appointmentInfo valueForKey:@"time"];
        self.labelDescription.text=[appointmentInfo valueForKey:@"description"];
        
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
@end
