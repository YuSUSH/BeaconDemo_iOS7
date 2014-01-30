//
//  ImageTableCell.m
//  BeaconDemo_iOS7
//
//  Created by Yu Liu on 30/01/14.
//
//

#import "ImageTableCell.h"
#import "BeaconDemoAppDelegate.h"


@implementation ImageTableCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    
    //Init the ImageView object
    self.personalImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 2, 50, 50)];
    [self.contentView addSubview:self.personalImage];
    
    
    //Init name Label
    self.NameLabel=[[UILabel alloc] initWithFrame:CGRectMake(75, 3, 190, 25)];
    [self.NameLabel setFont:[UIFont fontWithName:@"Helvetica Neue Light" size:26]];
    [self.contentView addSubview:self.NameLabel];
    
    //Init the time label
    self.timeLabel=[[UILabel alloc] initWithFrame:CGRectMake(75, 20, 190, 25)];
    [self.timeLabel setFont:[UIFont fontWithName:@"Helvetica Neue" size:15]];
    [self.contentView addSubview:self.timeLabel];
    
    //Init the in/out label
    self.inoutLabel=[[UILabel alloc] initWithFrame:CGRectMake(255, 5, 40, 40)];
    [self.NameLabel setFont:[UIFont fontWithName:@"Helvetica Neue" size:19]];
    [self.contentView addSubview:self.inoutLabel];
    
    return self;
}

-(void) setColorWhenOut
{
    //all set dark color
    [self.NameLabel setTextColor:RGB_COLOR(77, 77, 77, 1.0f)];
    [self.timeLabel setTextColor:RGB_COLOR(77, 77, 77, 1.0f)];
    [self.inoutLabel setTextColor:RGB_COLOR(77, 77, 77, 1.0f)];
    
    //white color
    [self setBackgroundColor:RGB_COLOR(255, 255, 255, 1.0f)];
}

-(void) setColorWhenIn
{
    //all set white color
    [self.NameLabel setTextColor:RGB_COLOR(255, 255, 255, 1.0f)];
    [self.timeLabel setTextColor:RGB_COLOR(255, 255, 255, 1.0f)];
    [self.inoutLabel setTextColor:RGB_COLOR(255, 255, 255, 1.0f)];
    
    //green color
    [self setBackgroundColor:RGB_COLOR(103, 186, 79, 1.0f)];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
