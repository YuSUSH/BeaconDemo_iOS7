//
//  BeaconDemoAppDelegate.h
//  BeaconDemo_iOS7
//
//  Created by Yu Liu on 10/10/13.
//
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "BLETagViewController.h"
#import "BeaconDemoViewController.h"
#import "PersonalInfoPopupViewController.h"

#define IPAD3_SERVICE_ID @"87BB8D91-4662-780A-5A25-C1626992C22D"

#define IPAD3_DEVICE_UUID @"87BB8D91-4662-780A-5A25-C1626992C22D"

@interface BeaconDemoAppDelegate : UIResponder <UIApplicationDelegate, CBCentralManagerDelegate,CBPeripheralDelegate>

@property (strong, nonatomic) UIWindow *window;

//for background running
@property (nonatomic, unsafe_unretained) UIBackgroundTaskIdentifier backgroundTaskIdentifier;
@property (nonatomic, strong) NSTimer *myTimer;

@property (strong,nonatomic) CBCentralManager *cm;

@property (strong, nonatomic) BLETagViewController *tv;
@property (strong, nonatomic) BeaconDemoViewController *bv;

@end
