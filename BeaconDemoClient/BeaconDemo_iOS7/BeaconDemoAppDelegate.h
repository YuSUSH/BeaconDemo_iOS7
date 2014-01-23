//
//  BeaconDemoAppDelegate.h
//  BeaconDemo_iOS7
//
//  Created by Yu Liu on 10/10/13.
//
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BLETagViewController.h"

#define IPAD3_SERVICE_ID @"87BB8D91-4662-780A-5A25-C1626992C22D"


#define PUSH_SERVIER_URL @"http://experiment.sandbox.net.nz/beacon/simplepush.php"
#define QUERY_DB_SERVIER_URL @"http://ble.sandbox.net.nz/myforum/query_personalinfo.php"
#define QUERY_LOGIN_URL @"http://ble.sandbox.net.nz/myforum/query_login.php"
#define CLIENT_ARRIVE_URL @"http://ble.sandbox.net.nz/myforum/client_arrive.php"
#define CLIENT_LEFT_URL @"http://ble.sandbox.net.nz/myforum/client_left.php"
#define GET_ALL_STAFF_INFO_URL @"http://ble.sandbox.net.nz/myforum/get_all_staff_info.php"
#define ADD_APPOINTMENT @"http://ble.sandbox.net.nz/myforum/add_appointment.php"
#define UPDATE_CLIENT_TOKEN_URL @"http://ble.sandbox.net.nz/myforum/update_clients_token.php"
#define QUERY_APPOINTMENT_DETAIL_URL @"http://ble.sandbox.net.nz/myforum/query_appointment_detail.php"
#define REQUEST_HOMELOAN_URL @"http://ble.sandbox.net.nz/myforum/request_homeloan.php"


#define GET_APPDELEGATE BeaconDemoAppDelegate *appDelegate	=	(BeaconDemoAppDelegate*)[[UIApplication sharedApplication] delegate];


#define BUSY_INDICATOR_START( indicator ) \
indicator.hidden=false; \
[ indicator startAnimating]; \
[[UIApplication sharedApplication] beginIgnoringInteractionEvents];

#define BUSY_INDICATOR_STOP( indicator ) \
dispatch_queue_t mainQueue = dispatch_get_main_queue(); \
dispatch_async(mainQueue, ^(void) \
{ \
        [ indicator stopAnimating]; \
        indicator.hidden=true; \
        [[UIApplication sharedApplication] endIgnoringInteractionEvents]; \
});


@interface BeaconDemoAppDelegate : UIResponder <UIApplicationDelegate, CBCentralManagerDelegate,CBPeripheralDelegate>

@property (strong, nonatomic) UIWindow *window;

//for background running
@property (nonatomic, unsafe_unretained) UIBackgroundTaskIdentifier backgroundTaskIdentifier;
@property (nonatomic, strong) NSTimer *myTimer;

@property (strong,nonatomic) CBCentralManager *cm;

@property (strong, nonatomic) BLETagViewController *tv;

@property (strong, nonatomic) NSString *CurrentUserID;
@property (strong, nonatomic) NSMutableDictionary *CurrentPersonalInfo;
@property (nonatomic) bool bEnableBLE; //if the BLE function is
@property (strong, nonatomic) NSString *currentToken;

@end
