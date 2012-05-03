/*
 storedData.h
 singSong
 
 Patrick Grennan
 grennan@nyu.edu
 
 This is a singleton class that serves as a shared data source for all of the VCs of the app.
 */

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface storedData : NSObject{
    NSNumber *count;
    NSURL *url;
    NSString *title;
    NSString *artist;
    MPMediaItemArtwork *artwork;
    MPMediaItemCollection *collection;
    NSNumber *duration;
    //MPMusicPlayerController *appMusicPlayer;
}

@property (nonatomic, retain) NSNumber *count;

// These are properties that will be edited solely by the MusicVC when the user picks a song
@property (nonatomic, retain) NSURL *url;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *artist;
@property (nonatomic, retain) MPMediaItemArtwork *artwork;
@property (nonatomic, retain) MPMediaItemCollection *collection;
@property (nonatomic, retain) NSNumber *duration;
//@property (nonatomic, retain) MPMusicPlayerController *appMusicPlayer;

+ (storedData *) sharedStore;

@end
