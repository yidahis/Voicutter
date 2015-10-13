//
//  VTMViewController.h
//  VTM
//
//  Created by jinhu zhang on 11-1-15.
//  Copyright 2011 no. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
@interface ViewController : UIViewController <MPMediaPickerControllerDelegate> {
    MPMediaItem *song;
    
    UILabel *songLabel;
    UILabel *artistLabel;
    UILabel *sizeLabel;
    UIImageView *coverArtView;
    UIProgressView *conversionProgress;
    
}
@property (nonatomic, retain) IBOutlet UILabel *songLabel;
@property (nonatomic, retain) IBOutlet UILabel *artistLabel;
@property (nonatomic, retain) IBOutlet UILabel *sizeLabel;
@property (nonatomic, retain) IBOutlet UIImageView *coverArtView;
@property (nonatomic, retain) IBOutlet UIProgressView *conversionProgress;

-(IBAction) chooseSongTapped: (id) sender;
-(IBAction) convertTapped: (id) sender;


@end

