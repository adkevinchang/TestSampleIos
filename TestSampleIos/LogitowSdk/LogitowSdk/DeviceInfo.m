//
//  DeviceInfo.m
//  LogitowSdk
//
//  Created by paracrakevin on 2018/1/23.
//  Copyright © 2018年 paracra. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DeviceInfo.h"

@implementation DeviceInfo

- (instancetype)init {
    self = [super init];
    if (self) {
        _addr = nil;
        _characteristic = nil;
        _modelcharacteristic = nil;
        _currPeripheral = nil;
        _connected = 1;
        _power = 0;
    }
    return self;
}

@end
