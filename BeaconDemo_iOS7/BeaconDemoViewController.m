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

@synthesize m_PopoverController, popupQueue, queueLock, enteringClients;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    m_PopoverController=nil;
    
    //Init the lock object for queue
    queueLock=[[NSLock alloc] init];
    
    //init the queue for showing people
    popupQueue=[[NSMutableArray alloc] init];
    [popupQueue removeAllObjects];
    
    //init the clients array for list show
    enteringClients=[[NSMutableArray alloc] init];
    [enteringClients removeAllObjects];
    
    self.title=@"iOS to iOS with Beacon API";
    
    //Save the view in the AppDelegate
    GET_APPDELEGATE
    appDelegate.bv=self; //pass this pointer to the AppDelegate
    
    //advertising
    [self stopRangingForBeacons];
    [self startAdvertisingBeacon];
    
    self.enteringClientTableView.delegate=self;
    self.enteringClientTableView.dataSource=self;
    [self.enteringClientTableView reloadData];
}


-(void) removeFromQueueAndShowPopupView
{
    [queueLock lock];
    
    if(self.popupQueue.count<1)
        return; //do nothing
    
    NSMutableDictionary *person=[popupQueue objectAtIndex:0];
    [self ShowPopupView:person];
    [popupQueue removeObjectAtIndex:0];
    
    [queueLock unlock];
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
        //self.TRSwitch.on = NO;
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
        //self.TRSwitch.on = NO;
        return;
    }
    
    if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorized) {
        NSLog(@"Couldn't turn on ranging: Location services not authorised.");
        //self.TRSwitch.on = NO;
        return;
    }
    
    //self.TRSwitch.on = YES;
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
        //self.TRSwitch.on = NO;
        return;
    }
    
    time_t t;
    srand((unsigned) time(&t));
    CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:self.beaconRegion.proximityUUID
                                                                     major:rand()
                                                                     minor:rand()
                                                                identifier:self.beaconRegion.identifier];
    NSDictionary *beaconPeripheralData = [region peripheralDataWithMeasuredPower:nil];
    [self.peripheralManager startAdvertising:beaconPeripheralData];
    
    //to advertise the service UUID
    //[self.peripheralManager startAdvertising:@{ CBAdvertisementDataServiceUUIDsKey : @[[CBUUID UUIDWithString:IPAD3_SERVICE_ID]] }];
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
        //self.TRSwitch.on = NO;
        return;
    }
    
    if (peripheralManager.isAdvertising) {
        NSLog(@"Turned on advertising.");
        //self.TRSwitch.on = NO;
    }
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheralManager
{
    if (peripheralManager.state != 5) {
        NSLog(@"Peripheral manager is off.");
        //self.TRSwitch.on = NO;
        return;
    }
    
    NSLog(@"Peripheral manager is on.");
    [self turnOnAdvertising];
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


-(void)ShowPopupView:(NSMutableDictionary*)personalInfo
{
    if(self.m_PopoverController!=nil)
        [self.m_PopoverController dismissPopoverAnimated:YES];
    
    PersonalInfoPopupViewController* popoverContent;
    //Show the popovercontrol
    popoverContent = [[PersonalInfoPopupViewController alloc] init];
    
    
    //create a popover controller
    self.m_PopoverController = [[UIPopoverController alloc] initWithContentViewController:popoverContent];
    self.m_PopoverController.delegate=self;
   
    popoverContent.personalInfo=personalInfo; //pass the personal info to popupview
    popoverContent.m_PopoverController=self.m_PopoverController; //pass the pointer of m_PopoverController
    popoverContent.mainView=self; //pass the pointer of this view
    
    self.m_PopoverController.popoverContentSize=CGSizeMake(531, 544);
    
    
    //Make it appears from the button's area
    [self.m_PopoverController presentPopoverFromRect: CGRectMake(80, 220, 531, 544)
     //[self convertRect:self.m_button.frame toView:self.mView]
                                              inView:self.view
                            permittedArrowDirections:0 animated:YES];
}

- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController
{
    return false;
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController;
{
    [m_PopoverController dismissPopoverAnimated:false];
    m_PopoverController=nil;
    
    //if need to show the next popup
    if(self.popupQueue.count>0)
    {
        [self removeFromQueueAndShowPopupView];
    }
}


//The client has left the shop, so we should remove him from the entering list
-(void) ClientHasLeft:(NSString*)userID
{
    int m;
    if(enteringClients!=nil && enteringClients.count>0)
    {
        for(m=0;m<enteringClients.count;m++)
        {
            NSMutableDictionary *client=[enteringClients objectAtIndex:m];
            if([[client valueForKey:@"userid"] isEqualToString:userID])
                [enteringClients removeObjectAtIndex:m]; //remove this client
        }
    }
    
    [self.enteringClientTableView reloadData]; //refresh the table view
    
}


-(void) QueryPersonalInfoAndShow:(NSString*)userID
{
    //firstly, check if this user is already in current client list
    int m;
    if(enteringClients!=nil && enteringClients.count>0)
    {
        bool found=false;
        for(m=0;m<enteringClients.count;m++)
        {
            NSMutableDictionary *client=[enteringClients objectAtIndex:m];
            if([[client valueForKey:@"userid"] isEqualToString:userID])
            {
                found=true;
                break;
            }
        }
        
        if(found==true) //already exists
            return; //do nothing
    }
    
    
    NSURL *requestURL=[NSURL URLWithString:QUERY_DB_SERVIER_URL];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];
    
    //Set Post Data
    //const char *bytes = [[NSString stringWithFormat:@"<?xml version=\"1.0\"?>\n<deviceid>%@</deviceid>", deviceID] UTF8String];
    
    const char *bytes = [[NSString stringWithFormat:@"userid=%@", userID] UTF8String];
    //For multiple POST data
    //NSString *key = [NSString stringWithFormat:@"key=%@&key2=%2", keyValue, key2value];
    
    //Send request
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[NSData dataWithBytes:bytes length:strlen(bytes)]];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    //Request with the personal ID and wait for response from DB server
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         if(error !=nil)
             return;
             
         NSLog(@"responseData: %@", data);
         
         //decode the response data
         NSMutableArray *jsonObjects = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
         
         NSMutableDictionary *personalInfo=[[NSMutableDictionary alloc] init];
         int i;
         for (i=0; i<[jsonObjects count];i++)
         {
             NSMutableDictionary *dataDict=[jsonObjects objectAtIndex:i];
             personalInfo=dataDict;
         }
         
       
         dispatch_async(dispatch_get_main_queue(), ^{
                 //[self ShowPopupView:personalInfo];
                [queueLock lock];
                [self.popupQueue addObject:personalInfo]; //Add it to the popup queue
                [queueLock unlock];
             
                [self.enteringClients addObject:personalInfo]; //Add it to the list array
                [self.enteringClientTableView reloadData]; //refresh list display
             
                if(self.popupQueue.count==1 && self.m_PopoverController==nil) //this is the only element in queue
                {
                    //show it and remove that element from queue
                    [self removeFromQueueAndShowPopupView];
                }
         });
         //[self ShowPersonInfoWindow:outputstr];
         //Show the popup window for personal info
         
         
     }];
    
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row < self.enteringClients.count)
    {
        NSMutableDictionary *client= [enteringClients objectAtIndex:indexPath.row];
        self.labelFullname.text=[NSString stringWithFormat:@"%@ %@",
        [client valueForKey:@"givename"], [client valueForKey:@"surname"] ];
        
        
        //show picture
        NSString *picture_url= [NSString stringWithFormat:@"%@%@",
                                @"http://ble.sandbox.net.nz/myforum/upload_image/",
                                [client valueForKey:@"iconfilename"] ];
        
        NSURL *url = [NSURL URLWithString:picture_url];
        NSData *data = [NSData dataWithContentsOfURL:url];
        UIImage *img = [[UIImage alloc] initWithData:data];
        CGSize size = img.size;
        [self.imgPhoto setImage:img];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    
    
    [cell.textLabel setFont:[UIFont systemFontOfSize:18]];
    [cell.textLabel setTextColor:[UIColor blackColor]];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    NSString *titilestr;
    
    if(indexPath.row<enteringClients.count)
    {
        NSMutableDictionary *person=[enteringClients objectAtIndex:indexPath.row];
        titilestr=[NSString stringWithFormat:@"%@ %@",
                   [person valueForKey:@"givename"],
                   [person valueForKey:@"surname"]];
    }
    else
        titilestr=@"";
    
    
    [cell.textLabel setText:titilestr];
    
    
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(enteringClients!=nil && enteringClients.count>0)
        return enteringClients.count;
    else
        return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


@end
