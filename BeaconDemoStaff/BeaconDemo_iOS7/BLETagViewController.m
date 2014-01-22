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
#import "AppointmentDetailViewController.h"
#import "MeetingNotifyViewController.h"

@interface BLETagViewController ()

@end

@implementation BLETagViewController
@synthesize peripherals, appointmentTableView, myAppointments;

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
    
    //self.cm = [[CBCentralManager alloc]initWithDelegate:self queue:nil];
    //Use iBeacon API instead of BLE API
    //[self startRangingForBeacons];
    
    //First of all update the staff token for this iphone device
    GET_APPDELEGATE
    [self UpdateStaffDeviceToken:appDelegate.CurrentTokenStr
                     WithStaffID:appDelegate.CurrentStaffID];
    
    self.title=@"BLE device to iOS with Bluetooth Core API";
    
    //peripherals=[[NSMutableArray alloc] init];
    //[peripherals removeAllObjects];
    
    
    appDelegate.tv=self; //pass this pointer to the AppDelegate
    
    //Show Welcome message with the user's fullname
    NSString *fullname=[NSString stringWithFormat:@"Welcome, %@ %@!",
                        [appDelegate.CurrentStaffInfo valueForKey:@"givename"],
                        [appDelegate.CurrentStaffInfo valueForKey:@"surname"]];
    self.LabelDeviceInfo.text=fullname;
    

    appointmentTableView.delegate=self;
    appointmentTableView.dataSource=self;
    
    [self FetchAllofMyAppointments:appDelegate.CurrentStaffID]; //get all the appointments at the moment
    
    
    self.navigationItem.hidesBackButton=true; //disable the back button
    
    

}


-(void) UpdateStaffDeviceToken:(NSString *)token WithStaffID:(NSString*)userid
{
    
    NSURL *requestURL=[NSURL URLWithString:UPDATE_STAFF_TOKEN_URL];
    
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


-(void) viewDidAppear:(BOOL)animated
{
    [self PlayRingtone];
}

-(NSString*) getCurrentDeviceID
{
    return [[UIDevice currentDevice] identifierForVendor].UUIDString;
}

NSMutableData *receivedData;
-(void) NotifyPushNotificationServer
{
    NSString* deviceID= [self getCurrentDeviceID];
    NSLog(@"////////This device ID=%@", deviceID);
    
    receivedData=[[NSMutableData alloc] init];
    NSString *requestURL=[NSString stringWithFormat:@"http://experiment.sandbox.net.nz/beacon/simplepush.php?deviceid=%@", deviceID];
    NSURLRequest *theRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:requestURL]];
    
    NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:theRequest  delegate:self];
    
}

-(void) NewClientArrive
{
    
    NSURL *requestURL=[NSURL URLWithString:CLIENT_ARRIVE_URL];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];
    
    //Set Post Data
    GET_APPDELEGATE
    const char *bytes = [[NSString stringWithFormat:@"userid=%@", appDelegate.CurrentStaffID] UTF8String];
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
        
        if([result isEqualToString:@"add_new"]) //if being asked to create new appointment
        {
            //try to add new appointment
            dispatch_queue_t mainQueue = dispatch_get_main_queue();
            dispatch_async(mainQueue, ^(void)
            {
                [self performSegueWithIdentifier:@"SegueNewAppointment" sender:self];
            });
        }
    }];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    
    if (receivedData) {
        
        NSMutableArray *jsonObjects = [NSJSONSerialization JSONObjectWithData:receivedData options:NSJSONReadingMutableContainers error:nil];
        
        int i;
        for (i=0; i<[jsonObjects count];i++)
        {
            NSMutableDictionary *dataDict=[jsonObjects objectAtIndex:i];
            NSString *ID = [dataDict objectForKey:@"ID"];
            NSString *Name = [dataDict objectForKey:@"Name"];
            NSString *Type = [dataDict objectForKey:@"Type"];
            NSLog(@"//////////////// ID=%@", ID);
            NSLog(@"//////////////// Name=%@", Name);
            NSLog(@"//////////////// Type=%@", Type);
            
        }
        
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
    
    if([segue.identifier isEqualToString:@"SegueToAppointmentDetail"])
    {
        AppointmentDetailViewController *myVC = [segue destinationViewController];
        myVC.appointmentInfo = sender;// set your properties here
    }
    
    if([segue.identifier isEqualToString:@"SegueToMeetingNotify"])
    {
        MeetingNotifyViewController *vc= segue.destinationViewController;
        vc.appointmentDetail=sender;
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
    
    NSLog(@"Ranging turned on for region: %@.", self.beaconRegion);
    
}
//////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)createBeaconRegion
{
    if (self.beaconRegion)
        return;
    
    NSUUID *proximityUUID = [[NSUUID alloc] initWithUUIDString:kUUID];
    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:proximityUUID identifier:kIdentifier];
    self.beaconRegion.notifyEntryStateOnDisplay=YES;
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
    if([region.identifier isEqualToString:kIdentifier])
    {
        /*
        NSLog(@"$$$$$$$$$$ I came in!");
        
        UIAlertView *helloWorldAlert = [[UIAlertView alloc]
                                        initWithTitle:@"My First App" message:@"I came in!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        // Display the Hello WorldMessage
        [helloWorldAlert show];
         */
        [self NewClientArrive]; //notify the server side that we found the iPad
    }
    
}

