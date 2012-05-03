/*
 storedData.m
 singSong
 
 Patrick Grennan
 grennan@nyu.edu
 
 This is a singleton class that serves as a shared data source for all of the VCs of the app.
 */

#import "storedData.h"

@implementation storedData

@synthesize count;
@synthesize url;
@synthesize title;
@synthesize artist;
@synthesize artwork;
@synthesize collection;
@synthesize duration;
//@synthesize appMusicPlayer;

- (id)init {
    self = [super init];
    if (self) {
        count = [NSNumber numberWithInt:0];
        url = nil;
        title = nil;
        artist = nil;
        artwork = nil;
        duration = nil;
    }
    return self;
}

+ (storedData *) sharedStore {
    static storedData *sharedStore = nil;
    if (!sharedStore) {
        sharedStore = [[super allocWithZone:nil] init];
    }
    
    return sharedStore;
}

+ (id)allocWithZone:(NSZone *)zone {
    return [self sharedStore];
}

@end
