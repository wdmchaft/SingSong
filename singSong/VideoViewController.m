/*
 VideoViewController.h
 singSong
 
 Patrick Grennan
 grennan@nyu.edu
 
 This VC allows the user to record a video while simultaneously playing a song in the background.
 */

#import <AssetsLibrary/AssetsLibrary.h>
#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "VideoViewController.h"
#import "storedData.h"

@interface VideoViewController (FileOutputDelegate) <AVCaptureFileOutputRecordingDelegate>

@end

@implementation VideoViewController
@synthesize field1;
@synthesize imagePreview;
@synthesize playButton;
@synthesize progressSlider;
@synthesize finishButton;
@synthesize redoButton;
@synthesize progressTimer;
@synthesize session;
@synthesize output;
@synthesize video;
@synthesize videoArray;
@synthesize songBufferArray;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UINavigationItem *n = [self navigationItem];
        [n setTitle:@"Record Your Video!"];
        self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
        
        // Sleep mode is disabled in this view so that the app does not sleep while recording a video
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
        
    }
    return self;
}




- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Loading the singleton for access to shared Data
    bucket = [storedData sharedStore];
    
    [field1 setText:@""];
    
    // The finish button and the undo button will only be enabled when playback is paused
    [finishButton setEnabled:NO];
    [redoButton setEnabled:NO];
    
    // Borrowing the collection from the Music VC, the appMusicPlayer controls audio playback
    appMusicPlayer = [MPMusicPlayerController applicationMusicPlayer];
    collection = [bucket collection];
    
    // This will hold the scenes that the user shoots for later concatenation
    videoArray = [[NSMutableArray alloc] init];
    
    // This will hold the pause points that a user designates between scenes
    songBufferArray = [[NSMutableArray alloc] init];
    [songBufferArray addObject:[NSNumber numberWithFloat:0.0]];
    
    float totalTime = [[bucket duration] floatValue];
    progressSlider.maximumValue = totalTime;
    
    
    //*** AV Initialization ***
    
    session = [[AVCaptureSession alloc] init];
	session.sessionPreset = AVCaptureSessionPresetMedium;
    
    // Creating and setting up the video preview layer
	CALayer *viewLayer = self.imagePreview.layer;
	//NSLog(@"viewLayer = %@", viewLayer);
    
	captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    
    // For Autorotation
    captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    
	captureVideoPreviewLayer.frame = self.imagePreview.bounds;
	[self.imagePreview.layer addSublayer:captureVideoPreviewLayer];
    
    // This can be extended here to feature a front-facing camera
	AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // Adding the input
	NSError *error = nil;
	AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
	if (!input) {
		NSLog(@"ERROR: trying to open camera: %@", error);
	}
	[session addInput:input];
    
    // Adding the output
    output = [[AVCaptureMovieFileOutput alloc] init];
    if (!output) {
        NSLog(@"ERROR: trying to add output %@", error);
    }
    [session addOutput:output];

    // This will prevent the user from recording video for longer than the song
    CMTime maxDuration = CMTimeMakeWithSeconds([[bucket duration] floatValue], 10);
    output.maxRecordedDuration = maxDuration;
    
	[session startRunning];
    
}




- (void)viewDidUnload
{
    [self setField1:nil];
    [self setPlayButton:nil];
    [self setImagePreview:nil];
    appMusicPlayer = nil;
    collection = nil;
    [self setProgressSlider:nil];
    [self setSession:nil];
    [self setOutput:nil];
    [self setVideo:nil];
    [self setFinishButton:nil];
    [self setVideoArray:nil];
    [self setSongBufferArray:nil];
    [self setRedoButton:nil];
    [super viewDidUnload];
}




- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // This allows for the view to autorotate
    
    float rotation;
    
    if (interfaceOrientation==UIInterfaceOrientationPortrait) {
        rotation = 0;
    } else
    if (interfaceOrientation==UIInterfaceOrientationLandscapeLeft) {
        rotation = M_PI/2;
    } else
    if (interfaceOrientation==UIInterfaceOrientationLandscapeRight) {
        rotation = -M_PI/2;
    }
    
    NSTimeInterval duration = 0.4;
    
    [UIView animateWithDuration:duration animations:^{
        imagePreview.transform = CGAffineTransformMakeRotation(rotation);
        imagePreview.frame = self.imagePreview.frame;
    }];
    
    return (interfaceOrientation == UIInterfaceOrientationLandscapeRight) || (interfaceOrientation == UIInterfaceOrientationPortrait);
    
    
    // This forces a portrait orientation
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
}




