//
//  ImageTableCell.m
//  BeaconDemo_iOS7
//
//  Created by Yu Liu on 28/01/14.
//
//

#import "ImageTableCell.h"


@implementation ImageTableCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    
    //Init the ImageView object
    self.personalImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 50, 50)];
    [self.contentView addSubview:self.personalImage];
    
    
    //Init name Label
    self.NameLabel=[[UILabel alloc] initWithFrame:CGRectMake(55, 0, 190, 25)];
    [self.contentView addSubview:self.NameLabel];
    
    //Init the time label
    self.timeLabel=[[UILabel alloc] initWithFrame:CGRectMake(55, 25, 190, 25)];
    [self.contentView addSubview:self.timeLabel];
    
    //Init the in/out label
    self.inoutLabel=[[UILabel alloc] initWithFrame:CGRectMake(245, 25, 40, 25)];
    [self.contentView addSubview:self.inoutLabel];
    
    return self;
}

-(void) updateImageDisplay
{
    //show picture
    NSString *picture_url= [NSString stringWithFormat:@"%@%@",
                            @"http://ble.sandbox.net.nz/myforum/upload_image/",
                            self.iconfilename ];
    
    NSURL *url = [NSURL URLWithString:picture_url];
    NSData *data = [NSData dataWithContentsOfURL:url];
    UIImage *img = [[UIImage alloc] initWithData:data];
    CGSize size = img.size;
    [self.personalImage setImage:img];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
