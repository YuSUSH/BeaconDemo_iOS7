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
    self.navigationItem.hidesBackButton=true; //disable the "back" button
    
    NSString *staffName=[appointmentDetail valueForKey:@"staff_fullname"];
    NSString *time=[appointmentDetail valueForKey:@"time"];
    NSString *description=[appointmentDetail valueForKey:@"description"];
    NSString *department=[appointmentDetail valueForKey:@"department"];
    
    self.labelTitle.text=[NSString  stringWithFormat:@"The appointment with %@ will be due at:",
                     staffName];
    self.labelTime.text=time;
    
    self.labelDepartment.text=department;
    self.textDescription.text=description;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)OnClockClose:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:true];
}
@end
