//
//  ViewController.m
//  LogitowSdkSample
//
//  Created by paracrakevin on 2018/1/24.
//  Copyright © 2018年 paracra. All rights reserved.
//

#import "ViewController.h"
#import "LogitowSdk.h"

@interface ViewController ()

@end

@implementation ViewController
{
    LogitowSdk *lsdk;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSString *info = [LogitowSdk sdkVersion];
    NSLog(@"logitowSdk %@",info);
    lsdk = [LogitowSdk getInstand];
    [self setBleDelegate];
    //设置代理
    [lsdk startSearchDevice];
    //2AA5306F-60CC-4A60-8FA1-7AFFE4C7893F
}

-(void)setBleDelegate{
    [lsdk setUpdateBleValue:^(NSString *data) {
        NSLog(@"sample data %@",data);
        [lsdk getDevicePower:@"2AA5306F-60CC-4A60-8FA1-7AFFE4C7893F"];
    }];
    
    [lsdk setDeviceOnConnect:^(BOOL *connected, NSString *addr) {
         NSLog(@"sample OnConnect %@",addr);
    }];
    
    [lsdk setUpdateFindDevice:^(DeviceInfo *dinfo) {
         NSLog(@"sample FindDevice %@",dinfo.addr);
        if([dinfo.addr isEqualToString:@"2AA5306F-60CC-4A60-8FA1-7AFFE4C7893F"])
        {
            [lsdk stopSearchDevice];
            [lsdk connectLogitowDevice:@"2AA5306F-60CC-4A60-8FA1-7AFFE4C7893F"];
        }
    }];
    
    [lsdk setUpdateLogitowPower:^(int level) {
        NSLog(@"sample UpdateLogitowPower %d",level);
    }];
    
    [lsdk setDeviceOnDisconnect:^(BOOL *connected, NSString *addr) {
        NSLog(@"sample OnDisconnect %@",addr);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
