//
//  BeaconDemoAppDelegate.m
//  BeaconDemo_iOS7
//
//  Created by Yu Liu on 10/10/13.
//
//

#import "BeaconDemoAppDelegate.h"


@implementation BeaconDemoAppDelegate
@synthesize  CurrentUserID, CurrentPersonalInfo, bEnableBLE, currentToken;
/////////////////////////////////////////////////////////////////////////////////////////
- (BOOL) isMultitaskingSupported
{
    BOOL result = false;
    if ([[UIDevice currentDevice]
         respondsToSelector:@selector(isMultitaskingSupported)])
    {
        result = [[UIDevice currentDevice] isMultitaskingSupported];
    }
    return result;
}
///////////////////////////////////////////////////////////////////////////////////////////
- (void) timerMethod:(NSTimer *)paramSender
{
    NSTimeInterval backgroundTimeRemaining =
    [[UIApplication sharedApplication] backgroundTimeRemaining];
    
    /*
    if (backgroundTimeRemaining == DBL_MAX)
        NSLog(@"Background Time Remaining = Undetermined");
    else
        NSLog(@"Background Time Remaining = %.02f Seconds",
              backgroundTimeRemaining);
     */
}
//////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    bEnableBLE=true; //enable BLE as default;
    
    
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
    
    return YES;
}


- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    //Conver the token into string
    const unsigned *tokenBytes = [deviceToken bytes];
    NSString *hexToken = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",
                          ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]),
                          ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]),
                          ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];
    
    NSLog(@"My token is: %@", hexToken);
    
    currentToken=hexToken; //save the new token;
}


- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo
{
	NSLog(@"Received notification: %@", userInfo);
    
    //Get the personID from notification
    NSString *appointmentid=[[userInfo valueForKey:@"aps"] valueForKey:@"alert"];
    NSString *event=[[userInfo valueForKey:@"aps"] valueForKey:@"event"];
    
    if([event isEqualToString:@"meeting_due"])
    {
        //Show the meeting notification
        if(self.tv!=nil)
            [self.tv ShowMeetingDueInfo:appointmentid];
        
    }
    
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

//////////////////////////////////////////////////////////////////////////////////////////////////
- (void) endBackgroundTask
{
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    __weak BeaconDemoAppDelegate
    *weakSelf = self;
    dispatch_async(mainQueue, ^(void)
    {
        BeaconDemoAppDelegate
        *strongSelf = weakSelf;
        if (strongSelf != nil)
        {
            [strongSelf.myTimer invalidate];
            [[UIApplication sharedApplication]
             endBackgroundTask:self.backgroundTaskIdentifier];
            strongSelf.backgroundTaskIdentifier = UIBackgroundTaskInvalid;
        }
    });
}
///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    if (![self isMultitaskingSupported])
        return;
    
    if(bEnableBLE) //if BLE function is enabled
    {
        /*
        self.cm = [[CBCentralManager alloc]initWithDelegate:self queue:nil];
        
        self.myTimer =
        [NSTimer scheduledTimerWithTimeInterval:1.0f
                                         target:self
                                       selector:@selector(timerMethod:)
                                       userInfo:nil
                                        repeats:YES];
        self.backgroundTaskIdentifier =
        [application beginBackgroundTaskWithExpirationHandler:^(void)
        {
            [self endBackgroundTask];
        }];
         */
        
        //Using iBeacon API
        [self.tv startRangingForBeacons];
    }

    
}
/////////////////////////////////////////////////////////////////////////////////////////////////
//static NSString * const TagUUID = @"A8CE57BF-00E1-B9A1-F5F0-E5412202529C";

-(void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    NSLog(@"//////////////centralManagerDidUpdateState.");
    if (central.state != CBCentralManagerStatePoweredOn)
    {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"BLE not supported !" message:[NSString stringWithFormat:@"CoreBluetooth return state: %d",central.state] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
    else
    {
        NSDictionary *options = @{CBCentralManagerScanOptionAllowDuplicatesKey: @NO};
        NSLog(@"//////////////Start to scan.");
         [central scanForPeripheralsWithServices:@[ [CBUUID UUIDWithString:IPAD3_SERVICE_ID] ] options:options];
    }
}
//////////////////////////////////////////////////////////////////////////////////////////////////
-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    
    NSLog(@"Found a BLE Device : %@",peripheral);
    
    /* iOS 6.0 bug workaround : connect to device before displaying UUID !
     The reason for this is that the CFUUID .UUID property of CBPeripheral
     here is null the first time an unkown (never connected before in any app)
     peripheral is connected. So therefore we connect to all peripherals we find.
     */
    
    float fRSSI=[RSSI floatValue];
    
    
    NSLog(@"device UUID=: %@, RSSI=%f", peripheral.identifier, fRSSI);
    
    /*
    //notify iOS that we've detected a device
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.alertBody = @"I found you";
    localNotification.soundName = @"ringtone.mp3";
    localNotification.fireDate = [NSDate date];
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
     */
        
    if(self.tv!=nil)
        [self.tv NewClientArrive]; //notify the server side
    
    
}
//////////////////////////////////////////////////////////////////////////////////////////////////

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
