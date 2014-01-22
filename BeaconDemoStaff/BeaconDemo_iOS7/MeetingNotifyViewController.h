//
//  MeetingNotifyViewController.h
//  BeaconDemo_iOS7
//
//  Created by Yu Liu on 22/01/14.
//
//

#import "AudioViewController.h"

@interface MeetingNotifyViewController : AudioViewController
@property (strong, nonatomic) IBOutlet UILabel *labelTime;
@property (strong, nonatomic) IBOutlet UILabel *labelDescription;

@property (strong, nonatomic) NSMutableDictionary *appointmentDetail;
@property (strong, nonatomic) IBOutlet UILabel *labelTitle;
- (IBAction)OnClickClose:(UIButton *)sender;

@end