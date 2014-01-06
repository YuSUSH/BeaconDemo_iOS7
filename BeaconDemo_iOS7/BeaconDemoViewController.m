//
//  BeaconDemoViewController.m
//  BeaconDemo_iOS7
//
//  Created by Yu Liu on 10/10/13.
//
//

#import "BeaconDemoAppDelegate.h"
#import "BeaconDemoViewController.h"


static NSString * const kUUID = @"00000000-0000-0000-0000-000000000000";
static NSString * const kIdentifier = @"SomeIdentifier";
static NSString * const kCellIdentifier = @"BeaconCell";
#define DETECT_IOS_DISTANCE_BASED_ON_RSSI -80

@interface BeaconDemoViewController ()


@end

@implementation BeaconDemoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title=@"iOS to iOS with Beacon API";
    
    //init
    if (self.TRSwitch.on)
    {
        //ranging
        [self stopAdvertisingBeacon];
        [self startRangingForBeacons];
    }
    else
    {
        //advertising
        [self stopRangingForBeacons];
        [self startAdvertisingBeacon];
    }
}

#pragma mark - Beacon ranging
- (void)createBeaconRegion
{
    if (self.beaconRegion)
        return;
    
    NSUUID *proximityUUID = [[NSUUID alloc] initWithUUIDString:kUUID];
    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:proximityUUID identifier:kIdentifier];
}

- (void)turnOnRanging
{
    NSLog(@"Turning on ranging...");
    
    if (![CLLocationManager isRangingAvailable]) {
        NSLog(@"Couldn't turn on ranging: Ranging is not available.");
        self.TRSwitch.on = NO;
        return;
    }
    
    if (self.locationManager.rangedRegions.count > 0) {
        NSLog(@"Didn't turn on ranging: Ranging already on.");
        return;
    }
    
    [self createBeaconRegion];
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
    
    NSLog(@"Ranging turned on for region: %@.", self.beaconRegion);
}


- (void)startRangingForBeacons
{
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.activityType = CLActivityTypeFitness;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [self turnOnRanging];
}

- (void)stopRangingForBeacons
{
    if (self.locationManager.rangedRegions.count == 0) {
        NSLog(@"Didn't turn off ranging: Ranging already off.");
        return;
    }
    
    [self.locationManager stopRangingBeaconsInRegion:self.beaconRegion];
    
    self.detectedBeacons = nil;
    [self.beaconTableView reloadData];
    
    NSLog(@"Turned off ranging.");
}

#pragma mark - Beacon ranging delegate methods
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (![CLLocationManager locationServicesEnabled]) {
        NSLog(@"Couldn't turn on ranging: Location services are not enabled.");
        self.TRSwitch.on = NO;
        return;
    }
    
    if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorized) {
        NSLog(@"Couldn't turn on ranging: Location services not authorised.");
        self.TRSwitch.on = NO;
        return;
    }
    
    self.TRSwitch.on = YES;
}

