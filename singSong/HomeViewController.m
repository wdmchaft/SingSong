/*
 HomeViewController.m
 singSong
 
 Patrick Grennan
 grennan@nyu.edu
 
 This VC serves as the landing page and the link between the Music VC and Video VC.
 */

#import "HomeViewController.h"
#import "MusicViewController.h"
#import "storedData.h"
#import "VideoViewController.h"

@interface HomeViewController ()

@end

@implementation HomeViewController
@synthesize firstField;
@synthesize secondField;
@synthesize albumArt;
@synthesize songButton;
@synthesize videoButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UINavigationItem *n = [self navigationItem];
        [n setTitle:@"SingSong!"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Initializing the singleton
    bucket = [storedData sharedStore];
    
    //[songButton setBackgroundColor:[UIColor blueColor]];
    //[videoButton setBackgroundColor:[UIColor grayColor]];
    [videoButton setEnabled:NO];
    
}

- (void)viewDidUnload
{
    [self setFirstField:nil];
    [self setSecondField:nil];
    [self setAlbumArt:nil];
    [self setSongButton:nil];
    [self setVideoButton:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) viewWillAppear:(BOOL)animated{
    //self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    
    
    [firstField setText:[bucket title]];
    [secondField setText:[bucket artist]];
                         
    UIImage *artworkImage = [[bucket artwork] imageWithSize: CGSizeMake (133, 133)];
    [albumArt setImage:artworkImage];
    [albumArt.layer setCornerRadius:15.0];
    
}

// Pushing the button pushes the Music Picker VC and enables the Video VC
- (IBAction)pickSong:(id)sender {
    [firstField setText:@"Picked Song!"];
    MusicViewController *mvc = [[MusicViewController alloc] init];
    
    [[self navigationController] pushViewController:mvc animated:YES];
    
    //[videoButton setBackgroundColor:[UIColor blueColor]];
    [videoButton setEnabled:YES];
}

// Pushing the Video VC
- (IBAction)pickVideo:(id)sender {
    [secondField setText:@"Picked Video!"];
    VideoViewController *vvc = [[VideoViewController alloc] init];
    
    [[self navigationController] pushViewController:vvc animated:YES];
}
@end
