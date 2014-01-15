//
//  NewAppintmentViewController.m
//  BeaconDemo_iOS7
//
//  Created by Yu Liu on 15/01/14.
//
//

#import "NewAppintmentViewController.h"
#import "BeaconDemoAppDelegate.h"

@interface NewAppintmentViewController ()

@end

@implementation NewAppintmentViewController
@synthesize allStaffs, staffPicker, selectedStaff;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    allStaffs=[[NSMutableArray alloc]init];
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
}

-(void)dismissKeyboard
{
    [self.textDescription resignFirstResponder];
}

-(void)viewWillAppear:(BOOL)animated
{

        
    NSURL *requestURL=[NSURL URLWithString:GET_ALL_STAFF_INFO_URL];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];
    
    //Set Post Data
    //GET_APPDELEGATE
    
    //Send request
    [request setHTTPMethod:@"POST"];
//    [request setHTTPBody:[NSData dataWithBytes:bytes length:strlen(bytes)]];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         if(error!=nil)
             return; //error
         
         NSLog(@"responseData: %@", data);
         
         //decode the response data
         NSMutableArray *jsonObjects = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
         
         allStaffs=jsonObjects; //save all the staffs info
     }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)OnClickStaffChoice:(UIButton *)sender
{
    //show the popup for staff name display
    staffPicker=[[PopoverPicker alloc] init];
    
    CGRect poprect=[self.view convertRect:self.btnStaffChoice.frame toView:self.view];
    poprect.origin.y+=30;
    
    [staffPicker Popup:self From:poprect InView:self.view
       DoneButtonTarget:self DoneButtonAction:(@selector(DoneStaffPicker:))];
    
    //display the selected index in the list
    [staffPicker.m_Picker selectRow:0 inComponent:0 animated:true];
}

-(IBAction) DoneStaffPicker:(id)sender
{
    [staffPicker Close]; //close the popover window
    
    int selected=[staffPicker.m_Picker selectedRowInComponent:0];
    
    selectedStaff=[allStaffs objectAtIndex:selected]; //save the selected staff info
    
    NSString *fullname;
    fullname=[NSString stringWithFormat:@"%@ %@",
    [selectedStaff valueForKey:@"givename"],
    [selectedStaff valueForKey:@"surname"] ];
    
    [self.btnStaffChoice setTitle:fullname forState:UIControlStateNormal];
    
}


- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if([pickerView isEqual:staffPicker.m_Picker]) //security level picker
    {
        
        NSString *surname, *givename, *fullname;
        surname=[[allStaffs objectAtIndex:row] valueForKey:@"surname"];
        givename=[[allStaffs objectAtIndex:row] valueForKey:@"givename"];
        
        fullname=[NSString stringWithFormat:@"%@ %@", givename, surname];
       
        return fullname;
    }
    else
        return @"";
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 40.0;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if([pickerView isEqual:self.staffPicker.m_Picker])
        return allStaffs.count; //5 types of truck
    else
        return 0;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}


- (IBAction)OnClickCancel:(UIButton *)sender
{
    //simple cancel this new appointment and back
    [self performSegueWithIdentifier:@"SegueCloseNewAppointment" sender:self];
}

- (IBAction)OnClickSubmit:(UIButton *)sender
{
    //Add a new record in appointment table in the DB
    [self addNewAppointment];
}


-(void) addNewAppointment
{
    
    NSURL *requestURL=[NSURL URLWithString:ADD_APPOINTMENT];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];
    
    //Set Post Data
    GET_APPDELEGATE
    
    const char *bytes = [[NSString stringWithFormat:@"client=%@&staff=%@&time=%@&description=%@",
                          appDelegate.CurrentUserID,
                          [selectedStaff valueForKey:@"userid"],
                          [NSDate date],
                          self.textDescription.text
                          ] UTF8String];
    
    
    //const char *bytes="time=010&staff=ryoko&description=gfhfhf+hgfhgfhghf+gfhfghfgfh&client=kkk";
    //For multiple POST data
    //NSString *key = [NSString stringWithFormat:@"key=%@&key2=%2", keyValue, key2value];
    
    //Send request
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[NSData dataWithBytes:bytes length:strlen(bytes)]];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         if(error!=nil)
             return; //error
         
         
        //try to add new appointment
        dispatch_queue_t mainQueue = dispatch_get_main_queue();
        dispatch_async(mainQueue, ^(void)
        {
            //Now come back to the main view
            [self performSegueWithIdentifier:@"SegueCloseNewAppointment" sender:self];
        });
     }];
}


@end
