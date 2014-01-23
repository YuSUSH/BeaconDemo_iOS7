//
//  BeaconDemoAppDelegate.h
//  BeaconDemo_iOS7
//
//  Created by Yu Liu on 10/10/13.
//
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "PersonalInfoPopupViewController.h"
#import "LeftTableViewController.h"
#import "ClientInfoViewController.h"

#define IPAD3_SERVICE_ID @"87BB8D91-4662-780A-5A25-C1626992C22D"


static NSString * const kUUID = @"00000000-0000-0000-0000-000000000000";
static NSString * const kIdentifier = @"SomeIdentifier";
static NSString * const kCellIdentifier = @"BeaconCell";
#define DETECT_IOS_DISTANCE_BASED_ON_RSSI -80


#define PUSH_SERVIER_URL @"http://experiment.sandbox.net.nz/beacon/simplepush.php"
#define IPAD_TOKEN_UPDATE_URL @"http://experiment.sandbox.net.nz/beacon/update_ipad_token.php"
#define QUERY_DB_SERVIER_URL @"http://ble.sandbox.net.nz/myforum/query_personalinfo.php"
#define QUERY_LOGIN_URL @"http://ble.sandbox.net.nz/myforum/query_login.php"
#define QUERY_ALL_APPOINTMENTS @"http://ble.sandbox.net.nz/myforum/query_all_appointments.php"

#define GET_APPDELEGATE BeaconDemoAppDelegate *appDelegate	=	(BeaconDemoAppDelegate*)[[UIApplication sharedApplication] delegate];

@interface BeaconDemoAppDelegate : UIResponder <UIApplicationDelegate, CBCentralManagerDelegate,CBPeripheralDelegate>

@property (strong, nonatomic) UIWindow *window;

//for background running
@property (nonatomic, unsafe_unretained) UIBackgroundTaskIdentifier backgroundTaskIdentifier;
@property (nonatomic, strong) NSTimer *myTimer;



@property (strong, nonatomic) NSString *CurrentUserID;
@property (strong, nonatomic) NSMutableDictionary *CurrentPersonalInfo;
@property (strong, nonatomic) LeftTableViewController *leftSplitView;
@property (strong, nonatomic) ClientInfoViewController *clientInfoView;

@end
