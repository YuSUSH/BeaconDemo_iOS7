//
//  UserLoginViewController.h
//  BeaconDemo_iOS7
//
//  Created by Yu Liu on 8/01/14.
//
//

#import <UIKit/UIKit.h>

@interface UserLoginViewController : UIViewController <UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UITextField *useridText;
@property (strong, nonatomic) IBOutlet UITextField *passwordText;
- (IBAction)OnClickedLoginButton:(UIButton *)sender;

@end