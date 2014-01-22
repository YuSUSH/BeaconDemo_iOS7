//
//  MeetingNotifyViewController.m
//  BeaconDemo_iOS7
//
//  Created by Yu Liu on 22/01/14.
//
//

#import "MeetingNotifyViewController.h"

@interface MeetingNotifyViewController ()

@end

@implementation MeetingNotifyViewController
@synthesize appointmentDetail;

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
    NSString *clientName=[appointmentDetail valueForKey:@"client_fullname"];
    NSString *time=[appointmentDetail valueForKey:@"time"];
    NSString *description=[appointmentDetail valueForKey:@"description"];
    
    self.labelTitle.text=[NSString  stringWithFormat:@"The appointment with %@ will be due at:",
                          clientName];
    self.labelTime.text=time;
    self.labelDescription.text=description;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
