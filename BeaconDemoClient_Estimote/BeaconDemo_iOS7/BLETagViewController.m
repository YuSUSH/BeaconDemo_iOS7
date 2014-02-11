//
//  BLETagViewController.m
//  BeaconDemo_iOS7
//
//  Created by Yu Liu on 14/10/13.
//
//

#import "BLETagViewController.h"
#import <UIKit/UIDevice.h>
#import "BeaconDemoAppDelegate.h"
#import "MeetingNotifyViewController.h"
#import "DepartmentTableCell.h"
#import "NewAppintmentViewController.h"

@interface BLETagViewController ()

@end

@implementation BLETagViewController
@synthesize peripherals;

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
    self.busyIndicator.hidden=true;
    
    //First of all update the client token for this iphone device
    GET_APPDELEGATE
    [self UpdateClientDeviceToken:appDelegate.currentToken
                     WithClientID:appDelegate.CurrentUserID];
    
    self.bInsideRange=false; //initially outside the Beacon range
    self.navigationItem.hidesBackButton=true; //disable the "back" button
    [self.navigationController setNavigationBarHidden: YES animated:NO]; //don't show the navigation bar
    
    //by default hide the make appointment button and shop label
    self.btnRequestHomeLoan.hidden=true;
    self.labelShopInfo.hidden=true;
    
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    //self.cm = [[CBCentralManager alloc]initWithDelegate:self queue:nil];
    //Use iBeacon API instead of BLE API
    [self createBeaconRegion];
    
    self.title=@"BLE device to iOS with Bluetooth Core API";
    
    peripherals=[[NSMutableArray alloc] init];
    [peripherals removeAllObjects];
    
    
    appDelegate.tv=self; //pass this pointer to the AppDelegate
    
    //Show Welcome message with the user's fullname
    NSString *fullname=[NSString stringWithFormat:@"Welcome, %@ %@!",
                        [appDelegate.CurrentPersonalInfo valueForKey:@"givename"],
                        [appDelegate.CurrentPersonalInfo valueForKey:@"surname"]];
    self.LabelDeviceInfo.text=fullname;
    
    
    
    //init the table view
    self.departmentTable.delegate=self;
    self.departmentTable.dataSource=self;

}


-(void) viewDidAppear:(BOOL)animated
{
    [self PlayRingtone];
}

-(NSString*) getCurrentDeviceID
{
    return [[UIDevice currentDevice] identifierForVendor].UUIDString;
}


-(void) UpdateClientDeviceToken:(NSString *)token WithClientID:(NSString*)userid
{
    
    NSURL *requestURL=[NSURL URLWithString:UPDATE_CLIENT_TOKEN_URL];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];
    
    //Set Post Data
    const char *bytes = [[NSString stringWithFormat:@"userid=%@&token=%@", userid, token] UTF8String];
    //For multiple POST data
    //NSString *key = [NSString stringWithFormat:@"key=%@&key2=%2", keyValue, key2value];
    
    //Send request
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[NSData dataWithBytes:bytes length:strlen(bytes)]];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         if(error!=nil)
             return; //error
         
         NSLog(@"responseData: %@", data);
         
     }];
}


-(void) ShowMeetingDueInfo:(NSString *)appointment_id
{
    //get the detailed info about the meeting
    NSURL *requestURL=[NSURL URLWithString:QUERY_APPOINTMENT_DETAIL_URL];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];
    
    //Set Post Data
    const char *bytes = [[NSString stringWithFormat:@"appointment_id=%@", appointment_id] UTF8String];
    //For multiple POST data
    //NSString *key = [NSString stringWithFormat:@"key=%@&key2=%2", keyValue, key2value];
    
    //Send request
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[NSData dataWithBytes:bytes length:strlen(bytes)]];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         if(error!=nil)
             return; //error
         
         NSLog(@"responseData: %@", data);
         
         //decode the response data
         NSMutableArray *jsonObjects = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
         
         if(jsonObjects==nil)
             return;
         
         NSMutableDictionary *appointment=[jsonObjects objectAtIndex:0];
         
         //Show Meeting info
         dispatch_queue_t mainQueue = dispatch_get_main_queue();
         dispatch_async(mainQueue, ^(void)
        {
            //Show the appointment detail window
             [self performSegueWithIdentifier:@"SegueToMeetingNotify" sender:appointment];
        });
         
     }];
}


