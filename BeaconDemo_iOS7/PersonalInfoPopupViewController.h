//
//  PersonalInfoPopupViewController.h
//  BeaconDemo_iOS7
//
//  Created by Yu Liu on 7/01/14.
//
//

#import <UIKit/UIKit.h>

@interface PersonalInfoPopupViewController : UIViewController
@property (strong, nonatomic) IBOutlet UILabel *labelName;
@property (strong, nonatomic) IBOutlet UILabel *personalInfoLabel;
@property (strong, nonatomic) IBOutlet UIImageView *imageViewPhoto;

@property (strong, nonatomic) NSMutableDictionary *personalInfo;

@end
