/*
 VideoViewController.h
 singSong
 
 Patrick Grennan
 grennan@nyu.edu
 
 This VC allows the user to record a video while simultaneously playing a song in the background.
 */

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

@class storedData;

@interface VideoViewController : UIViewController{
    storedData *bucket;
    MPMusicPlayerController *appMusicPlayer;
    MPMediaItemCollection *collection;
    NSTimer *progressTimer;
    AVCaptureSession *session;
    AVCaptureMovieFileOutput *output;
    AVURLAsset *video;
    NSMutableArray *videoArray;
    NSMutableArray *songBufferArray;
    UIAlertView *loadingAlert;
    AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;
    //CMTime recordingDuration;
}

@property (weak, nonatomic) IBOutlet UILabel *field1;
@property (weak, nonatomic) IBOutlet UIView *imagePreview;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UISlider *progressSlider;
@property (weak, nonatomic) IBOutlet UIButton *finishButton;
@property (weak, nonatomic) IBOutlet UIButton *redoButton;
@property (nonatomic, retain) NSTimer *progressTimer;
@property (strong, retain) AVCaptureSession *session;
@property (strong, retain) AVCaptureMovieFileOutput *output;
@property (strong, retain) AVURLAsset *video;
@property (nonatomic, retain) NSMutableArray *videoArray;
@property (nonatomic, retain) NSMutableArray *songBufferArray;

- (IBAction)playPause:(id)sender;
- (IBAction)finishMovie:(id)sender;
- (IBAction)redoScene:(id)sender;
- (void) updateSlider;
- (void) resetTimer:(NSTimer *)timer;
- (NSURL *) tempFileURL;
- (void) startRecording;
- (void) stopRecording;
- (void) saveVideoToAlbum:(NSString *)path;
- (void) video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;
@end
