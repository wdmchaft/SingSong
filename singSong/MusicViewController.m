/*
 MusicViewController.m
 singSong
 
 Patrick Grennan
 grennan@nyu.edu
 
 This VC prompts for the user to select a song from her/his music library and allows the user to preview the song.
 */

#import "MusicViewController.h"
#import "HomeViewController.h"
#import "storedData.h"

@interface MusicViewController ()

@end

@implementation MusicViewController

@synthesize countText;
@synthesize songTitle;
@synthesize songArtist;
@synthesize albumArtwork;
@synthesize playButton;
@synthesize count;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UINavigationItem *n = [self navigationItem];
        [n setTitle:@"Pick Your Song!"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Initializing the data storage singleton
    bucket = [storedData sharedStore];
    
    appMusicPlayer = [MPMusicPlayerController applicationMusicPlayer];
    collection = nil;
    
}

- (void)viewDidUnload
{
    [self setCountText:nil];
    [self setSongTitle:nil];
    [self setSongArtist:nil];
    [self setAlbumArtwork:nil];
    [self setPlayButton:nil];
    appMusicPlayer = nil;
    collection = nil;
    [super viewDidUnload];
}

// This will load the album artwork and album animation (if a song has been selected)
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    //[playButton setImage:[UIImage imageNamed:@"playButton.png"] forState:UIControlStateNormal];
    
    if ([bucket artwork]) {
        NSLog(@"passed");
        UIImage *artworkImage = [[bucket artwork] imageWithSize: CGSizeMake (133, 133)];
        [albumArtwork setImage:artworkImage];
    } else {
        [albumArtwork setImage:[UIImage imageNamed:@"noAlbumArtwork.png"]];
    }
    
    
    [songTitle setText:[bucket title]];
    [songArtist setText:[bucket artist]];
}

// This will stop the music player so that this MP doesn't interfere with the MP in the Video VC
- (void) viewDidDisappear:(BOOL)animated{
    [appMusicPlayer stop];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


// This instantiates the music picker and presents it modially
- (IBAction)increment:(id)sender {
    count += 1;
    //[countText setText:[[NSNumber numberWithInt:count] stringValue]];
    
    [playButton setImage:[UIImage imageNamed:@"playButton.png"] forState:UIControlStateNormal];
    [countText setText:@"Preview your song below!"];

    // Instantiating the music picker
    MPMediaPickerController *mediaPicker = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeMusic];
    
    if (mediaPicker != nil) {
        
        NSLog(@"Media picker successfully instantiated.");
        mediaPicker.delegate = self;
        mediaPicker.allowsPickingMultipleItems = NO;
        //mediaPicker.prompt = @"Pick your song!";
        
        [self.navigationController presentModalViewController:mediaPicker animated:YES];
    }
    else {
        NSLog(@"Could not instantiate the media picker");
    }
    
}

// Play/Pause control so that the user can preview her or his selected song
- (IBAction)playPause:(id)sender {
    [appMusicPlayer setQueueWithItemCollection:collection];
    
    if ([appMusicPlayer playbackState] == MPMusicPlaybackStatePlaying) {
        [appMusicPlayer pause];
        [playButton setImage:[UIImage imageNamed:@"playButton.png"] forState:UIControlStateNormal];
        
    } else {
        [appMusicPlayer play];
        [playButton setImage:[UIImage imageNamed:@"pauseButton.png"] forState:UIControlStateNormal];
        
    }        
}


// Required by the MPMusicPicker class, this f'n handles the return of the data back to the VC
// and loads the data into the shared data singleton.
- (void) mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection {
    
    NSLog(@"Media picker returned");
    
    NSURL *itemURL = nil;
    NSString *itemTitle = nil;
    NSString *itemArtist = nil;
    MPMediaItemArtwork *itemArtwork = nil;
    NSNumber *itemDuration = nil;
    
    
    for (MPMediaItem *thisItem in mediaItemCollection.items){
        itemURL = [thisItem valueForProperty:MPMediaItemPropertyAssetURL];
        itemTitle = [thisItem valueForProperty:MPMediaItemPropertyTitle];
        itemArtist = [thisItem valueForProperty:MPMediaItemPropertyArtist];
        itemArtwork = [thisItem valueForProperty:MPMediaItemPropertyArtwork];
        itemDuration = [thisItem valueForProperty:MPMediaItemPropertyPlaybackDuration];
        
        NSLog(@"Item URL: %@", itemURL);
        NSLog(@"Item Title: %@", itemTitle);
        NSLog(@"Item Artist: %@", itemArtist);
        NSLog(@"Item Artwork: %@", itemArtwork);
        NSLog(@"Item Duration: %@", itemDuration);
        
    }
    
    UIImage *artworkImage = [itemArtwork imageWithSize: CGSizeMake (133, 133)];
    [albumArtwork setImage:artworkImage];
    
    [songTitle setText:itemTitle];
    [songArtist setText:itemArtist];
    
    collection = mediaItemCollection;
    
    [bucket setUrl:itemURL];
    [bucket setTitle:itemTitle];
    [bucket setArtist:itemArtist];
    [bucket setArtwork:itemArtwork];
    [bucket setCollection:collection];
    [bucket setDuration:itemDuration];
    
    [self dismissModalViewControllerAnimated: YES];
    
}

-(void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker {
    NSLog(@"Picker Canceled");
    [self dismissModalViewControllerAnimated:YES];
}

@end
