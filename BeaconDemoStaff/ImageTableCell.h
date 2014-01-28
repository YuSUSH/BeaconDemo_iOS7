//
//  ImageTableCell.h
//  BeaconDemo_iOS7
//
//  Created by Yu Liu on 28/01/14.
//
//

#import <UIKit/UIKit.h>

@interface ImageTableCell : UITableViewCell

@property (strong, nonatomic) UIImageView *personalImage;
@property (strong, nonatomic) UILabel     *NameLabel;
@property (strong, nonatomic) UILabel     *timeLabel;
@property (strong, nonatomic) UILabel     *inoutLabel;

-(void) setColorWhenIn;
-(void) setColorWhenOut;

@end
