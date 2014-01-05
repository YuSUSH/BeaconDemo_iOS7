//
//  AudioViewController.h
//  BeaconDemo_iOS7
//
//  Created by Yu Liu on 18/10/13.
//
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

//A UIViewController class with Audio playing function
@interface AudioViewController : UIViewController <AVAudioPlayerDelegate>

@property (nonatomic, strong) AVAudioPlayer *audioPlayer;

-(void)PlayRingtone;

@end
