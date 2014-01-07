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
    
    self.cm = [[CBCentralManager alloc]initWithDelegate:self queue:nil];
    
    self.title=@"BLE device to iOS with Bluetooth Core API";
    
    peripherals=[[NSMutableArray alloc] init];
    [peripherals removeAllObjects];
    
    
    BeaconDemoAppDelegate *appDelegate	=	(BeaconDemoAppDelegate*)[[UIApplication sharedApplication] delegate];
    appDelegate.tv=self; //pass this pointer to the AppDelegate

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

-(void) NotifyPushNotificationServer_Post
{
    NSString* deviceID= [self getCurrentDeviceID];
    NSLog(@"////////This device ID=%@", deviceID);
    
    NSURL *requestURL=[NSURL URLWithString:PUSH_SERVIER_URL];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];
    
    //Set Post Data
    //const char *bytes = [[NSString stringWithFormat:@"<?xml version=\"1.0\"?>\n<deviceid>%@</deviceid>", deviceID] UTF8String];
    
    const char *bytes = [[NSString stringWithFormat:@"deviceid=%@", deviceID] UTF8String];
    //For multiple POST data
    //NSString *key = [NSString stringWithFormat:@"key=%@&key2=%2", keyValue, key2value];
    
    //Send request
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[NSData dataWithBytes:bytes length:strlen(bytes)]];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
    {
        
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
        [self NotifyPushNotificationServer_Post]; //notify the server side that we found the iPad
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
////////////////////////////////////////////////////////////////////////////////////////////

@end
