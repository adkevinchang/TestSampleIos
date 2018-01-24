//
//  LogitowSdk.h
//  LogitowSdk
//
//  Created by paracrakevin on 2018/1/23.
//  Copyright © 2018年 paracra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "DeviceInfo.h"
#import "LogitowCallBack.h"

# pragma mark - bluetooth 蓝牙定义
#define BLUE_DEVICE @"LOGITOW"
#define SERVICE_UUID @"69400001-B5A3-F393-E0A9-E50E24DCCA99"
#define SERVICE_MODEL_UUID @"7F510004-B5A3-F393-E0A9-E50E24DCCA9E"
#define CLIENT_UUID @"69400003-B5A3-F393-E0A9-E50E24DCCA99"
#define CLIENT_MODEL_UUID @"7F510005-B5A3-F393-E0A9-E50E24DCCA9E"
#define CHANNEL_ON_VIEW @"changeonview"

//! Project version number for LogitowSdk.
FOUNDATION_EXPORT double LogitowSdkVersionNumber;

//! Project version string for LogitowSdk.
FOUNDATION_EXPORT const unsigned char LogitowSdkVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <LogitowSdk/PublicHeader.h>
/**
 * @brief 核心类（Core class）v0.0.1
 */
@interface LogitowSdk : NSObject

//当前搜索到的所有设备
@property (nonatomic, copy) NSMutableArray* currFindDevices;
@property (nonatomic, copy) LogitowCallBack *defaultCallback;
@property (nonatomic, assign) BOOL connected;

/**
 * 单例构造方法
 * @return BabyBluetooth共享实例
 */
+ (instancetype)getInstand;

#pragma mark - 连接设备 (connect device)

/**
 *  @from                    v0.0.1
 *  @brief                   连接指定设备(Connect Logitow Device)
 *  @tip                     调用此方法时，请设置所有的委托
 *
 */
- (void) connectLogitowDevice:(NSString *)daddr;

#pragma mark - 获取设备列表 (get device list)

/**
 *  @from                    v0.0.1
 *  @brief                   开始搜索设备(start search devices)
 *  @tip                     调用此方法时，请设置所有的委托
 */
- (void) startSearchDevice;

/**
 *  @from                    v0.0.1
 *  @brief                   停止搜索设备(stop search devices)
 *  @tip                     调用此方法时，请设置所有的委托
 *
 */
- (void) stopSearchDevice;


#pragma mark - 获取设备电量 (get device power level)
/**
 *  @from                    v0.0.1
 *  @brief                   获取设备电量(get device power)
 *  @tip                     调用此方法时，请设置所有的委托
 *
 */
- (void) getDevicePower:(NSString *)daddr;

//通过设备唯一id，找寻设备信息对象
- (DeviceInfo *) getDeviceInfoByAddr:(NSString *)daddr;

/**
 *  @from                    v0.0.1
 *  @brief                   获取版本号(get version number)
 *
 */
+ (NSString *) sdkVersion;

#pragma mark - LogitowSdk 委托 (Logitow sdk delegate)
/**
 断开主积木连接的委托
 |  when disconnected logitow host.
 */
- (void)setDeviceOnDisconnect:(void (^)(BOOL *connected,NSString *addr))block;

/**
 主积木连接成功的委托
 |  when connected logitow host.
 */
- (void)setDeviceOnConnect:(void (^)(BOOL *connected,NSString *addr))block;

/**
 更新搜索到的逻辑塔主积木的设备列表
 |  when new logitow host find.
 */
- (void)setUpdateFindDevice:(void (^)(DeviceInfo *dinfo))block;

/**
主积木电量更新的委托
 |  update logitow power level.
 */
- (void)setUpdateLogitowPower:(void (^)(int level))block;

/**
 更新蓝牙通讯数据
 |  update logitow notice data.
 */
- (void)setUpdateBleValue:(void (^)(NSString *data))block;

#pragma mark - LogitowSdk 方法 (Logitow sdk function)
/**
 清除所有蓝牙数据
 |  clear all.
 */
-(void) clearAllBlueTooth;

/**
 BabyBluetooth的蓝牙委托
 |  BabyBluetooth blue Delegate.
 */
- (void)blueDelegate;

@end