-(void) ShowMeetingConfirmation:(NSString *)appointment_id
{
    //get the detailed info about the meeting
    NSURL *requestURL=[NSURL URLWithString:QUERY_APPOINTMENT_DETAIL_URL];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];
    
    //Set Post Data
    const char *bytes = [[NSString stringWithFormat:@"appointment_id=%@", appointment_id] UTF8String];
    //For multiple POST data
    //NSString *key = [NSString stringWithFormat:@"key=%@&key2=%2", keyValue, key2value];
    
    //Send request
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[NSData dataWithBytes:bytes length:strlen(bytes)]];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         if(error!=nil)
             return; //error
         
         NSLog(@"responseData: %@", data);
         
         //decode the response data
         NSMutableArray *jsonObjects = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
         
         if(jsonObjects==nil)
             return;
         
         NSMutableDictionary *appointment=[jsonObjects objectAtIndex:0];
         
         //Show Meeting info
         dispatch_queue_t mainQueue = dispatch_get_main_queue();
         dispatch_async(mainQueue, ^(void)
        {
            //Show the appointment detail window
            NSString *time=[appointment valueForKey:@"time"];
            NSString *department=[appointment valueForKey:@"department"];
            
            NSString *showStr=[NSString stringWithFormat:@"Our staff from %@ department has confirmed the appointment with you at %@.", department, time];
            
            SHOW_ALERT_WINDOW(@"Appointment Confirmation", showStr)
        });
         
     }];
}


- (IBAction)OnClickRequestHomeloan:(UIButton *)sender
{
    [self requestHomeloan];
}


-(void) NewClientArrive
{
    
    NSURL *requestURL=[NSURL URLWithString:CLIENT_ARRIVE_URL];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];
    
    //Set Post Data
    GET_APPDELEGATE
    const char *bytes = [[NSString stringWithFormat:@"userid=%@", appDelegate.CurrentUserID] UTF8String];
    //For multiple POST data
    //NSString *key = [NSString stringWithFormat:@"key=%@&key2=%2", keyValue, key2value];
    
    //Send request
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[NSData dataWithBytes:bytes length:strlen(bytes)]];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
    {
        if(error!=nil)
            return; //error
        
        NSLog(@"responseData: %@", data);
        
        //decode the response data
        NSMutableArray *jsonObjects = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        
        NSMutableDictionary *dataDict=[jsonObjects objectAtIndex:0];
        NSString *result = [dataDict objectForKey:@"result"];
        NSString *shop_info=[dataDict objectForKey:@"shop_info"];
        
        
        if([result isEqualToString:@"add_new"]) //if being asked to create new appointment
        {
            //Show shop info and make appointment button
            dispatch_queue_t mainQueue = dispatch_get_main_queue();
            dispatch_async(mainQueue, ^(void)
            {
                self.labelShopInfo.hidden=false;
                self.labelShopInfo.text=shop_info;
                self.btnRequestHomeLoan.hidden=false;
                
                
                //If in backgournd mode
                UIApplicationState state = [[UIApplication sharedApplication] applicationState];
                if (state == UIApplicationStateBackground || state == UIApplicationStateInactive)
                {
                    //notify iOS that we've detected a device
                    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
                    localNotification.alertBody = @"Welcome to Kiwi bank!";
                    localNotification.soundName = @"ringtone.mp3";
                    localNotification.fireDate = [NSDate date];
                
                    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
                }
                
                SHOW_ALERT_WINDOW(@"Welcome", @"Welcome to Kiwi Bank!")
                

            });
        }
    }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==0)
    {
        //Make new appointment
        [self performSegueWithIdentifier:@"SegueNewAppointment" sender:self];
    }
}
-(void) ClientExit //The client exit this shop
{
    
    NSURL *requestURL=[NSURL URLWithString:CLIENT_LEFT_URL];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];
    
    
    //Hide the shop info and appointment making button
    self.labelShopInfo.hidden=true;
    self.btnRequestHomeLoan.hidden=true;
    
    //Show good bye message
    UIAlertView *helloWorldAlert = [[UIAlertView alloc]
                                    initWithTitle:@"Good Bye!" message:@"See you next time." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    // Display the Hello WorldMessage
    [helloWorldAlert show];


    
    //Set Post Data
    GET_APPDELEGATE
    const char *bytes = [[NSString stringWithFormat:@"userid=%@", appDelegate.CurrentUserID] UTF8String];
    //For multiple POST data
    //NSString *key = [NSString stringWithFormat:@"key=%@&key2=%2", keyValue, key2value];
    
    //Send request
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[NSData dataWithBytes:bytes length:strlen(bytes)]];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         if(error!=nil)
             return; //error
         
         NSLog(@"responseData: %@", data);
         /*
         //decode the response data
         NSMutableArray *jsonObjects = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
         
         NSMutableDictionary *dataDict=[jsonObjects objectAtIndex:0];
         NSString *result = [dataDict objectForKey:@"result"];
         
         if([result isEqualToString:@"add_new"]) //if being asked to create new appointment
         {
             //try to add new appointment
             dispatch_queue_t mainQueue = dispatch_get_main_queue();
             dispatch_async(mainQueue, ^(void)
                            {
                                [self performSegueWithIdentifier:@"SegueNewAppointment" sender:self];
                            });
         }
          */
     }];
}

