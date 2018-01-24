//
//  LogitowCallBack.h
//  LogitowSdk
//
//  Created by paracrakevin on 2018/1/23.
//  Copyright © 2018年 paracra. All rights reserved.
//

#import "DeviceInfo.h"

//更新主机电量块类
typedef void (^BBCentralUpdateLogitowPowerBlock)(int level);
//断开连接设备块类
typedef void (^BBCentralDeviceOnDisconnectBlock)(BOOL *connected,NSString *addr);
//连接设备块类
typedef void (^BBCentralDeviceOnConnectBlock)(BOOL *connected,NSString *addr);
//更新搜索到设备列表块类
typedef void (^BBCentralUpdateFindDeviceBlock)(DeviceInfo *dinfo);
//更新蓝牙通讯数据委托
typedef void (^BBCentralUpdateBleValueBlock)(NSString* data);


@interface LogitowCallBack : NSObject

#pragma mark - callback block
//更新主机电量委托
@property (nonatomic, copy) BBCentralUpdateLogitowPowerBlock updateLogitowPower;
//断开连接设备委托
@property (nonatomic, copy) BBCentralDeviceOnDisconnectBlock deviceOnDisconnect;
//连接设备委托
@property (nonatomic, copy) BBCentralDeviceOnConnectBlock deviceOnConnect;
//更新搜索到设备列表委托
@property (nonatomic, copy) BBCentralUpdateFindDeviceBlock updateFindDevice;
//更新蓝牙通讯数据委托
@property (nonatomic, copy) BBCentralUpdateBleValueBlock updateBleValue;

@end
