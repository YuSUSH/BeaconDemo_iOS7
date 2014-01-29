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
- (IBAction)OnClickBackButton:(UIButton *)sender;
@property (strong, nonatomic) IBOutlet UIImageView *personalImage;
@property (strong, nonatomic) IBOutlet UILabel *labelClientID;
@property (strong, nonatomic) IBOutlet UITextView *textDescription;
@property (strong, nonatomic) IBOutlet UILabel *labelDepartment;
- (IBAction)OnClickConfirmMeeting:(UIButton *)sender;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *busyIndicator;

@end