- (IBAction)OnBLESwitchChange:(UISwitch *)sender
{
    /*
    if([sender isOn])
    {
        NSLog(@"//////////Start to Scan");
        NSDictionary *options = @{CBCentralManagerScanOptionAllowDuplicatesKey: @NO};
        [self.cm scanForPeripheralsWithServices:nil options:options];
        GET_APPDELEGATE
        appDelegate.bEnableBLE=true;
    }
    else
    {
        NSLog(@"////////Stop scanning");
        [self.cm stopScan];
        GET_APPDELEGATE
        appDelegate.bEnableBLE=false;
    }
     */
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"segue=%@, sender=%@.", segue.identifier, sender);
    
    if([segue.identifier isEqualToString:@"SegueToMeetingNotify"])
    {
        MeetingNotifyViewController *vc= segue.destinationViewController;
        vc.appointmentDetail=sender;
    }
    
    if([segue.identifier isEqualToString:@"SegueNewAppointment"])
    {
        NewAppintmentViewController *vc=segue.destinationViewController;
        vc.department=sender;
    }
}

//Bluetooth related implementations

-(void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if (central.state != CBCentralManagerStatePoweredOn)
    {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"BLE not supported !" message:[NSString stringWithFormat:@"CoreBluetooth return state: %d",central.state] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
    else
    {
        NSDictionary *options = @{CBCentralManagerScanOptionAllowDuplicatesKey: @NO};
        [central scanForPeripheralsWithServices:nil options:options];
    }
}

///////////////////////////////////////////////////////////////////////////////
-(void)ShowAlertDialog:(NSString *)msg
{
    [super PlayRingtone];
    //show the dialog box
    UIAlertView *helloWorldAlert = [[UIAlertView alloc]
                                    initWithTitle:@"Sush Mobile" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    // Display the Hello WorldMessage
    [helloWorldAlert show];
}

//////////////////////////////////////////////////////////////////////////////
-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    [peripheral discoverServices:nil];
}




-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    
    NSLog(@"Found a BLE Device : %@",peripheral);
    
    /* iOS 6.0 bug workaround : connect to device before displaying UUID !
     The reason for this is that the CFUUID .UUID property of CBPeripheral
     here is null the first time an unkown (never connected before in any app)
     peripheral is connected. So therefore we connect to all peripherals we find.
     */
    
    //Yu Liu Added
    //convert into string
    NSString *UUIDstr = peripheral.identifier.UUIDString;
    float fRSSI=[RSSI floatValue];
    float overall_RSSI=-9000.0f;
    static float last_RSSI=-9000.0f;

    
    NSLog(@"device UUID=: %@, advertisementData=%@ RSSI=%f", UUIDstr, advertisementData, fRSSI);
    
    NSArray *services=[advertisementData objectForKey:@"kCBAdvDataServiceUUIDs"];
    

    //If containing our sevice ID
    if( [services containsObject:[CBUUID UUIDWithString:IPAD3_SERVICE_ID]])
    {
        [self NewClientArrive]; //notify the server side that we found the iPad
    }
}


/////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////


