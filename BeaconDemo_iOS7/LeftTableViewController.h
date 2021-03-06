//
//  LeftTableViewController.h
//  BeaconDemo_iOS7
//
//  Created by Yu Liu on 24/01/14.
//
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface LeftTableViewController : UITableViewController <CLLocationManagerDelegate, CBPeripheralManagerDelegate, UIPopoverControllerDelegate>


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

//@property (strong, nonatomic) IBOutlet UITableView *enteringClientTableView;
//@property (strong, nonatomic) IBOutlet UILabel *labelFullname;
//@property (strong, nonatomic) IBOutlet UIImageView *imgPhoto;

@property (strong, nonatomic) NSMutableArray *imageArray; //store all the image data for the entering clients

-(void)homeloanRequest:(NSString *)userid;

@end
