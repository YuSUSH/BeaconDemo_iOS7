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
-(void) NotifyServer
{
    NSString* deviceID= [self getCurrentDeviceID];
    NSLog(@"////////This device ID=%@", deviceID);
    
    receivedData=[[NSMutableData alloc] init];
    NSString *requestURL=[NSString stringWithFormat:@"http://experiment.sandbox.net.nz/beacon/simplepush.php?deviceid=%@", deviceID];
    NSURLRequest *theRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:requestURL]];
    
    NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:theRequest  delegate:self];
    
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
        NSDictionary *options = @{CBCentralManagerScanOptionAllowDuplicatesKey: @YES};
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
       
        
        //if( [UUIDstr isEqual:kUUID])
        //    NSLog(@"/////// We've found the TI Tag!");
        static int got_index=0;

#define MEASURE_SIZE 50
        static float RSSI_array[MEASURE_SIZE];
        
        RSSI_array[got_index]=fRSSI; //the RSSI value we got this time
        got_index++;
        
        /*
        peripheral.delegate = self;
        [central connectPeripheral:peripheral options:nil]; //connect to the periph
        [peripherals addObject:peripheral];
         */
        
        if(got_index>=MEASURE_SIZE) //process this surge of data
        {
            got_index=0;
        
            last_RSSI=overall_RSSI;
            //get the sum of this surge of data
            overall_RSSI=0.0f;
            int i;
            for(i=0;i<MEASURE_SIZE;i++)
                overall_RSSI+= RSSI_array[i];
            
            overall_RSSI/=MEASURE_SIZE;
        }
        else
            return;
        

        self.LabelDeviceInfo.text=[NSString stringWithFormat:@"RSSI= %f", overall_RSSI];
        
        
         static Boolean bInsideRange=NO;
        
        if([RSSI floatValue]<0 && (overall_RSSI > DETECT_BLETAG_DISTANCE_BASED_ON_RSSI))
        {
            
            if((!bInsideRange) ) //if we were outside before
            {
                [self NotifyServer]; //notify the server side that we found the iPad
                [self ShowAlertDialog:@"Welcome to the TI SensorTag!"];
                bInsideRange=YES;
            }
        }
        else
        {
            if(bInsideRange ) //if we were inside before
            {
                [self ShowAlertDialog:@"See you Next time!"];
                bInsideRange=NO;
            }
        }
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
