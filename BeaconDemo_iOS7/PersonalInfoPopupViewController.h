//
//  PersonalInfoPopupViewController.h
//  BeaconDemo_iOS7
//
//  Created by Yu Liu on 7/01/14.
//
//

#import <UIKit/UIKit.h>
#import "AudioViewController.h"
#import "LeftTableViewController.h"

@interface PersonalInfoPopupViewController : AudioViewController
@property (strong, nonatomic) IBOutlet UILabel *labelName;
@property (strong, nonatomic) IBOutlet UILabel *personalInfoLabel;
@property (strong, nonatomic) IBOutlet UIImageView *imageViewPhoto;

@property (nonatomic, retain) UIPopoverController *m_PopoverController; //The Popover Controller
@property (nonatomic, retain) LeftTableViewController *mainView; //pointer to the main view
@property (strong, nonatomic) NSMutableDictionary *personalInfo;
- (IBAction)OnClickCloseButton:(UIButton *)sender;
@property (strong, nonatomic) IBOutlet UILabel *labelClientID;

@end