- (void)locationManager:(CLLocationManager *)manager
          didExitRegion:(CLRegion *)region
{
    if([region.identifier isEqualToString:kIdentifier])
    {
        /*
        NSLog(@"$$$$$$$$$$ I went out!");
        
        UIAlertView *helloWorldAlert = [[UIAlertView alloc]
                                        initWithTitle:@"My First App" message:@"I went out!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        // Display the Hello WorldMessage
        [helloWorldAlert show];
         */
    }

    
}

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    if(state == CLRegionStateInside) {
        NSLog(@"locationManager didDetermineState INSIDE for %@", region.identifier);
    }
    else if(state == CLRegionStateOutside) {
        NSLog(@"locationManager didDetermineState OUTSIDE for %@", region.identifier);
    }
    else {
        NSLog(@"locationManager didDetermineState OTHER for %@", region.identifier);
    }
}


- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row < myAppointments.count)
    {
        NSMutableDictionary *this_appointment;
        this_appointment=[myAppointments objectAtIndex:indexPath.row];
        [self performSegueWithIdentifier:@"SegueToAppointmentDetail" sender:this_appointment];
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    
    
    [cell.textLabel setFont:[UIFont systemFontOfSize:18]];
    [cell.textLabel setTextColor:[UIColor blackColor]];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
#define LENGTH_NAME_IN_TABLE 15
    NSString *titilestr;
    
    NSString *showFullName;
    NSMutableDictionary *appointment=[myAppointments objectAtIndex:indexPath.row];
    
    showFullName= [appointment valueForKey:@"client_fullname"];
/*
    int fullname_len=showFullName.length;
    showFullName=[showFullName substringToIndex:LENGTH_NAME_IN_TABLE];
    if(fullname_len>LENGTH_NAME_IN_TABLE)
        showFullName=[showFullName stringByAppendingString:@"..."];
 */
    
    NSString *showTime;
    showTime=[appointment valueForKey:@"time"];
//    showTime=[showTime substringFromIndex:5];
    
//    titilestr=[NSString stringWithFormat:@"%18@ %@",
//               showFullName,
//               showTime];

    [cell.textLabel setText:showFullName];
    [cell.detailTextLabel setText:showTime];

    
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(myAppointments!=nil && myAppointments.count>0)
        return myAppointments.count;
    else
        return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}



-(void) FetchAllofMyAppointments:(NSString *)staffid
{
        
    NSURL *requestURL=[NSURL URLWithString:QUERY_STAFFS_APPOINTMENTS_URL];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];
    
    //Set Post Data
    const char *bytes = [[NSString stringWithFormat:@"userid=%@", staffid] UTF8String];
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
         
         //NSMutableDictionary *dataDict=[jsonObjects objectAtIndex:0];
         //NSString *result = [dataDict objectForKey:@"result"];
         
         if(jsonObjects.count>0)
         {
             dispatch_async(dispatch_get_main_queue(), ^{
                 myAppointments=jsonObjects; //pass the appointment info
                 [appointmentTableView reloadData];
             });
         }
     }];
}

- (IBAction)OnClickLogout:(UIButton *)sender
{
    //pop to previous layer
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)showNewAppointment:(NSString *)appointment_id
{
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
         
         //NSMutableDictionary *dataDict=[jsonObjects objectAtIndex:0];
         //NSString *result = [dataDict objectForKey:@"result"];
         
         if(jsonObjects.count>0)
         {
             NSMutableDictionary *meeting= [jsonObjects objectAtIndex:0];
             dispatch_async(dispatch_get_main_queue(), ^{
                 NSString *meeting_str;
                 meeting_str=[NSString stringWithFormat:@"%@ and %@ at %@ about %@.",
                               [meeting valueForKey:@"client_fullname"],
                               [meeting valueForKey:@"staff_fullname"],
                               [meeting valueForKey:@"time"],
                               [meeting valueForKey:@"description"]];
                 
                 UIAlertView *helloWorldAlert = [[UIAlertView alloc]
                                                 initWithTitle:@"New Appointment" message:meeting_str delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                 // Display the Hello WorldMessage
                 [helloWorldAlert show];
                 [appointmentTableView reloadData];
             });
         }
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

-(void) gotHomeLoanRequestNotification:(NSString*)client_id
{
    //get the detailed info about the meeting
    NSURL *requestURL=[NSURL URLWithString:QUERY_DB_SERVIER_URL];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];
    
    //Set Post Data
    const char *bytes = [[NSString stringWithFormat:@"userid=%@", client_id] UTF8String];
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
         
         NSMutableDictionary *client=[jsonObjects objectAtIndex:0];
         
         //Show Meeting info
         dispatch_queue_t mainQueue = dispatch_get_main_queue();
         dispatch_async(mainQueue, ^(void)
            {
                NSString *showstr;
                showstr=[NSString stringWithFormat:@"%@ %@ has requested the home loan.",
                        [client valueForKey:@"givename"],
                         [client valueForKey:@"surname"]];
                
                SHOW_ALERT_WINDOW(@"Request", showstr)
            });
         
     }];

}

@end
