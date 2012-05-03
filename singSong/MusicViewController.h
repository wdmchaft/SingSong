/*
 MusicViewController.h
 singSong
 
 Patrick Grennan
 grennan@nyu.edu
 
 This VC prompts for the user to select a song from her/his music library and allows the user to preview the song.
 */

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

@class storedData;

@interface MusicViewController : UIViewController <MPMediaPickerControllerDelegate>{
    storedData *bucket;
    int count;
    MPMusicPlayerController *appMusicPlayer;
    MPMediaItemCollection *collection;
}

@property (weak, nonatomic) IBOutlet UILabel *countText;
@property (weak, nonatomic) IBOutlet UILabel *songTitle;
@property (weak, nonatomic) IBOutlet UILabel *songArtist;
@property (weak, nonatomic) IBOutlet UIImageView *albumArtwork;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (nonatomic, assign) int count;


- (IBAction)increment:(id)sender;
- (IBAction)playPause:(id)sender;

@end
