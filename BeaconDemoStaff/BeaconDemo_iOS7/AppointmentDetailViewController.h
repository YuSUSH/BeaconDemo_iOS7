//
//  AppointmentDetailViewController.h
//  BeaconDemo_iOS7
//
//  Created by Yu Liu on 21/01/14.
//
//

#import <UIKit/UIKit.h>

@interface AppointmentDetailViewController : UIViewController

@property (strong, nonatomic) NSMutableDictionary *appointmentInfo;
@property (strong, nonatomic) IBOutlet UILabel *labelClientName;
@property (strong, nonatomic) IBOutlet UILabel *labelTime;
@property (strong, nonatomic) IBOutlet UILabel *labelDescription;
- (IBAction)OnClickBackButton:(UIButton *)sender;

@end
