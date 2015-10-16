//
//  VTMViewController.m
//  VTM
//
//  Created by jinhu zhang on 11-1-15.
//  Copyright 2011 no. All rights reserved.
//

#import "ViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import "CutterViewController.h"
#import "RecordViewController.h"

#define EXPORT_NAME @"exported.caf"
@implementation ViewController

@synthesize songLabel;
@synthesize artistLabel;
@synthesize sizeLabel;
@synthesize coverArtView;
@synthesize conversionProgress;

#pragma mark init/dealloc
//- (void)dealloc {
//    [super dealloc];
//}

#pragma mark vc lifecycle

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(recordFinsh:) name:kRecordFinsh object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)recordFinsh:(NSNotification*)noti{
    self.filePathLabel.text  = [NSString stringWithFormat:@"%@",noti.object];
    
    UInt64 convertedByteCount = [[self dataSize:noti.object] longValue];
    self.sizeLabel.text = [NSString stringWithFormat: @"%llu bytes converted", convertedByteCount];
}

- (NSNumber*)dataSize:(NSString*)path{
    NSDictionary *outputFileAttributes = [[NSFileManager defaultManager]
                                          attributesOfItemAtPath:path
                                          error:nil];
    NSLog (@"done. file size is %llu",
           [outputFileAttributes fileSize]);
    return [NSNumber numberWithLong:[outputFileAttributes fileSize]];
}

#pragma mark event handlers

-(IBAction) chooseSongTapped: (id) sender {
    MPMediaPickerController *pickerController =	[[MPMediaPickerController alloc]
                                                 initWithMediaTypes: MPMediaTypeMusic];
    pickerController.prompt = @"Choose song to export";
    pickerController.allowsPickingMultipleItems = NO;
    pickerController.delegate = self;
    [self presentModalViewController:pickerController animated:YES];
    
    
}

-(IBAction) convertTapped: (id) sender {
    UIStoryboard *board = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CutterViewController *vc = [board instantiateViewControllerWithIdentifier:@"CutterViewController"];
    vc.filePath = self.filePathLabel.text;
    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)recordTaped:(id)sender {
    UIStoryboard *board = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    RecordViewController *vc = [board instantiateViewControllerWithIdentifier:@"RecordViewController"];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
    
}

-(void) updateSizeLabel: (NSNumber*) convertedByteCountNumber {
    UInt64 convertedByteCount = [convertedByteCountNumber longValue];
    sizeLabel.text = [NSString stringWithFormat: @"%llu bytes converted", convertedByteCount];
}

-(void) updateCompletedSizeLabel: (NSNumber*) convertedByteCountNumber {
    UInt64 convertedByteCount = [convertedByteCountNumber longValue];
    sizeLabel.text = [NSString stringWithFormat: @"done. file size is %llu", convertedByteCount];
}


#pragma mark MPMediaPickerControllerDelegate
- (void)mediaPicker: (MPMediaPickerController *)mediaPicker
  didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection {
    [self dismissModalViewControllerAnimated:YES];
    if ([mediaItemCollection count] < 1) {
        return;
    }
    
    song = [[mediaItemCollection items] objectAtIndex:0] ;
    songLabel.hidden = NO;
    artistLabel.hidden = NO;
    coverArtView.hidden = NO;
    songLabel.text = [song valueForProperty:MPMediaItemPropertyTitle];
    artistLabel.text = [song valueForProperty:MPMediaItemPropertyArtist];
    coverArtView.image = [[song valueForProperty:MPMediaItemPropertyArtwork]
                          imageWithSize: coverArtView.bounds.size];
    
}

- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker {
    [self dismissModalViewControllerAnimated:YES];
}


- ( NSURL*) convertToMp3: (MPMediaItem *)item
{
    NSURL *url = [item valueForProperty:MPMediaItemPropertyAssetURL];
    
    AVURLAsset *songAsset = [AVURLAsset URLAssetWithURL:url options:nil];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *dirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectoryPath = [dirs objectAtIndex:0];
    
    NSLog (@"compatible presets for songAsset: %@",[AVAssetExportSession exportPresetsCompatibleWithAsset:songAsset]);
    
    NSArray *ar = [AVAssetExportSession exportPresetsCompatibleWithAsset: songAsset];
    NSLog(@"%@", ar);
    
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc]
                                      initWithAsset: songAsset
                                      presetName: AVAssetExportPresetAppleM4A];
    
    NSLog (@"created exporter. supportedFileTypes: %@", exporter.supportedFileTypes);
    
    exporter.outputFileType = @"com.apple.m4a-audio";
    
    NSString *exportFile = [documentsDirectoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.m4a",[song valueForProperty:MPMediaItemPropertyTitle]]];
    
    NSError *error1;
    
    if([fileManager fileExistsAtPath:exportFile])
    {
        [fileManager removeItemAtPath:exportFile error:&error1];
    }
    
    NSURL* exportURL = [NSURL fileURLWithPath:exportFile];
    
    exporter.outputURL = exportURL;
    
    // do the export
    [exporter exportAsynchronouslyWithCompletionHandler:^
     {
         NSData *data1 = [NSData dataWithContentsOfFile:exportFile];
         //NSLog(@"==================data1:%@",data1);
         
         
         int exportStatus = exporter.status;
         
         switch (exportStatus) {
                 
             case AVAssetExportSessionStatusFailed: {
                 
                 // log error to text view
                 NSError *exportError = exporter.error;
                 
                 NSLog (@"AVAssetExportSessionStatusFailed: %@", exportError);
                 
                 
                 
                 break;
             }
                 
             case AVAssetExportSessionStatusCompleted: {
                 
                 NSLog (@"AVAssetExportSessionStatusCompleted");
                 
                 
                 break;
             }
                 
             case AVAssetExportSessionStatusUnknown: {
                 NSLog (@"AVAssetExportSessionStatusUnknown");
                 break;
             }
             case AVAssetExportSessionStatusExporting: {
                 NSLog (@"AVAssetExportSessionStatusExporting");
                 break;
             }
                 
             case AVAssetExportSessionStatusCancelled: {
                 NSLog (@"AVAssetExportSessionStatusCancelled");
                 break;
             }
                 
             case AVAssetExportSessionStatusWaiting: {
                 NSLog (@"AVAssetExportSessionStatusWaiting");
                 break;
             }
                 
             default:
             { NSLog (@"didn't get export status");
                 break;
             }
         }
         
     }];
    
    
    return exportURL;
}



@end
