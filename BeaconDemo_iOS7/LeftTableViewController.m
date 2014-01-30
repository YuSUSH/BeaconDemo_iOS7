//
//  LeftTableViewController.m
//  BeaconDemo_iOS7
//
//  Created by Yu Liu on 24/01/14.
//
//

#import "LeftTableViewController.h"
#import "BeaconDemoAppDelegate.h"
#import "ImageTableCell.h"

@interface LeftTableViewController ()

@end

@implementation LeftTableViewController

@synthesize m_PopoverController, popupQueue, queueLock, enteringClients;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source




/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

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
    
    self.title=@"Queue";
    
    //Save the view in the AppDelegate
    GET_APPDELEGATE
    appDelegate.leftSplitView=self; //pass this pointer to the AppDelegate
    
    //advertising
    [self stopRangingForBeacons];
    [self startAdvertisingBeacon];
    
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    [self.tableView reloadData];
    
    /*
     #define CHECH_PERIOD 10 * 60 //every 10 minutes
     //[self MeetingDueNotify];
     meetingDueTimer = [NSTimer scheduledTimerWithTimeInterval:CHECH_PERIOD
     target:self selector:@selector(checkDueAppointment:)
     userInfo:nil repeats:YES];
     */
    
    //Init the image array
    self.imageArray= [[NSMutableArray alloc] init];
    [self.imageArray removeAllObjects];
    
    UINavigationBar *navbar= self.navigationController.navigationBar;
    
    //[navbar setBackgroundColor:[UIColor redColor]];
    [[UINavigationBar appearance] setTintColor:[UIColor redColor]];
    //[navbar setTintColor:[UIColor redColor]];
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
    [self.tableView reloadData];
    
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
    //[super PlayRingtone];
    
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
    [self.m_PopoverController presentPopoverFromRect: CGRectMake(380, 120, 531, 544)
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
            {
                [enteringClients removeObjectAtIndex:m]; //remove this client
                [self.imageArray removeObjectAtIndex:m]; //remove this client's image from the array too.
            }
        }
    }
    
    [self.tableView reloadData]; //refresh the table view
    
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
    
    
    NSURL *requestURL=[NSURL URLWithString:QUERY_PERSONAL_INFO_URL];
    
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
             //Load the image data for this client
             NSString *iconfilename= [personalInfo valueForKey:@"iconfilename"];
             UIImage *img=[self loadIconImage:iconfilename];
             [self.imageArray addObject:img]; //Add this image to the array
             [self.tableView reloadData]; //refresh list display
             
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

-(UIImage*) loadIconImage:(NSString*)iconfilename
{
    //show picture
    NSString *picture_url= [NSString stringWithFormat:@"%@%@",
                            @"http://ble.sandbox.net.nz/myforum/upload_image/",
                            iconfilename ];
    
    NSURL *url = [NSURL URLWithString:picture_url];
    NSData *data = [NSData dataWithContentsOfURL:url];
    UIImage *img = [[UIImage alloc] initWithData:data];
    return img;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row < self.enteringClients.count)
    {
        NSMutableDictionary *client= [enteringClients objectAtIndex:indexPath.row];
        GET_APPDELEGATE
        if(appDelegate.clientInfoView!=nil)
        {
            appDelegate.clientInfoView.labelFullname.text=[NSString stringWithFormat:@"%@ %@",
                                     [client valueForKey:@"givename"], [client valueForKey:@"surname"] ];
            
            
            NSString *clientIDstr;
            clientIDstr=[NSString stringWithFormat:@"Client ID: %@", [client valueForKey:@"userid"]];
            appDelegate.clientInfoView.labelClientID.text=clientIDstr;
            
            //show picture
            NSString *picture_url= [NSString stringWithFormat:@"%@%@",
                                    @"http://ble.sandbox.net.nz/myforum/upload_image/",
                                    [client valueForKey:@"iconfilename"] ];
            
            NSURL *url = [NSURL URLWithString:picture_url];
            NSData *data = [NSData dataWithContentsOfURL:url];
            UIImage *img = [[UIImage alloc] initWithData:data];
            CGSize size = img.size;
            [appDelegate.clientInfoView.imgPhoto setImage:img];
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"Cell";
    ImageTableCell *cell = (ImageTableCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil)
    {
        cell = [[ImageTableCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    
    
    [cell.NameLabel setTextColor:[UIColor blackColor]];
    //[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    NSString *titilestr;
    
    if(indexPath.row<enteringClients.count)
    {
        NSMutableDictionary *person=[enteringClients objectAtIndex:indexPath.row];
        titilestr=[NSString stringWithFormat:@"%@ %@",
                   [person valueForKey:@"givename"],
                   [person valueForKey:@"surname"]];
        
        if([person valueForKey:@"homeloan_request"] !=nil)
        {
            if([[person valueForKey:@"homeloan_request"] isEqualToString:@"TRUE"])
                cell.detailTextLabel.text=@"Home Loan Requested";
        }
        
        //show the image for this client
        [cell.imageView setImage:[self.imageArray objectAtIndex:indexPath.row]];
    }
    else
        titilestr=@"";
    
    
    [cell.NameLabel setText:titilestr];
    
    
    
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


-(void)homeloanRequest:(NSString *)userid
{
    if(enteringClients==nil || enteringClients.count==0)
        return; //do nothing
    
    int i;
    for(i=0;i<enteringClients.count;i++)
    {
        NSMutableDictionary *client= [enteringClients objectAtIndex:i];
        if( [userid isEqualToString:[client valueForKey:@"userid"]])
        {
            [client setObject:@"TRUE" forKey:@"homeloan_request"]; //set the value for homeload request
            [self.tableView reloadData]; //refresh display
            break;
        }
    }
}




@end
