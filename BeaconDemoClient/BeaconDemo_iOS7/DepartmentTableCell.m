//
//  DepartmentTableCell.m
//  BeaconDemo_iOS7
//
//  Created by Yu Liu on 29/01/14.
//
//

#import "DepartmentTableCell.h"

@implementation DepartmentTableCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    
    //Init the in/out label
    self.strokeLabel=[[UILabel alloc] initWithFrame:CGRectMake(265, 5, 40, 40)];
    [self.strokeLabel setFont:[UIFont fontWithName:@"Helvetica Neue" size:19]];
    [self.strokeLabel setText:@">"];
    [self.contentView addSubview:self.strokeLabel];
    
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