- (IBAction)OnClickLogout:(UIButton *)sender
{
    //simply going back
    [self.navigationController popViewControllerAnimated:YES];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)createBeaconRegion
{
    if (self.beaconRegion)
        return;
    
    /////////////////////////////////////////////////////////////
    // setup Estimote beacon manager
    
    // craete manager instance
    self.beaconManager = [[ESTBeaconManager alloc] init];
    self.beaconManager.delegate = self;
    self.beaconManager.avoidUnknownStateBeacons = YES;
    
    // create sample region with major value defined
    ESTBeaconRegion* region = [[ESTBeaconRegion alloc] initWithProximityUUID:ESTIMOTE_PROXIMITY_UUID
                                                                       major:BLUE_ESTIMOTE_BEACON_MAJOR minor:BLUE_ESTIMOTE_BEACON_MINOR
                                                                  identifier: kIdentifier];
    
    
    // start looking for estimote beacons in region
    // when beacon ranged beaconManager:didEnterRegion:
    // and beaconManager:didExitRegion: invoked
    [self.beaconManager startMonitoringForRegion:region];
    
    [self.beaconManager requestStateForRegion:region];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////




-(void)beaconManager:(ESTBeaconManager *)manager
      didEnterRegion:(ESTBeaconRegion *)region
{
    //if(self.bInsideRange) //if already inside the range
    //    return; //do nothing
    
    if([region.identifier isEqualToString:kIdentifier])
    {
        self.bInsideRange=true;
        [self NewClientArrive]; //notify the server side that we found the iPad
    }
    
}

-(void)beaconManager:(ESTBeaconManager *)manager
       didExitRegion:(ESTBeaconRegion *)region
{
    //if(!self.bInsideRange) //if already outside the range
    //    return; //do nothing
       
    if([region.identifier isEqualToString:kIdentifier])
    {
        self.bInsideRange=false;
        
        [self ClientExit]; //send push notification for exiting the shop
    }

    
}


-(void)beaconManager:(ESTBeaconManager *)manager
   didDetermineState:(CLRegionState)state
           forRegion:(ESTBeaconRegion *)region
{
    if(state == CLRegionStateInside)
    {
        NSLog(@"/////DetermineState INSIDE for %@", region.identifier);
        //[self NewClientArrive]; //notify the server side that we found the iPad
    }
    else if(state == CLRegionStateOutside) {
        NSLog(@"////DetermineState OUTSIDE for %@", region.identifier);
        //[self ClientExit]; //send push notification for exiting the shop
    }
    else {
        NSLog(@"locationManager didDetermineState OTHER for %@", region.identifier);
    }
}

- (IBAction)OnClickMakeAppointment:(UIButton *)sender
{
    //Make new appointment
    [self performSegueWithIdentifier:@"SegueNewAppointment" sender:self];
}


-(void) requestHomeloan
{
    BUSY_INDICATOR_START(self.busyIndicator)
    NSURL *requestURL=[NSURL URLWithString:REQUEST_HOMELOAN_URL];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];
    
    //Set Post Data
    GET_APPDELEGATE
    const char *bytes = [[NSString stringWithFormat:@"client=%@", appDelegate.CurrentUserID] UTF8String];
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
         
         //decode the response data
         NSMutableArray *jsonObjects = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
         
         NSMutableDictionary *dataDict=[jsonObjects objectAtIndex:0];
         NSString *result = [dataDict objectForKey:@"result"];
         
         
         if([result isEqualToString:@"OK"]) //if being asked to create new appointment
         {
             //Show shop info and make appointment button
             dispatch_queue_t mainQueue = dispatch_get_main_queue();
             dispatch_async(mainQueue, ^(void)
            {
                UIAlertView *helloWorldAlert = [[UIAlertView alloc]
                                                initWithTitle:@"Complete" message:@"Request has been sent. We will serve you soon." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                // Display the Hello WorldMessage
                [helloWorldAlert show];
                
                //[self performSegueWithIdentifier:@"SegueNewAppointment" sender:self];
            });
         }
     }];

}

///////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

#define HOME_LOAN_DEPARTMENT 0
#define STUDENT_LOAN_DEPARTMENT 1
#define INSURANCE_DEPARTMENT 2
#define CREDIT_DEPARTMENT 3
#define KIWI_SAVER_DEPARTMENT 4

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"Cell";
    DepartmentTableCell *cell = (DepartmentTableCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil)
    {
        cell = [[DepartmentTableCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    
    switch(indexPath.row)
    {
        case HOME_LOAN_DEPARTMENT:
            cell.textLabel.text=@"Home Loans";
            break;
        case STUDENT_LOAN_DEPARTMENT:
            cell.textLabel.text=@"Student Loans";
            break;
        case INSURANCE_DEPARTMENT:
            cell.textLabel.text=@"Insurance";
            break;
        case CREDIT_DEPARTMENT:
            cell.textLabel.text=@"Credit";
            break;
        case KIWI_SAVER_DEPARTMENT:
            cell.textLabel.text=@"Kiwi Saver";
            break;
    }
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row < 5)
    {
        NSString *department=@"";
        switch(indexPath.row)
        {
            case HOME_LOAN_DEPARTMENT:
                department=@"Home Loans";
                break;
            case STUDENT_LOAN_DEPARTMENT:
                department=@"Student Loans";
                break;
            case INSURANCE_DEPARTMENT:
                department=@"Insurance";
                break;
            case CREDIT_DEPARTMENT:
                department=@"Credit";
                break;
            case KIWI_SAVER_DEPARTMENT:
                department=@"Kiwi Saver";
                break;
        }
        
        [self performSegueWithIdentifier:@"SegueNewAppointment" sender:department];
    }
}


@end
