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
    
    self.bInsideRangeNow=false; //initially outside the Beacon range
    self.bInSideRangeLastNotified=false; //initially outside the Beacon range
    self.timestampLastNotified=[self getCurrentTimestamp]; //init the timestamp
    //Init the check reminder notify timer
    self.checkRemindNotifyTimer=[[NSTimer alloc] init];
    self.checkRemindNotifyTimer=[NSTimer scheduledTimerWithTimeInterval:5.0 target:self                selector:@selector(CheckToRemindNotify:) userInfo:nil repeats:YES];
    
    self.navigationItem.hidesBackButton=true; //disable the "back" button
    [self.navigationController setNavigationBarHidden: YES animated:NO]; //don't show the navigation bar
    
    //by default hide the make appointment button and shop label
    self.btnRequestHomeLoan.hidden=true;
    self.labelShopInfo.hidden=true;
    
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    //self.cm = [[CBCentralManager alloc]initWithDelegate:self queue:nil];
    //Use iBeacon API instead of BLE API
    [self startRangingForBeacons];
    
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
//////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void) peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    BOOL replace = NO;
    BOOL found = NO;
    NSLog(@"///////////////////////////////Services scanned !");
    [self.cm cancelPeripheralConnection:peripheral];
    for (CBService *s in peripheral.services)
    {
        
        NSLog(@"Service found : %@",s.UUID);
        if ([s.UUID isEqual:[CBUUID UUIDWithString:@"f000aa00-0451-4000-b000-000000000000"]])  {
            NSLog(@"This is a SensorTag !");
            found = YES;
        }
    }
}

/////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)startRangingForBeacons
{
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.activityType = CLActivityTypeFitness;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [self turnOnRanging];
}

- (IBAction)OnClickLogout:(UIButton *)sender
{
    //simply going back
    [self.navigationController popViewControllerAnimated:YES];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)turnOnRanging
{
    NSLog(@"Turning on ranging...");
    
    if (![CLLocationManager isRangingAvailable]) {
        NSLog(@"Couldn't turn on ranging: Ranging is not available.");
        //self.TRSwitch.on = NO;
        return;
    }
    
    if (self.locationManager.rangedRegions.count > 0) {
        NSLog(@"Didn't turn on ranging: Ranging already on.");
        return;
    }
    
    [self createBeaconRegion];
    [self.locationManager startMonitoringForRegion:self.beaconRegion];
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
    
    self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    self.locationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters;
    self.locationManager.delegate = self;
    [self.locationManager startMonitoringSignificantLocationChanges];
    [self.locationManager startUpdatingLocation];
    
    NSLog(@"Ranging turned on for region: %@.", self.beaconRegion);
    
}
//////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)createBeaconRegion
{
    if (self.beaconRegion)
        return;
    
    NSUUID *proximityUUID = [[NSUUID alloc] initWithUUIDString:kUUID];
    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:proximityUUID identifier:kIdentifier];
    self.beaconRegion.notifyEntryStateOnDisplay=NO;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)locationManager:(CLLocationManager *)manager
        didRangeBeacons:(NSArray *)beacons
               inRegion:(CLBeaconRegion *)region
{
    for(CLBeacon *beacon in beacons)
    {
        if([beacon.proximityUUID.UUIDString isEqual: kUUID]) //if it's our beacon device
        {
            //NSLog(@"///////////////Found it!");
        }
    }
}




- (void)locationManager:(CLLocationManager *)manager
         didEnterRegion:(CLRegion *)region
{
    if(self.bInSideRangeLastNotified) //if already inside the range
        return; //do nothing
    
    if([region.identifier isEqualToString:kIdentifier])
    {
        //update status
        self.bInsideRangeNow=true;
        
        long long currentTimestamp=[self getCurrentTimestamp];
        
        NSLog(@"currentTimestamp - self.timestampLastNotified=%d", (int)(currentTimestamp - self.timestampLastNotified));
        if((int)(currentTimestamp - self.timestampLastNotified) > 50000) //more than 5 seconds since last notified
        {
            //update status
            self.bInSideRangeLastNotified=true;
            self.timestampLastNotified=currentTimestamp;
            
            [self NewClientArrive]; //notify the server side that we found the iPad
        }
    }
    
}

-(long long) getCurrentTimestamp
{
    return (long long)([[NSDate date] timeIntervalSince1970] * 1000.0);
}

- (void)locationManager:(CLLocationManager *)manager
          didExitRegion:(CLRegion *)region
{
    if(!self.bInSideRangeLastNotified) //if already outside the range
        return; //do nothing
       
    if([region.identifier isEqualToString:kIdentifier])
    {
        //update status
        self.bInsideRangeNow=false;
        
        long long currentTimestamp=[self getCurrentTimestamp];
        
        NSLog(@"currentTimestamp - self.timestampLastNotified=%d", (int)(currentTimestamp - self.timestampLastNotified));
        if((int)(currentTimestamp - self.timestampLastNotified) > 5000) //more than 5 seconds since last notified
        {
            
            //update status
            self.bInSideRangeLastNotified=false;
            self.timestampLastNotified=currentTimestamp;
        
            [self ClientExit]; //send push notification for exiting the shop
        }
    }
}

//To see if we need to notify that we have entered the region or gone out of the region
-(void) CheckToRemindNotify:(NSTimer*)pTimer
{
    //if current status is different from that notified last time
    if(self.bInsideRangeNow != self.bInSideRangeLastNotified )
    {
        long long currentTimestamp=[self getCurrentTimestamp];
        
        if(self.bInsideRangeNow)
        {
            self.bInSideRangeLastNotified=true; //update it
            self.timestampLastNotified=currentTimestamp;
            [self NewClientArrive]; //notify come in
        }
        else
        {
            self.bInSideRangeLastNotified=false; //update it
            self.timestampLastNotified=currentTimestamp;
            [self ClientExit]; //notify go out
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    if([region.identifier isEqualToString:kIdentifier])
    {
        if(state == CLRegionStateInside)
        {
            self.bInsideRangeNow=true; //update current status
            NSLog(@"locationManager didDetermineState INSIDE for %@", region.identifier);
        }
        else if(state == CLRegionStateOutside)
        {
            self.bInsideRangeNow=false; //update current status
            NSLog(@"locationManager didDetermineState OUTSIDE for %@", region.identifier);
        }
        else {
            NSLog(@"locationManager didDetermineState OTHER for %@", region.identifier);
        }
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
