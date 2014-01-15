//
//  PopoverDatePicker.h
//  BeaconDemo_iOS7
//
//  Created by Yu Liu on 16/01/14.
//
//

#import <Foundation/Foundation.h>

@interface PopoverDatePicker: NSObject
@property (nonatomic, retain) UIPopoverController *m_PopoverController;
@property (nonatomic, retain) UIDatePicker *m_Picker;

-(void) Close;
-(void) Popup:(id<UIPickerViewDelegate>)PickerDelegate
         From:(CGRect)rect InView:(UIView*)view
DoneButtonTarget:(id)target DoneButtonAction:(SEL)handler;
- (IBAction)OnClickCancel:(id)sender;
@end