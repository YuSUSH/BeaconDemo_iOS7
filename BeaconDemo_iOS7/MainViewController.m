//
//  MainViewController.m
//  BeaconDemo_iOS7
//
//  Created by Yu Liu on 18/10/13.
//
//

#import "MainViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.title=@"Bluetooth Low Energy for iOS7 Demo";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 2;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:[NSString stringWithFormat:@"%d_Cell",indexPath.row]];
    
    switch(indexPath.row)
    {
    case 0:
        cell.textLabel.text = @"BLE Device to iOS";
        cell.detailTextLabel.text = @"Detail ...";
        break;
    case 1:
        cell.textLabel.text = @"iOS to iOS (iOS 7 Beacon API)";
        cell.detailTextLabel.text = @"Detail ...";
        break;
    default:
        cell.textLabel.text = @"";
        cell.detailTextLabel.text = @"";
        break;
    }
    
    return cell;
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row==0)
        [self performSegueWithIdentifier:@"SegueToBLETagView" sender:self]; //transfer to Tag View
    
    if(indexPath.row==1)
        [self performSegueWithIdentifier:@"SegueToBeaconView" sender:self]; //transfer to Beacon View
    
    
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"segue=%@, sender=%@.", segue.identifier, sender);
}


@end
