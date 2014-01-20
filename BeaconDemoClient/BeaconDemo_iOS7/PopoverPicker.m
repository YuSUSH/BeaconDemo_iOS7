//
//  PopoverPicker.m
//  BeaconDemo_iOS7
//
//  Created by Yu Liu on 15/01/14.
//
//

#import "PopoverPicker.h"

@implementation PopoverPicker
@synthesize m_Picker, m_PopoverController;
#define POPWINDOW_WIDTH 280

-(void) Popup:(id<UIPickerViewDelegate>)PickerDelegate
         From:(CGRect)rect InView:(UIView*)view
DoneButtonTarget:(id)target DoneButtonAction:(SEL)handler
{
    //Init the toobar with cancel & done buttons
    UIToolbar *pickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, POPWINDOW_WIDTH, 44)];
    pickerToolbar.barStyle = UIBarStyleBlackOpaque;
    NSMutableArray *barItems = [[NSMutableArray alloc] init];
    
    UIBarButtonItem* cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemCancel target:self action:@selector(OnClickCancel:)];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:target action:handler];
    
    
    UIBarButtonItem* space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:Nil action:nil];
    
    [barItems addObject:cancelButton];
    [barItems addObject:space];
    [barItems addObject:doneButton];
    
    pickerToolbar.items = barItems;
    
    
    //Init the Security Level Picker
    m_Picker=[[UIPickerView alloc] initWithFrame:CGRectMake(0, 45, POPWINDOW_WIDTH, 244)];
    m_Picker.delegate=PickerDelegate;
    m_Picker.showsSelectionIndicator=YES;
    m_Picker.hidden=false;
    //[m_Picker selectRow:self.m_SelectedCheckFreq-1 inComponent:0 animated:true];
    
    //Show the popovercontrol
    UIViewController* popoverContent = [[UIViewController alloc] init];
    popoverContent.contentSizeForViewInPopover = CGSizeMake(POPWINDOW_WIDTH, 264);
    UIView* popoverView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, POPWINDOW_WIDTH, 264)];
    popoverView.backgroundColor = [UIColor whiteColor];
    [popoverView addSubview:pickerToolbar];
    [popoverView addSubview:m_Picker];
    popoverContent.view = popoverView;
    
    
    //create a popover controller
    m_PopoverController = [[UIPopoverController alloc] initWithContentViewController:popoverContent];
    
    
    //Set the texts for each label
    //popoverContent.m_LabelShowInfo.numberOfLines=0;
    //[popoverContent.m_LabelShowInfo setText: showString];
    
    
    //Make it appears from the button's area
    //CGRect poprect=[self convertRect:self.m_Button.frame toView:self.contentView];
    //poprect.origin.x+=550; //move to the right side
    [self.m_PopoverController presentPopoverFromRect:rect
                                              inView:view
                            permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}
////////////////////////////////////////////////////////////////////////////////////////////////
-(void) Close
{
    [self.m_PopoverController dismissPopoverAnimated:true];
}
////////////////////////////////////////////////////////////////////////////////////////////
- (IBAction)OnClickCancel:(id)sender
{
    [self Close];
}

@end









@implementation iphonePicker

@synthesize m_Picker;

-(void) Init:(UITextField*)textfield Delegate:(id<UIPickerViewDelegate>)PickerDelegate DoneButtonTarget:(id)target DoneButtonAction:(SEL)handler
{
    
    self.textField=textfield;
    
    //Add the Date picker for the text field
    m_Picker=[[UIPickerView alloc] initWithFrame:CGRectMake(0, 45, POPWINDOW_WIDTH, 244)];
    m_Picker.delegate=PickerDelegate;
    m_Picker.showsSelectionIndicator=YES;
    m_Picker.hidden=false;

    
   // [m_Picker setDate:[NSDate date]];
   // [m_Picker addTarget:self action:@selector(updateTextField:) forControlEvents:UIControlEventValueChanged];
    
    
    
    
    //Init the toobar with cancel & done buttons
    UIToolbar *pickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    pickerToolbar.barStyle = UIBarStyleBlackOpaque;
    NSMutableArray *barItems = [[NSMutableArray alloc] init];
    
    UIBarButtonItem* cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemCancel target:self action:@selector(OnClickCancel:)];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:target action:handler];
    
    
    UIBarButtonItem* space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:Nil action:nil];
    
    [barItems addObject:cancelButton];
    [barItems addObject:space];
    [barItems addObject:doneButton];
    
    pickerToolbar.items = barItems;
    
    
    //Init the Security Level Picker
    [m_Picker setTag:10];
    //[m_Picker addTarget:self action:@selector(result) forControlEvents:UIControlEventValueChanged];
    //[m_Picker selectRow:self.m_SelectedCheckFreq-1 inComponent:0 animated:true];
    
    //Show the popovercontrol
    //UIViewController* popoverContent = [[UIViewController alloc] init];
    //popoverContent.contentSizeForViewInPopover = CGSizeMake(320, 264);
    UIView* popoverView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 264)];
    popoverView.backgroundColor = [UIColor whiteColor];
    [popoverView addSubview:pickerToolbar];
    [popoverView addSubview:m_Picker];
    
    
    [self.textField setInputView:popoverView];
}


-(void)updateTextField:(id)sender
{
}

- (IBAction)OnClickCancel:(id)sender
{
    [self.textField resignFirstResponder];
}
@end