// This allows the user to synchronously play and pause the recording/playback
- (IBAction)playPause:(id)sender {
    [appMusicPlayer setQueueWithItemCollection:collection];
    
    [self resetTimer:progressTimer];
    
    // Pausing action
    if ([appMusicPlayer playbackState] == MPMusicPlaybackStatePlaying) {
        [appMusicPlayer pause];
        [playButton setImage:[UIImage imageNamed:@"playButton.png"] forState:UIControlStateNormal];
        [self stopRecording];
        
    } 
    // Playing action
    else {
        [appMusicPlayer play];
        [playButton setImage:[UIImage imageNamed:@"pauseButton.png"] forState:UIControlStateNormal];
        [self startRecording];
        
    }
}




// After the user is done recording, this finishes the movie by creating an AVComposition and sending it to the Photo Album
- (IBAction)finishMovie:(id)sender {
    [finishButton setEnabled:NO];
    
    loadingAlert = [[UIAlertView alloc] initWithTitle:@"Saving Video..." message:@"" delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
    [loadingAlert show];
    
    if(loadingAlert != nil) {
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        
        indicator.center = CGPointMake(loadingAlert.bounds.size.width/2, loadingAlert.bounds.size.height-45);
        [indicator startAnimating];
        [loadingAlert addSubview:indicator];
    }
    
    // Getting the song asset
    AVURLAsset *song = [[AVURLAsset alloc] initWithURL:[bucket url] options:nil];
    //NSLog(@"Audio asset is: %@", song);
    //NSLog(@"Video asset is: %@",video);
    
    // This is the finial composition that will hold all the AV tracks
    AVMutableComposition* mixComposition = [AVMutableComposition composition];
    
    AVMutableCompositionTrack *videoCompTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    
    // Video Loop: adds all the scenes to the videoCompTrack
    CMTime nextClipStartTime = kCMTimeZero;
    
    for (AVURLAsset *asset in videoArray) {
        //NSLog(@"Asset is: %@", asset);
                
        CMTimeRange clipTime = CMTimeRangeMake(kCMTimeZero, asset.duration);
        
        [videoCompTrack insertTimeRange:clipTime ofTrack:[[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:nextClipStartTime error:nil];
        
        // This update handles for the slight delay between the audio and video cutting between scenes
        nextClipStartTime = CMTimeAdd(nextClipStartTime, asset.duration);
        nextClipStartTime = CMTimeAdd(nextClipStartTime, CMTimeMake(1,11));
    }
    
    // This would be used to force a one-shot track instead of the loop
    /*
    CMTimeRange timeRange = CMTimeRangeMake(kCMTimeZero,video.duration);
    AVMutableCompositionTrack *videoCompTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [videoCompTrack insertTimeRange:timeRange ofTrack:[[video tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:kCMTimeZero error:nil];
     */
    
    // This handles for the initial delay between the audio and the video playback
    CMTimeRange timeRange = CMTimeRangeMake(kCMTimeZero, song.duration);
    CMTime audioSyncStart = CMTimeMake(1, 3);
    
    AVMutableCompositionTrack *songCompTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    [songCompTrack insertTimeRange:timeRange ofTrack:[[song tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:audioSyncStart error:nil];
    
    //NSLog(@"AV Composition is: %@", mixComposition);
    
    NSString* outputFileName = @"outputFile.mov";
    NSString* outputFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:outputFileName];
    NSURL*    outputFileUrl = [NSURL fileURLWithPath:outputFilePath];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:outputFilePath]) 
        [[NSFileManager defaultManager] removeItemAtPath:outputFilePath error:nil];
    
    // Initializing the export session and sending it to the photo Album
    AVAssetExportSession* _assetExport = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetMediumQuality];   
    _assetExport.outputFileType = @"com.apple.quicktime-movie";
    _assetExport.outputURL = outputFileUrl;
    
    [_assetExport exportAsynchronouslyWithCompletionHandler:
     ^(void ) {
         NSLog(@"Export Status %d %@", _assetExport.status, _assetExport.error);
         [self saveVideoToAlbum:outputFilePath]; 
     }];
    
}




// This allows for the user to reshoot scenes
- (IBAction)redoScene:(id)sender {
    
    if ([[bucket count] intValue] > 0){
        int index = [[bucket count] intValue]-1;
        NSNumber *tmp = [songBufferArray objectAtIndex:index];
        NSTimeInterval currTime = (NSTimeInterval)[tmp doubleValue];
        
        // "Rewinding" to the previous scene
        [appMusicPlayer setCurrentPlaybackTime:currTime];
        
        [videoArray removeObjectAtIndex:index];
        
        [bucket setCount:[NSNumber numberWithInt:[[bucket count] intValue] - 1]];
    }
}




- (void) viewDidDisappear:(BOOL)animated{
    [appMusicPlayer stop];
    if ([progressTimer isValid]) {
        [progressTimer invalidate];
    }
    progressTimer = nil;
}




// The following two functions control the updating slider showing the progress of the song
- (void)updateSlider {
    float curTime = (float)appMusicPlayer.currentPlaybackTime;
    
    // Could be used to display the remaining time on the device
    //[field1 setText:[NSString stringWithFormat:@"%f",curTime]];
    
    if ([progressSlider maximumValue] <= curTime) {
        NSLog(@"Stopping Recording this way");
        [self stopRecording];
    }
    
    [progressSlider setValue:curTime animated:YES];
    [progressSlider setNeedsDisplay];
}




- (void)resetTimer:(NSTimer *)timer {
    [progressTimer invalidate];
    progressTimer = nil;
    progressTimer = [NSTimer scheduledTimerWithTimeInterval:.5 target:self
                                                   selector:@selector(updateSlider)
                                                   userInfo:nil repeats:YES];
}




// This returns the local URLs that the scenes will be stored in
- (NSURL *) tempFileURL
{
    // Setting a unique fileName and incrementing the count
    NSString *fileName = [NSString stringWithFormat:(@"camera%d.mov"),[[bucket count] intValue]];
    [bucket setCount:[NSNumber numberWithInt:[[bucket count] intValue] + 1]];
    
    NSString *outputPath = [[NSString alloc] initWithFormat:@"%@%@", NSTemporaryDirectory(), fileName];
    NSURL *outputURL = [[NSURL alloc] initFileURLWithPath:outputPath];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:outputPath])
        [[NSFileManager defaultManager] removeItemAtPath:outputPath error:nil];
    
    return outputURL;
}




