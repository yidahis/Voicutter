//
//  CutterViewController.m
//  Voicutter
//
//  Created by zhouyi on 15/10/13.
//  Copyright © 2015年 yiwanjun. All rights reserved.
//


#define EXPORT_NAME @"exported.caf"

#import "CutterViewController.h"


@interface CutterViewController ()

@end

@implementation CutterViewController{
    NSURL *_assetURL;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //
    // Setup the AVAudioSession. EZMicrophone will not work properly on iOS
    // if you don't do this!
    //
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *error;
    [session setCategory:AVAudioSessionCategoryPlayback error:&error];
    if (error)
    {
        NSLog(@"Error setting up audio session category: %@", error.localizedDescription);
    }
    [session setActive:YES error:&error];
    if (error)
    {
        NSLog(@"Error setting up audio session active: %@", error.localizedDescription);
    }
    
    
    self.player = [EZAudioPlayer audioPlayerWithDelegate:self];
    self.player.volume = 1.0f;
    
    //
    // Customizing the audio plot's look
    //
    // Background color
    self.audioPlot.backgroundColor = [UIColor colorWithRed: 0.169 green: 0.643 blue: 0.675 alpha: 1];
    // Waveform color
    self.audioPlot.color           = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    // Plot type
    self.audioPlot.plotType        = EZPlotTypeBuffer;
    // Fill
    self.audioPlot.shouldFill      = YES;
    // Mirror
    self.audioPlot.shouldMirror    = YES;
    // No need to optimze for realtime
    self.audioPlot.shouldOptimizeForRealtimePlot = NO;
    // Customize the layer with a shadow for fun
    self.audioPlot.waveformLayer.shadowOffset = CGSizeMake(0.0, 1.0);
    self.audioPlot.waveformLayer.shadowRadius = 0.0;
    self.audioPlot.waveformLayer.shadowColor = [UIColor colorWithRed: 0.069 green: 0.543 blue: 0.575 alpha: 1].CGColor;
    self.audioPlot.waveformLayer.shadowOpacity = 1.0;
    
    //
    // Load in the sample file
    //
    [self openFileWithFilePathURL:[NSURL URLWithString:self.filePath]];
    
    
    
    
}

//------------------------------------------------------------------------------
#pragma mark - Action Extensions
//------------------------------------------------------------------------------

- (void)openFileWithFilePathURL:(NSURL*)filePathURL
{
    
    self.audioFile          = [EZAudioFile audioFileWithURL:filePathURL];
    self.eof                = NO;
    self.filePathLabel.text = filePathURL.lastPathComponent;
    
    // Plot the whole waveform
    self.audioPlot.plotType     = EZPlotTypeBuffer;
    self.audioPlot.shouldFill   = YES;
    self.audioPlot.shouldMirror = YES;
    self.audioPlot.gain = 2.5f;
    __weak typeof (self) weakSelf = self;
    [self.audioFile getWaveformDataWithCompletionBlock:^(float **waveformData,
                                                         int length)
     {
         NSLog(@"%d",length);
         [weakSelf.audioPlot updateBuffer:waveformData[0]
                           withBufferSize:length];
     }];
}

//------------------------------------------------------------------------------


//------------------------------------------------------------------------------
#pragma mark - EZAudioPlayerDelegate
//------------------------------------------------------------------------------

- (void) audioPlayer:(EZAudioPlayer *)audioPlayer
         playedAudio:(float **)buffer
      withBufferSize:(UInt32)bufferSize
withNumberOfChannels:(UInt32)numberOfChannels
         inAudioFile:(EZAudioFile *)audioFile
{
    __weak typeof (self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
//        [weakSelf.playingAudioPlot updateBuffer:buffer[0]
//                                 withBufferSize:bufferSize];
    });
}

//------------------------------------------------------------------------------

- (void)audioPlayer:(EZAudioPlayer *)audioPlayer
    updatedPosition:(SInt64)framePosition
        inAudioFile:(EZAudioFile *)audioFile
{
    __weak typeof (self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
//        weakSelf.currentTimeLabel.text = [audioPlayer formattedCurrentTime];
    });
}


