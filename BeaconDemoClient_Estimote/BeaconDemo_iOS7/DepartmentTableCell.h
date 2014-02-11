//
//  DepartmentTableCell.h
//  BeaconDemo_iOS7
//
//  Created by Yu Liu on 29/01/14.
//
//

#import <UIKit/UIKit.h>

@interface DepartmentTableCell : UITableViewCell

@property (strong, nonatomic) UILabel     *strokeLabel;

-(void) setColorWhenIn;
-(void) setColorWhenOut;

@end

