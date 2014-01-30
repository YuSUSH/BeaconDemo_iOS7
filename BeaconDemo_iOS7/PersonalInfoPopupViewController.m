//
//  PersonalInfoPopupViewController.m
//  BeaconDemo_iOS7
//
//  Created by Yu Liu on 7/01/14.
//
//

#import "PersonalInfoPopupViewController.h"

@interface PersonalInfoPopupViewController ()

@end

@implementation PersonalInfoPopupViewController
@synthesize personalInfo, m_PopoverController;

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
    // Do any additional setup after loading the view from its nib.
    

}

-(void) viewWillAppear:(BOOL)animated
{
    //set the text with personal info passed by other class
    NSString *fullname= [NSString stringWithFormat:@"%@ %@", [personalInfo valueForKey:@"givename"],
                         [personalInfo valueForKey:@"surname"]];
    [self.personalInfoLabel setText:fullname];
    
    NSString *clientIDstr;
    clientIDstr=[NSString stringWithFormat:@"Client ID: %@", [personalInfo valueForKey:@"userid"]];
    self.labelClientID.text=clientIDstr;
    
    [self PlayRingtone];
    
}

-(void) viewDidAppear:(BOOL)animated
{
    //show picture
    NSString *picture_url= [NSString stringWithFormat:@"%@%@",
    @"http://ble.sandbox.net.nz/myforum/upload_image/",
    [personalInfo valueForKey:@"iconfilename"] ];
    
    NSURL *url = [NSURL URLWithString:picture_url];
    NSData *data = [NSData dataWithContentsOfURL:url];
    UIImage *img = [[UIImage alloc] initWithData:data];
    CGSize size = img.size;
    [self.imageViewPhoto setImage:img];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)OnClickCloseButton:(UIButton *)sender
{
    if(self.mainView!=nil)
    {
        [self.mainView popoverControllerDidDismissPopover:nil];
    }
    
}
@end