- (void) startRecording
{
    NSURL *url = [self tempFileURL];
    [output startRecordingToOutputFileURL:url recordingDelegate:self];
    //NSLog(@"Writing to: %@", url);
    
    //[finishButton setBackgroundColor:[UIColor grayColor]];
    [finishButton setEnabled:NO];
    [redoButton setEnabled:NO];
    
}




- (void) stopRecording
{
    if([output isRecording])
        [output stopRecording];
    
}






// The following two functions handle the saving of the video to the photo library
- (void) saveVideoToAlbum:(NSString *)path{
    NSLog(@"Saved video to the Album!");
    
    [loadingAlert dismissWithClickedButtonIndex:0 animated:YES];

    
    // Alerting the user of a successful saving and popping to the main view
    UIAlertView *successAlert = [[UIAlertView alloc] initWithTitle:@"Success!" 
                                                           message:@"Your video has been saved to your device's photo album!" 
                                                          delegate:nil 
                                                 cancelButtonTitle:@"OK"
                                                 otherButtonTitles:nil];
    [successAlert show];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
    
    if(UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(path)){
        UISaveVideoAtPathToSavedPhotosAlbum (path, self, @selector(video:didFinishSavingWithError: contextInfo:), nil);
    }
    
}




- (void) video: (NSString *) videoPath didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo {
    NSLog(@"Finished saving video with error: %@", error);
} 

@end

// Implementing the File output Delegate methods for the AVOutput
@implementation VideoViewController (FileOutputDelegate)

- (void)             captureOutput:(AVCaptureFileOutput *)captureOutput
didStartRecordingToOutputFileAtURL:(NSURL *)fileURL
                   fromConnections:(NSArray *)connections
{
    NSLog(@"Started Recording!");

}




- (void)              captureOutput:(AVCaptureFileOutput *)captureOutput
didFinishRecordingToOutputFileAtURL:(NSURL *)anOutputFileURL
                    fromConnections:(NSArray *)connections
                              error:(NSError *)error
{
    NSLog(@"Stopped Recording!");
    //NSLog(@"Recorded to: %@",anOutputFileURL);
    
    NSDictionary *options = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES]
                                                        forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    video = [[AVURLAsset alloc] initWithURL:anOutputFileURL options:options];
    
    // The max duration of the output is changed to reflect the duration of this clip
    CMTime songBuffer = CMTimeMakeWithSeconds((float)[appMusicPlayer currentPlaybackTime],10);
    CMTime maxDuration = CMTimeMakeWithSeconds([[bucket duration] floatValue], 10);
    output.maxRecordedDuration = CMTimeSubtract(maxDuration, songBuffer);    
    
    [videoArray addObject:video];
    
    // This initializes the stopping point for use stitching the AVURLAssets together in the finish function
    NSTimeInterval tmp = [appMusicPlayer currentPlaybackTime];
    NSNumber *otherSongBuffer = [NSNumber numberWithDouble:tmp];
    NSLog(@"Stop Point: %@", otherSongBuffer);
    [songBufferArray addObject:otherSongBuffer];
    
    //[finishButton setBackgroundColor:[UIColor blueColor]];
    [finishButton setEnabled:YES];
    [redoButton setEnabled:YES];
    
}

@end

