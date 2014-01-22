//
//  BeaconDemoAppDelegate.h
//  BeaconDemo_iOS7
//
//  Created by Yu Liu on 10/10/13.
//
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BeaconDemoViewController.h"
#import "PersonalInfoPopupViewController.h"

#define IPAD3_SERVICE_ID @"87BB8D91-4662-780A-5A25-C1626992C22D"


#define PUSH_SERVIER_URL @"http://experiment.sandbox.net.nz/beacon/simplepush.php"
#define IPAD_TOKEN_UPDATE_URL @"http://experiment.sandbox.net.nz/beacon/update_ipad_token.php"
#define QUERY_DB_SERVIER_URL @"http://ble.sandbox.net.nz/myforum/query_personalinfo.php"
#define QUERY_LOGIN_URL @"http://ble.sandbox.net.nz/myforum/query_login.php"
#define MEETING_DUE_NOTIFY_URL @"http://ble.sandbox.net.nz/myforum/notify_meeting.php"
#define QUERY_ALL_APPOINTMENTS @"http://ble.sandbox.net.nz/myforum/query_all_appointments.php"
#define QUERY_CLIENTS_APPOINTMENT_URL @"http://ble.sandbox.net.nz/myforum/query_clients_appointments.php"

#define GET_APPDELEGATE BeaconDemoAppDelegate *appDelegate	=	(BeaconDemoAppDelegate*)[[UIApplication sharedApplication] delegate];

@interface BeaconDemoAppDelegate : UIResponder <UIApplicationDelegate, CBCentralManagerDelegate,CBPeripheralDelegate>

@property (strong, nonatomic) UIWindow *window;

//for background running
@property (nonatomic, unsafe_unretained) UIBackgroundTaskIdentifier backgroundTaskIdentifier;
@property (nonatomic, strong) NSTimer *myTimer;


@property (strong, nonatomic) BeaconDemoViewController *bv;

@property (strong, nonatomic) NSString *CurrentUserID;
@property (strong, nonatomic) NSMutableDictionary *CurrentPersonalInfo;

@end
