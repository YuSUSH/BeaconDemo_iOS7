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

@property (retain, nonatomic) iphonePicker *staffPicker;
@property (strong, nonatomic) NSString *selectedDateStr;

@property (strong, nonatomic) NSMutableArray *allStaffs;
@property (strong, nonatomic) IBOutlet UITextField *textDateChoice;
- (IBAction)OnClickStaffChoice:(UIButton *)sender;
-(IBAction) DoneStaffPicker:(id)sender;
@property (strong, nonatomic) IBOutlet UITextView *textDescription;
@property (strong, nonatomic) NSMutableDictionary *selectedStaff;
- (IBAction)OnClickSubmit:(UIButton *)sender;

@property (strong, nonatomic) iphoneDatePicker *datePicker;
@property (strong, nonatomic) IBOutlet UITextField *textStaffChoice;

@end
