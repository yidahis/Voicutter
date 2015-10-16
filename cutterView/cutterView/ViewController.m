//
//  ViewController.m
//  cutterView
//
//  Created by zhouyi on 15/10/15.
//  Copyright © 2015年 yiwanjun. All rights reserved.
//

#import "ViewController.h"
#import "CutterView.h"

#define kGetSelfViewRectWidth CGRectGetWidth(self.view.frame)
#define kGetSelfViewRectHeight CGRectGetHeight(self.view.frame)
@interface ViewController ()
@property (strong,nonatomic) CutterView *cutter;
@end

@implementation ViewController{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
    self.cutter = [[CutterView alloc]initWithFrame:CGRectMake(0, 28, kGetSelfViewRectWidth, 180)];
    [self.view addSubview:self.cutter];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
