//
//  NewAppintmentViewController.h
//  BeaconDemo_iOS7
//
//  Created by Yu Liu on 15/01/14.
//
//

#import "AudioViewController.h"
#import "PopoverPicker.h"

@interface NewAppintmentViewController : AudioViewController <UIPickerViewDelegate>

@property (retain, nonatomic) PopoverPicker *staffPicker;
@property (strong, nonatomic) NSMutableArray *allStaffs;
@property (strong, nonatomic) IBOutlet UIButton *btnStaffChoice;
- (IBAction)OnClickStaffChoice:(UIButton *)sender;
-(IBAction) DoneStaffPicker:(id)sender;

@end
