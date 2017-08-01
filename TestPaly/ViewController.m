//
//  ViewController.m
//  TestPaly
//
//  Created by lingang on 2017/7/7.
//  Copyright © 2017年 upyun. All rights reserved.
//

#import "ViewController.h"
#import "UPLivePlayerDemoViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UPLivePlayerDemoViewController *vc = [UPLivePlayerDemoViewController new];
    vc.title = @"播放器";
    vc.view.backgroundColor = [UIColor whiteColor];
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
