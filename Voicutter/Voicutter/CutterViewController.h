//
//  CutterViewController.h
//  Voicutter
//
//  Created by zhouyi on 15/10/13.
//  Copyright © 2015年 yiwanjun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <EZAudio/EZAudio.h>
#import "VoiPlot.h"

/**
 Here's the default audio file included with the example
 */
#define kAudioFileDefault [[NSBundle mainBundle] pathForResource:@"simple-drum-beat" ofType:@"wav"]

@interface CutterViewController : UIViewController
#pragma mark - Components
/**
 The EZAudioFile representing of the currently selected audio file
 */
@property (nonatomic,strong) EZAudioFile *audioFile;

/**
 The CoreGraphics based audio plot
 */
@property (nonatomic,weak) IBOutlet VoiPlot *audioPlot;


/**
 A BOOL indicating whether or not we've reached the end of the file
 */
@property (nonatomic,assign) BOOL eof;

#pragma mark - UI Extras
/**
 A label to display the current file path with the waveform shown
 */
@property (nonatomic,weak) IBOutlet UILabel *filePathLabel;

@property(strong,nonatomic)NSURL *songUrl;

@end
