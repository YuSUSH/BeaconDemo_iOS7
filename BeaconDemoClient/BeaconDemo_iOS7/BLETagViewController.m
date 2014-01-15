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
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    //self.cm = [[CBCentralManager alloc]initWithDelegate:self queue:nil];
    //Use iBeacon API instead of BLE API
    [self startRangingForBeacons];
    
    self.title=@"BLE device to iOS with Bluetooth Core API";
    
    peripherals=[[NSMutableArray alloc] init];
    [peripherals removeAllObjects];
    
    
    GET_APPDELEGATE
    appDelegate.tv=self; //pass this pointer to the AppDelegate
    
    //Show Welcome message with the user's fullname
    NSString *fullname=[NSString stringWithFormat:@"Welcome, %@ %@!",
                        [appDelegate.CurrentPersonalInfo valueForKey:@"givename"],
                        [appDelegate.CurrentPersonalInfo valueForKey:@"surname"]];
    self.LabelDeviceInfo.text=fullname;

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

@end
