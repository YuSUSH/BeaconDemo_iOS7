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
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
