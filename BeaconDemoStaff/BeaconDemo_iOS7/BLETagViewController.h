//
//  BLETagViewController.h
//  BeaconDemo_iOS7
//
//  Created by Yu Liu on 14/10/13.
//
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreLocation/CoreLocation.h>
#import "AudioViewController.h"

static NSString * const kUUID = @"00000000-0000-0000-0000-000000000000";
static NSString * const kIdentifier = @"SomeIdentifier";

#define IPHONE5
//#define IPAD3

#ifdef IPHONE5
static NSString * const TagUUID = @"A8CE57BF-00E1-B9A1-F5F0-E5412202529C";
#endif

#ifdef IPAD3
//static NSString * const TagUUID = @"798D3801-B7B2-1594-3641-A91E559638B7";
static NSString * const TagUUID = @"18D50646-E9D1-BEE1-5749-85928B89BC45";
#endif

static NSString * const iOSUUID = @"00000000-0000-0000-0000-000000000000";

#define DETECT_IOS_DISTANCE_BASED_ON_RSSI -80
#define DETECT_BLETAG_DISTANCE_BASED_ON_RSSI -80

@interface BLETagViewController : AudioViewController <CBCentralManagerDelegate,CBPeripheralDelegate, NSURLConnectionDelegate, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource>

@property (strong,nonatomic) CBCentralManager *cm;
@property (weak, nonatomic) IBOutlet UILabel *LabelDeviceInfo;
@property (strong,nonatomic) NSMutableArray *peripherals;

-(void) NotifyPushNotificationServer;
-(void) NewClientArrive;

//iBeacon objects
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLBeaconRegion *beaconRegion;

- (void)startRangingForBeacons;
@property (strong, nonatomic) IBOutlet UITableView *appointmentTableView;

@property (strong, nonatomic) NSMutableArray *myAppointments; //store all the appointments with me
- (IBAction)OnClickLogout:(UIButton *)sender;

-(void)showNewAppointment:(NSString *)appointment_id;
-(void) ShowMeetingDueInfo:(NSString *)appointment_id;

@end
