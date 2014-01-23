//
//  ClientInfoViewController.m
//  BeaconDemo_iOS7
//
//  Created by Yu Liu on 24/01/14.
//
//

#import "ClientInfoViewController.h"
#import "BeaconDemoAppDelegate.h"

@interface ClientInfoViewController ()

@end

@implementation ClientInfoViewController

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
    GET_APPDELEGATE
    appDelegate.clientInfoView=self;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
