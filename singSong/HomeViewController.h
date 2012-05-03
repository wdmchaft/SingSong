/*
 HomeViewController.h
 singSong
 
 Patrick Grennan
 grennan@nyu.edu
 
 This VC serves as the landing page and the link between the Music VC and Video VC.
 */

#import <UIKit/UIKit.h>

@class storedData;

@interface HomeViewController : UIViewController{
    storedData *bucket;
}

@property (weak, nonatomic) IBOutlet UILabel *firstField;
@property (weak, nonatomic) IBOutlet UILabel *secondField;
@property (weak, nonatomic) IBOutlet UIImageView *albumArt;
@property (weak, nonatomic) IBOutlet UIButton *songButton;
@property (weak, nonatomic) IBOutlet UIButton *videoButton;


- (IBAction)pickSong:(id)sender;
- (IBAction)pickVideo:(id)sender;


@end
