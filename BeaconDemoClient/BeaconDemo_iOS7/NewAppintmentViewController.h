//
//  NewAppintmentViewController.h
//  BeaconDemo_iOS7
//
//  Created by Yu Liu on 15/01/14.
//
//

#import "AudioViewController.h"
#import "PopoverPicker.h"
#import "PopoverDatePicker.h"

@interface NewAppintmentViewController : AudioViewController <UIPickerViewDelegate>

@property (retain, nonatomic) PopoverPicker *staffPicker;
@property (retain, nonatomic) PopoverDatePicker *timePicker;
@property (strong, nonatomic) NSString *selectedDateStr;

@property (strong, nonatomic) NSMutableArray *allStaffs;
@property (strong, nonatomic) IBOutlet UIButton *btnStaffChoice;
@property (strong, nonatomic) IBOutlet UIButton *btnSelectTime;
- (IBAction)OnClickStaffChoice:(UIButton *)sender;
-(IBAction) DoneStaffPicker:(id)sender;
@property (strong, nonatomic) IBOutlet UITextView *textDescription;
@property (strong, nonatomic) NSMutableDictionary *selectedStaff;
- (IBAction)OnClickCancel:(UIButton *)sender;
- (IBAction)OnClickSubmit:(UIButton *)sender;
- (IBAction)OnClickSelectTime:(UIButton *)sender;

@end