- (void)cutterBegain{
    
    // set up an AVAssetReader to read from the iPod Library
    
    AVURLAsset *songAsset = [AVURLAsset URLAssetWithURL:_assetURL options:nil];
    
    NSError *assetError = nil;
    AVAssetReader *assetReader = [AVAssetReader assetReaderWithAsset:songAsset
                                                               error:&assetError]
    ;
    if (assetError) {
        NSLog (@"error: %@", assetError);
        return;
    }
    
    AVAssetReaderOutput *assetReaderOutput = [AVAssetReaderAudioMixOutput
                                              assetReaderAudioMixOutputWithAudioTracks:songAsset.tracks
                                              audioSettings: nil]
    ;
    if (! [assetReader canAddOutput: assetReaderOutput]) {
        NSLog (@"can't add reader output... die!");
        return;
    }
    [assetReader addOutput: assetReaderOutput];
    
    NSArray *dirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectoryPath = [dirs objectAtIndex:0];
    NSString *exportPath = [documentsDirectoryPath stringByAppendingPathComponent:EXPORT_NAME] ;
    if ([[NSFileManager defaultManager] fileExistsAtPath:exportPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:exportPath error:nil];
    }
    NSURL *exportURL = [NSURL fileURLWithPath:exportPath];
    AVAssetWriter *assetWriter = [AVAssetWriter assetWriterWithURL:exportURL
                                                          fileType:AVFileTypeCoreAudioFormat
                                                             error:&assetError]
    ;
    if (assetError) {
        NSLog (@"error: %@", assetError);
        return;
    }
    AudioChannelLayout channelLayout;
    memset(&channelLayout, 0, sizeof(AudioChannelLayout));
    channelLayout.mChannelLayoutTag = kAudioChannelLayoutTag_Stereo;
    NSDictionary *outputSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithInt:kAudioFormatLinearPCM], AVFormatIDKey,
                                    [NSNumber numberWithFloat:44100.0], AVSampleRateKey,
                                    [NSNumber numberWithInt:2], AVNumberOfChannelsKey,
                                    [NSData dataWithBytes:&channelLayout length:sizeof(AudioChannelLayout)], AVChannelLayoutKey,
                                    [NSNumber numberWithInt:16], AVLinearPCMBitDepthKey,
                                    [NSNumber numberWithBool:NO], AVLinearPCMIsNonInterleaved,
                                    [NSNumber numberWithBool:NO],AVLinearPCMIsFloatKey,
                                    [NSNumber numberWithBool:NO], AVLinearPCMIsBigEndianKey,
                                    nil];
    AVAssetWriterInput *assetWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio
                                                                              outputSettings:outputSettings]
    ;
    if ([assetWriter canAddInput:assetWriterInput]) {
        [assetWriter addInput:assetWriterInput];
    } else {
        NSLog (@"can't add asset writer input... die!");
        return;
    }
    
    assetWriterInput.expectsMediaDataInRealTime = NO;
    
    [assetWriter startWriting];
    [assetReader startReading];
    
    AVAssetTrack *soundTrack = [songAsset.tracks objectAtIndex:0];
    CMTime startTime = CMTimeMake (0, soundTrack.naturalTimeScale);
    [assetWriter startSessionAtSourceTime: startTime];
    
    __block UInt64 convertedByteCount = 0;
    
    dispatch_queue_t mediaInputQueue = dispatch_queue_create("mediaInputQueue", NULL);
    [assetWriterInput requestMediaDataWhenReadyOnQueue:mediaInputQueue
                                            usingBlock: ^
     {
         // NSLog (@"top of block");
         while (assetWriterInput.readyForMoreMediaData) {
             CMSampleBufferRef nextBuffer = [assetReaderOutput copyNextSampleBuffer];
             if (nextBuffer) {
                 // append buffer
                 [assetWriterInput appendSampleBuffer: nextBuffer];
                 //				NSLog (@"appended a buffer (%d bytes)",
                 //					   CMSampleBufferGetTotalSampleSize (nextBuffer));
                 convertedByteCount += CMSampleBufferGetTotalSampleSize (nextBuffer);
                 // oops, no
                 // sizeLabel.text = [NSString stringWithFormat: @"%ld bytes converted", convertedByteCount];
                 
                 NSNumber *convertedByteCountNumber = [NSNumber numberWithLong:convertedByteCount];
                 [self performSelectorOnMainThread:@selector(updateSizeLabel:)
                                        withObject:convertedByteCountNumber
                                     waitUntilDone:NO];
             } else {
                 // done!
                 [assetWriterInput markAsFinished];
                 [assetWriter finishWriting];
                 [assetReader cancelReading];
                 NSDictionary *outputFileAttributes = [[NSFileManager defaultManager]
                                                       attributesOfItemAtPath:exportPath
                                                       error:nil];
                 NSLog (@"done. file size is %llu",
                        [outputFileAttributes fileSize]);
                 NSNumber *doneFileSize = [NSNumber numberWithLong:[outputFileAttributes fileSize]];
                 [self performSelectorOnMainThread:@selector(updateCompletedSizeLabel:)
                                        withObject:doneFileSize
                                     waitUntilDone:NO];
                 AVURLAsset *songAsset = [AVURLAsset URLAssetWithURL:exportURL options:nil];
                 //				exportPath
                 NSString *exportPath1 = [documentsDirectoryPath stringByAppendingPathComponent:@"bbb.m4a"] ;
                 [self exportAsset:songAsset toFilePath:exportPath1];
                 
                 
                 
             }
         }
         
     }];

}

