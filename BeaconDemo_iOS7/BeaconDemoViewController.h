//
//  BeaconDemoViewController.h
//  BeaconDemo_iOS7
//
//  Created by Yu Liu on 10/10/13.
//
//

#import <UIKit/UIKit.h>


#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "AudioViewController.h"


@interface BeaconDemoViewController : AudioViewController <CLLocationManagerDelegate, CBPeripheralManagerDelegate, UITableViewDataSource, UITableViewDelegate, UIPopoverControllerDelegate>
@property (weak, nonatomic) IBOutlet UISwitch *TRSwitch;
- (IBAction)FunctionSwitch:(UISwitch *)sender;

@property (nonatomic, weak) IBOutlet UITableView *beaconTableView;
@property (strong, nonatomic) IBOutlet UILabel *infoLabel;


@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLBeaconRegion *beaconRegion;
@property (nonatomic, strong) CBPeripheralManager *peripheralManager;
@property (nonatomic, strong) NSArray *detectedBeacons;
@property (nonatomic, retain) UIPopoverController *m_PopoverController; //The Popover Controller
@property (nonatomic, strong) NSMutableArray *popupQueue; //the queue storing all the people to be shown
@property (nonatomic, strong) NSLock *queueLock; //Lock object used for the queue
@property (nonatomic, strong) NSMutableArray *enteringClients; //all the clients who have come into the shop

-(void)ShowPopupView:(NSMutableDictionary*)personalInfo;
-(void) QueryPersonalInfoAndShow:(NSString*)userID;
-(void) ClientHasLeft:(NSString*)userID;
@property (strong, nonatomic) IBOutlet UITableView *enteringClientTableView;

@end