-(void)ShowAlertDialog:(NSString *)msg
{
    [super PlayRingtone];
    
    //show the dialog box
    UIAlertView *helloWorldAlert = [[UIAlertView alloc]
                                    initWithTitle:@"Sush Mobile" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    // Display the Hello WorldMessage
    [helloWorldAlert show];
}

- (void)locationManager:(CLLocationManager *)manager
        didRangeBeacons:(NSArray *)beacons
               inRegion:(CLBeaconRegion *)region
{
    static Boolean bInsideRange=NO;
    
    if ([beacons count] == 0)
    {
        NSLog(@"No beacons found nearby.");
    }
    else
    {
        NSLog(@"Found beacons!");
        //identify the target device
        for(CLBeacon *beacon in beacons)
        {
            //NSLog(@"detected device's UUID=%@", beacon.proximityUUID.UUIDString);
            if([beacon.proximityUUID.UUIDString isEqual: kUUID]) //if it's our beacon device
            {
                
               if(beacon.rssi<0 && beacon.rssi >DETECT_IOS_DISTANCE_BASED_ON_RSSI) //if it's inside our range
               {
                   if(!bInsideRange) //if we haven't shown this information before
                   {
                    
                       [self ShowAlertDialog:@"Welcome to Sush Mobile!"];
                       bInsideRange=YES;
                       return;
                   }
               }
               else //we are outside the range
               {
                   if(bInsideRange) //if we were inside range before
                   {
                       [self ShowAlertDialog:@"See you next time!"];
                       bInsideRange=NO;
                       return;
                   }
               }
            }
    
        }
      
    }
    
    
    //self.detectedBeacons = beacons;
    //[self.beaconTableView reloadData];
}

#pragma mark - Beacon advertising
- (void)turnOnAdvertising
{
    if (self.peripheralManager.state != 5) {
        NSLog(@"Peripheral manager is off.");
        self.TRSwitch.on = NO;
        return;
    }
    
    time_t t;
    srand((unsigned) time(&t));
    CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:self.beaconRegion.proximityUUID
                                                                     major:rand()
                                                                     minor:rand()
                                                                identifier:self.beaconRegion.identifier];
    //NSDictionary *beaconPeripheralData = [region peripheralDataWithMeasuredPower:nil];
    //[self.peripheralManager startAdvertising:beaconPeripheralData];
    //to advertise the service UUID
    [self.peripheralManager startAdvertising:@{ CBAdvertisementDataServiceUUIDsKey : @[[CBUUID UUIDWithString:IPAD3_SERVICE_ID]] }];
}


- (void)startAdvertisingBeacon
{
    NSLog(@"Turning on advertising...");
    
    [self createBeaconRegion];
    
    if (!self.peripheralManager)
        self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil options:nil];
    
    [self turnOnAdvertising];
}

- (void)stopAdvertisingBeacon
{
    [self.peripheralManager stopAdvertising];
    
    NSLog(@"Turned off advertising.");
}

#pragma mark - Beacon advertising delegate methods
- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheralManager error:(NSError *)error
{
    if (error) {
        NSLog(@"Couldn't turn on advertising: %@", error);
        self.TRSwitch.on = NO;
        return;
    }
    
    if (peripheralManager.isAdvertising) {
        NSLog(@"Turned on advertising.");
        self.TRSwitch.on = NO;
    }
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheralManager
{
    if (peripheralManager.state != 5) {
        NSLog(@"Peripheral manager is off.");
        self.TRSwitch.on = NO;
        return;
    }
    
    NSLog(@"Peripheral manager is on.");
    [self turnOnAdvertising];
}

#pragma mark - Table view functionality
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CLBeacon *beacon = self.detectedBeacons[indexPath.row];
    
    UITableViewCell *defaultCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                                          reuseIdentifier:kCellIdentifier];
    
    defaultCell.textLabel.text = beacon.proximityUUID.UUIDString;
    
    NSString *proximityString;
    switch (beacon.proximity) {
        case CLProximityNear:
            proximityString = @"Near";
            break;
        case CLProximityImmediate:
            proximityString = @"Immediate";
            break;
        case CLProximityFar:
            proximityString = @"Far";
            break;
        case CLProximityUnknown:
        default:
            proximityString = @"Unknown";
            break;
    }
    defaultCell.detailTextLabel.text = [NSString stringWithFormat:@"%@, %@ • %@ • %f • %li",
                                        beacon.major.stringValue, beacon.minor.stringValue, proximityString, beacon.accuracy, (long)beacon.rssi];
    defaultCell.detailTextLabel.textColor = [UIColor grayColor];
    
    return defaultCell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.detectedBeacons.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Detected beacons";
}
/////////////////////////////////////////////////////////////////////////////////////////
- (IBAction)FunctionSwitch:(UISwitch *)sender
{
    
    UISwitch *theSwitch = (UISwitch *)sender;
    if (theSwitch.on)
    {
        //ranging
        [self stopAdvertisingBeacon];
        [self startRangingForBeacons];
    }
    else
    {
        //advertising
        [self stopRangingForBeacons];
        [self startAdvertisingBeacon];
    }
    
}
@end