- (BOOL)exportAsset:(AVAsset *)avAsset toFilePath:(NSString *)filePath {
    
    // we need the audio asset to be at least 50 seconds long for this snippet
    CMTime assetTime = [avAsset duration];
    Float64 duration = CMTimeGetSeconds(assetTime);
    if (duration < 20.0) return NO;
    
    // get the first audio track
    NSArray *tracks = [avAsset tracksWithMediaType:AVMediaTypeAudio];
    if ([tracks count] == 0) return NO;
    
    AVAssetTrack *track = [tracks objectAtIndex:0];
    
    // create the export session
    // no need for a retain here, the session will be retained by the
    // completion handler since it is referenced there
    AVAssetExportSession *exportSession = [AVAssetExportSession
                                           exportSessionWithAsset:avAsset
                                           presetName:AVAssetExportPresetAppleM4A];
    if (nil == exportSession) return NO;
    
    // create trim time range - 20 seconds starting from 30 seconds into the asset
    CMTime startTime = CMTimeMake(30, 1);
    CMTime stopTime = CMTimeMake(50, 1);
    CMTimeRange exportTimeRange = CMTimeRangeFromTimeToTime(startTime, stopTime);
    
    // create fade in time range - 10 seconds starting at the beginning of trimmed asset
    CMTime startFadeInTime = startTime;
    CMTime endFadeInTime = CMTimeMake(40, 1);
    CMTimeRange fadeInTimeRange = CMTimeRangeFromTimeToTime(startFadeInTime,
                                                            endFadeInTime);
    
    // setup audio mix
    AVMutableAudioMix *exportAudioMix = [AVMutableAudioMix audioMix];
    AVMutableAudioMixInputParameters *exportAudioMixInputParameters =
    [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:track];
    
    [exportAudioMixInputParameters setVolumeRampFromStartVolume:0.0 toEndVolume:1.0
                                                      timeRange:fadeInTimeRange];
    exportAudioMix.inputParameters = [NSArray
                                      arrayWithObject:exportAudioMixInputParameters];
    
    // configure export session  output with all our parameters
    exportSession.outputURL = [NSURL fileURLWithPath:filePath]; // output path
    exportSession.outputFileType = AVFileTypeAppleM4A; // output file type
    exportSession.timeRange = exportTimeRange; // trim time range
    exportSession.audioMix = exportAudioMix; // fade in audio mix
    
    // perform the export
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        
        if (AVAssetExportSessionStatusCompleted == exportSession.status) {
            NSLog(@"AVAssetExportSessionStatusCompleted");
        } else if (AVAssetExportSessionStatusFailed == exportSession.status) {
            // a failure may happen because of an event out of your control
            // for example, an interruption like a phone call comming in
            // make sure and handle this case appropriately
            NSLog(@"AVAssetExportSessionStatusFailed");
        } else {
            NSLog(@"Export Session Status: %ld", (long)exportSession.status);
        }
    }];
    
    return YES;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
