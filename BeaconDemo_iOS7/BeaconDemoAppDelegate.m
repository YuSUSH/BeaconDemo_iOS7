//
//  BeaconDemoAppDelegate.m
//  BeaconDemo_iOS7
//
//  Created by Yu Liu on 10/10/13.
//
//

#import "BeaconDemoAppDelegate.h"


@implementation BeaconDemoAppDelegate
@synthesize  CurrentUserID, CurrentPersonalInfo;
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
    
    
    // Let the device know we want to receive push notifications
	[[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
    //Your app can find out which types of push notifications are enabled through:
    //UIRemoteNotificationType enabledTypes = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
    //NSLog(@"enabledTypes is: %d", enabledTypes);
    
    return YES;
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
	NSLog(@"My token is: %@", deviceToken);
    
    //Conver the token into string
    const unsigned *tokenBytes = [deviceToken bytes];
    NSString *hexToken = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",
                          ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]),
                          ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]),
                          ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];
    
    [self UpdateNotifyPushNotificationToken:hexToken];
    
}

-(void) UpdateNotifyPushNotificationToken:(NSString *)tokenstr
{
    
    NSURL *requestURL=[NSURL URLWithString:IPAD_TOKEN_UPDATE_URL];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];
    
    //Set Post Data
    const char *bytes = [[NSString stringWithFormat:@"token=%@", tokenstr] UTF8String];
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

- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo
{
	NSLog(@"Received notification: %@", userInfo);
    
    //Get the personID from notification
    NSString *userid=[[userInfo valueForKey:@"aps"] valueForKey:@"id"];
    NSString *event=[[userInfo valueForKey:@"aps"] valueForKey:@"event"];
    
    // Query the personal info with the ID got from notification
    if([event isEqualToString:@"in"]) //client came in event
    {
        if(self.bv!=nil)
        {
            [self.bv QueryPersonalInfoAndShow:userid];
            [self.bv checkDueAppointment:userid]; //check if there's any due meeting for this client
        }
        
        return;
    }
    
    if([event isEqualToString:@"out"]) //client came in event
    {
        if(self.bv!=nil)
            [self.bv ClientHasLeft:userid];
    }
    
    
    if([event isEqualToString:@"homeloan_request"]) //request homeloan
    {
        if(self.bv!=nil)
            [self.bv homeloanRequest:userid];
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

    
}
//////////////////////////////////////////////////////////////////////////////////////////////////
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
