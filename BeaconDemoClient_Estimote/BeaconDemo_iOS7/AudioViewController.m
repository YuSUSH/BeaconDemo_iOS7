//
//  AudioViewController.m
//  BeaconDemo_iOS7
//
//  Created by Yu Liu on 18/10/13.
//
//

#import "AudioViewController.h"

@interface AudioViewController ()

@end

@implementation AudioViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)PlayRingtone
{
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *filePath = [mainBundle pathForResource:@"ringtone"
                                              ofType:@"mp3"];
    NSData *fileData = [NSData dataWithContentsOfFile:filePath];
    NSError *error = nil;
    /* Start the audio player */
    self.audioPlayer = [[AVAudioPlayer alloc] initWithData:fileData
                                                     error:&error];
    /* Did we get an instance of AVAudioPlayer? */
    if (self.audioPlayer != nil)
    {
        /* Set the delegate and start playing */
        self.audioPlayer.delegate = self;
        if ([self.audioPlayer prepareToPlay] &&
            [self.audioPlayer play])
        {
            /* Successfully started playing */
        }
        else
        {
            /* Failed to play */
        }
    }
    else
    {
        /* Failed to instantiate AVAudioPlayer */
    }
}

@end
